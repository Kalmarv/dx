//! The module part of the listing: the program's LLVM 3.7 IR as text, as dxc's disassembler prints it (LLVM's
//! `AssemblyWriter`: the type and slot numbering of `TypePrinting` and `SlotTracker`, the constant, instruction and
//! metadata forms of `AsmWriter.cpp`, with dxc's comment after each `dx.op` call).
use std::collections::{BTreeMap, HashMap, HashSet};
use std::fmt::Write as _;

use super::annotate;
use crate::module::{
    Atomic, Attribute, BinaryOp, CastOp, Constant, DebugLoc, DebugNode, FUNCTION_SLOT, Function, Instruction,
    Linkage, Metadata, MetadataId, Module, Op, Ordering, TailCall, Type, TypeId, Value, ValueId,
};
use crate::{Result, error};

mod debug;

/// A metadata node of the listing: one of the module's, or the location an instruction's debug location makes where
/// no node of the module is that location (`DebugLoc::get` makes the `DILocation` the bitcode does not store).
#[derive(Clone, Copy, Debug, PartialEq, Eq, Hash)]
enum Node {
    Metadata(MetadataId),
    Location(usize),
}

/// The metadata kinds an LLVM 3.7 context registers before reading a module, by their fixed ids. An attachment's
/// position among an instruction's is by this id; the kinds a module adds follow, in the order it names them.
const FIXED_KINDS: [&str; 14] = [
    "dbg",
    "tbaa",
    "prof",
    "fpmath",
    "range",
    "tbaa.struct",
    "invariant.load",
    "alias.scope",
    "noalias",
    "nontemporal",
    "llvm.mem.parallel_loop_access",
    "nonnull",
    "dereferenceable",
    "dereferenceable_or_null",
];

/// Writes the module as LLVM's `Module::print` does.
pub(super) fn write(out: &mut String, m: &Module) -> Result<()> {
    let w = Writer::new(m)?;
    w.module(out)
}

/// An attribute as LLVM orders it in a set: flags first (by their `Attribute::AttrKind`), then integer attributes (by
/// their value), then strings (by key, then value).
#[derive(Clone, Debug, PartialEq, Eq, PartialOrd, Ord)]
enum Attr {
    Enum(u32, &'static str),
    Int(u64, &'static str),
    Str(String, String),
}

impl Attr {
    /// The attribute as `Attribute::getAsString` writes it, in an attribute group (`align=4`) or elsewhere (`align 4`).
    fn text(&self, in_group: bool) -> String {
        match self {
            Attr::Enum(_, name) => (*name).to_owned(),
            Attr::Int(value, name) => match (*name, in_group) {
                ("align", false) => format!("align {value}"),
                (_, true) => format!("{name}={value}"),
                (_, false) => format!("{name}({value})"),
            },
            Attr::Str(key, value) if value.is_empty() => format!("\"{key}\""),
            Attr::Str(key, value) => format!("\"{key}\"=\"{value}\""),
        }
    }
}

/// An LLVM 3.7 attribute kind by its bitcode code: its position in `Attribute::AttrKind`, its name, and whether it
/// carries an integer.
fn attribute_kind(code: u64) -> Option<(u32, &'static str, bool)> {
    Some(match code {
        1 => (1, "align", true),
        2 => (2, "alwaysinline", false),
        3 => (4, "byval", false),
        4 => (8, "inlinehint", false),
        5 => (9, "inreg", false),
        6 => (11, "minsize", false),
        7 => (12, "naked", false),
        8 => (13, "nest", false),
        9 => (14, "noalias", false),
        10 => (15, "nobuiltin", false),
        11 => (16, "nocapture", false),
        12 => (17, "noduplicate", false),
        13 => (18, "noimplicitfloat", false),
        14 => (19, "noinline", false),
        15 => (20, "nonlazybind", false),
        16 => (24, "noredzone", false),
        17 => (25, "noreturn", false),
        18 => (26, "nounwind", false),
        19 => (27, "optsize", false),
        20 => (29, "readnone", false),
        21 => (30, "readonly", false),
        22 => (32, "returned", false),
        23 => (33, "returns_twice", false),
        24 => (34, "signext", false),
        25 => (35, "alignstack", true),
        26 => (36, "ssp", false),
        27 => (37, "sspreq", false),
        28 => (38, "sspstrong", false),
        29 => (40, "sret", false),
        30 => (41, "sanitize_address", false),
        31 => (42, "sanitize_thread", false),
        32 => (43, "sanitize_memory", false),
        33 => (44, "uwtable", false),
        34 => (45, "zeroext", false),
        35 => (3, "builtin", false),
        36 => (6, "cold", false),
        37 => (28, "optnone", false),
        38 => (5, "inalloca", false),
        39 => (21, "nonnull", false),
        40 => (10, "jumptable", false),
        41 => (22, "dereferenceable", true),
        42 => (23, "dereferenceable_or_null", true),
        43 => (7, "convergent", false),
        44 => (39, "safestack", false),
        45 => (31, "argmemonly", false),
        _ => return None,
    })
}

/// An attribute list as LLVM holds it: for each slot (0 the result, 1 and up the parameters, [`FUNCTION_SLOT`] the
/// function), its attributes merged from the list's groups and sorted.
type AttributeSet = BTreeMap<u64, Vec<Attr>>;

/// An `AttrBuilder` of one slot: its flags and integer attributes by kind, its strings by key.
type Builder = (BTreeMap<u32, Attr>, BTreeMap<String, String>);

fn attribute_set(m: &Module, list: usize) -> Result<AttributeSet> {
    let groups = m.attribute_lists.get(list).ok_or_else(|| {
        error(
            m.at,
            format!("attribute list {list} of {}", m.attribute_lists.len()),
        )
    })?;
    // per slot, as LLVM's AttrBuilder merges them: a flag once, an integer attribute and a string by its kind or key,
    // the last one read winning
    let mut builders: BTreeMap<u64, Builder> = BTreeMap::new();
    for id in groups {
        let group = m
            .attribute_groups
            .iter()
            .find(|g| g.id == *id)
            .ok_or_else(|| error(m.at, format!("attribute group {id} is missing")))?;
        let (kinds, strings) = builders.entry(group.slot).or_default();
        for a in &group.attributes {
            match a {
                Attribute::Enum(code) | Attribute::Integer(code, _) => {
                    let (order, name, int) =
                        attribute_kind(*code).ok_or_else(|| error(m.at, format!("attribute kind {code}")))?;
                    let attr = match (a, int) {
                        (Attribute::Enum(_), false) => Attr::Enum(order, name),
                        (Attribute::Integer(_, value), true) => Attr::Int(*value, name),
                        _ => return Err(error(m.at, format!("attribute {name} with the wrong form"))),
                    };
                    kinds.insert(order, attr);
                }
                Attribute::String(key, value) => {
                    strings.insert(key.clone(), value.clone());
                }
            }
        }
    }
    Ok(builders
        .into_iter()
        .map(|(slot, (kinds, strings))| {
            let mut attrs: Vec<Attr> = kinds.into_values().collect();
            attrs.extend(strings.into_iter().map(|(k, v)| Attr::Str(k, v)));
            attrs.sort();
            (slot, attrs)
        })
        .collect())
}

fn join(attrs: &[Attr], in_group: bool) -> String {
    attrs
        .iter()
        .map(|a| a.text(in_group))
        .collect::<Vec<_>>()
        .join(" ")
}

/// The numbering the listing gives: struct types, global values without names, metadata nodes and the function
/// attribute sets.
struct Writer<'m> {
    m: &'m Module,
    /// The numbered struct types (identified, without a name), by number.
    numbered: Vec<TypeId>,
    /// The number of each numbered struct type.
    numbers: HashMap<TypeId, usize>,
    /// The named struct types, in the order met.
    named: Vec<TypeId>,
    /// The slot of each global value without a name.
    global_slots: HashMap<ValueId, usize>,
    /// The slot of each metadata node, and the nodes by slot.
    md_slots: HashMap<Node, usize>,
    md_order: Vec<Node>,
    /// The locations instructions are at that no node of the module is, by [`Node::Location`].
    locations: Vec<DebugLoc>,
    /// The node of each location an instruction is at.
    location_nodes: HashMap<DebugLoc, Node>,
    /// The function attribute sets by slot (`#0`...).
    attribute_sets: Vec<Vec<Attr>>,
    /// Each function body by the module value of its function.
    bodies: HashMap<ValueId, &'m Function>,
    /// The module's names of its values.
    names: HashMap<ValueId, &'m str>,
    /// The context id of each metadata kind the module names (by its id in the file).
    kind_order: HashMap<u64, usize>,
}

/// A function body as it is printed: the names of its values and blocks, the slots of those without, and each block's
/// predecessors in the order LLVM keeps their uses.
struct Local<'m> {
    f: &'m Function,
    names: HashMap<ValueId, &'m str>,
    block_names: HashMap<usize, &'m str>,
    slots: HashMap<ValueId, usize>,
    block_slots: HashMap<usize, usize>,
    /// The instructions of each block, in order.
    blocks: Vec<Vec<&'m Instruction>>,
    /// The blocks whose terminators branch to each block, as `pred_iterator` walks them.
    preds: Vec<Vec<usize>>,
}

impl<'m> Writer<'m> {
    fn new(m: &'m Module) -> Result<Self> {
        let mut w = Writer {
            m,
            numbered: Vec::new(),
            numbers: HashMap::new(),
            named: Vec::new(),
            global_slots: HashMap::new(),
            md_slots: HashMap::new(),
            md_order: Vec::new(),
            locations: Vec::new(),
            location_nodes: HashMap::new(),
            attribute_sets: Vec::new(),
            bodies: m.functions.iter().map(|f| (f.value, f)).collect(),
            names: m.names.iter().map(|(v, n)| (*v, n.as_str())).collect(),
            kind_order: HashMap::new(),
        };
        // a kind the context registers keeps its id; the module's others follow, in the order it names them
        let mut next = FIXED_KINDS.len();
        for (id, name) in &m.kinds {
            let order = match FIXED_KINDS.iter().position(|k| k == name) {
                Some(p) => p,
                None => {
                    next = next.saturating_add(1);
                    next.saturating_sub(1)
                }
            };
            w.kind_order.insert(*id, order);
        }
        // `DILocation::get` uniques a location: an instruction at the location of a module node is at that node
        for (id, md) in m.metadata.iter().enumerate() {
            if let Metadata::Debug {
                distinct: false,
                node:
                    DebugNode::Location {
                        line,
                        column,
                        scope,
                        inlined_at,
                    },
            } = md
            {
                let loc = DebugLoc {
                    line: *line,
                    column: *column,
                    scope: Some(*scope),
                    inlined_at: *inlined_at,
                };
                w.location_nodes.entry(loc).or_insert(Node::Metadata(id));
            }
        }
        for f in &m.functions {
            for loc in f.instructions.iter().filter_map(|i| i.debug_loc) {
                if loc.scope.is_some() && !w.location_nodes.contains_key(&loc) {
                    w.location_nodes.insert(loc, Node::Location(w.locations.len()));
                    w.locations.push(loc);
                }
            }
        }
        let structs = Finder::new(&w).run();
        for t in structs {
            match m.types.get(t) {
                Some(
                    Type::Struct {
                        name: None,
                        literal: false,
                        ..
                    }
                    | Type::Opaque(None),
                ) => {
                    w.numbers.insert(t, w.numbered.len());
                    w.numbered.push(t);
                }
                Some(
                    Type::Struct {
                        name: Some(_),
                        literal: false,
                        ..
                    }
                    | Type::Opaque(Some(_)),
                ) => w.named.push(t),
                _ => {}
            }
        }
        w.number_slots()?;
        Ok(w)
    }

    /// A value and its type, from the module or the body being printed.
    fn lookup(&self, local: Option<&Local<'m>>, id: ValueId) -> Result<(&'m Value, TypeId)> {
        let found = match local {
            Some(l) if id >= l.f.first => {
                let i = id.saturating_sub(l.f.first);
                l.f.locals.get(i).zip(l.f.local_types.get(i).copied())
            }
            _ => self.m.values.get(id).zip(self.m.value_types.get(id).copied()),
        };
        found.ok_or_else(|| error(self.m.at, format!("value {id} is missing")))
    }

    // ---- types -------------------------------------------------------------------------------------------------

    /// A type as LLVM writes it.
    fn write_ty(&self, s: &mut String, t: TypeId) {
        match self.m.types.get(t) {
            None => s.push_str("<invalid type>"),
            Some(Type::Void) => s.push_str("void"),
            Some(Type::Label) => s.push_str("label"),
            Some(Type::Metadata) => s.push_str("metadata"),
            Some(Type::Half) => s.push_str("half"),
            Some(Type::Float) => s.push_str("float"),
            Some(Type::Double) => s.push_str("double"),
            Some(Type::Integer(w)) => {
                let _ = write!(s, "i{w}");
            }
            Some(Type::Function { vararg, ret, params }) => {
                self.write_ty(s, *ret);
                s.push_str(" (");
                for (i, p) in params.iter().enumerate() {
                    if i > 0 {
                        s.push_str(", ");
                    }
                    self.write_ty(s, *p);
                }
                if *vararg {
                    if !params.is_empty() {
                        s.push_str(", ");
                    }
                    s.push_str("...");
                }
                s.push(')');
            }
            Some(Type::Struct { literal: true, .. }) => self.struct_body(s, t),
            Some(Type::Struct { name: Some(n), .. } | Type::Opaque(Some(n))) => llvm_name(s, n, "%"),
            Some(Type::Struct { name: None, .. } | Type::Opaque(None)) => match self.numbers.get(&t) {
                Some(n) => {
                    let _ = write!(s, "%{n}");
                }
                None => s.push_str("%\"type 0x0\""),
            },
            Some(Type::Pointer(to, space)) => {
                self.write_ty(s, *to);
                if *space != 0 {
                    let _ = write!(s, " addrspace({space})");
                }
                s.push('*');
            }
            Some(Type::Array(n, e)) => {
                let _ = write!(s, "[{n} x ");
                self.write_ty(s, *e);
                s.push(']');
            }
            Some(Type::Vector(n, e)) => {
                let _ = write!(s, "<{n} x ");
                self.write_ty(s, *e);
                s.push('>');
            }
        }
    }

    /// `TypePrinting::printStructBody`.
    fn struct_body(&self, s: &mut String, t: TypeId) {
        match self.m.types.get(t) {
            Some(Type::Struct { elements, packed, .. }) => {
                if *packed {
                    s.push('<');
                }
                if elements.is_empty() {
                    s.push_str("{}");
                } else {
                    s.push_str("{ ");
                    for (i, e) in elements.iter().enumerate() {
                        if i > 0 {
                            s.push_str(", ");
                        }
                        self.write_ty(s, *e);
                    }
                    s.push_str(" }");
                }
                if *packed {
                    s.push('>');
                }
            }
            _ => s.push_str("opaque"),
        }
    }

    /// The element type of a vector, or the type itself.
    fn scalar(&self, t: TypeId) -> Option<&'m Type> {
        match self.m.types.get(t) {
            Some(Type::Vector(_, e)) => self.m.types.get(*e),
            other => other,
        }
    }

    // ---- slots -------------------------------------------------------------------------------------------------

    /// Attachments as LLVM's `getAllMetadata` lists them: one per kind (the last attached), by the kind's context id.
    fn sorted_kinds(&self, attachments: &[crate::module::Attachment]) -> Vec<(u64, MetadataId)> {
        let mut by_kind: Vec<(usize, u64, MetadataId)> = Vec::new();
        for a in attachments {
            let order = self.kind_order.get(&a.kind).copied().unwrap_or(usize::MAX);
            match by_kind.iter_mut().find(|(_, k, _)| *k == a.kind) {
                Some(entry) => entry.2 = a.node,
                None => by_kind.push((order, a.kind, a.node)),
            }
        }
        by_kind.sort_by_key(|(order, _, _)| *order);
        by_kind.into_iter().map(|(_, k, n)| (k, n)).collect()
    }

    fn sorted_attachments(&self, attachments: &[crate::module::Attachment]) -> Vec<MetadataId> {
        self.sorted_kinds(attachments)
            .into_iter()
            .map(|(_, n)| n)
            .collect()
    }

    /// `SlotTracker::processModule`, and then what each function body adds as it is printed: the global values
    /// without names, the metadata nodes (those named metadata lists, then each body's attachments) and the function
    /// attribute sets (the functions', then each body's calls').
    fn number_slots(&mut self) -> Result<()> {
        let m = self.m;
        let mut next = 0usize;
        for want_global in [true, false] {
            for (id, v) in m.values.iter().enumerate() {
                let fits = match v {
                    Value::Global { .. } => want_global,
                    Value::Function { .. } => !want_global,
                    _ => false,
                };
                if fits && !self.names.contains_key(&id) {
                    self.global_slots.insert(id, next);
                    next = next.saturating_add(1);
                }
            }
        }
        for (_, nodes) in &m.named_metadata {
            for n in nodes {
                self.md_slot(Node::Metadata(*n));
            }
        }
        for v in &m.values {
            if let Value::Function {
                attributes: Some(list),
                ..
            } = v
            {
                self.attribute_slot(*list)?;
            }
        }
        for (id, v) in m.values.iter().enumerate() {
            let Value::Function { .. } = v else { continue };
            let Some(body) = self.bodies.get(&id).copied() else {
                continue;
            };
            for n in self.sorted_attachments(&body.attachments) {
                self.md_slot(Node::Metadata(n));
            }
            // `processInstructionMetadata`: the nodes an intrinsic is passed, then the location and the attachments
            for inst in &body.instructions {
                if let Op::Call { function, args, .. } = &inst.op
                    && self.names.get(function).is_some_and(|n| n.starts_with("llvm."))
                {
                    for a in args {
                        let i = a.saturating_sub(body.first);
                        if let Some(Value::Metadata(md)) = body.locals.get(i).filter(|_| *a >= body.first) {
                            self.md_slot(Node::Metadata(*md));
                        }
                    }
                }
                if let Some(n) = self.location_node(inst.debug_loc) {
                    self.md_slot(n);
                }
                for n in self.sorted_attachments(&inst.attachments) {
                    self.md_slot(Node::Metadata(n));
                }
            }
            for inst in &body.instructions {
                if let Op::Call {
                    attributes: Some(list),
                    ..
                } = &inst.op
                {
                    self.attribute_slot(*list)?;
                }
            }
        }
        Ok(())
    }

    /// `CreateMetadataSlot`: a node, then the nodes among its operands, depth first (a string or a value takes no
    /// slot). The walk keeps its own stack: a program's debug types nest deeply.
    fn md_slot(&mut self, node: Node) {
        let mut stack = vec![node];
        while let Some(node) = stack.pop() {
            let Some(ops) = self.node_operands(node) else {
                continue;
            };
            if self.md_slots.contains_key(&node) {
                continue;
            }
            self.md_slots.insert(node, self.md_order.len());
            self.md_order.push(node);
            stack.extend(ops.into_iter().rev().flatten().map(Node::Metadata));
        }
    }

    /// The operands of a metadata node in LLVM's order; `None` where it is not a node (a string or a value).
    fn node_operands(&self, node: Node) -> Option<Vec<Option<MetadataId>>> {
        match node {
            Node::Metadata(id) => match self.m.metadata.get(id)? {
                Metadata::Node(ops) | Metadata::Distinct(ops) => Some(ops.clone()),
                Metadata::Debug { node, .. } => Some(node.operands()),
                Metadata::String(_) | Metadata::Value { .. } => None,
            },
            Node::Location(i) => self.locations.get(i).map(debug::location_operands),
        }
    }

    fn attribute_slot(&mut self, list: usize) -> Result<()> {
        if let Some(attrs) = attribute_set(self.m, list)?.remove(&FUNCTION_SLOT)
            && !attrs.is_empty()
            && !self.attribute_sets.contains(&attrs)
        {
            self.attribute_sets.push(attrs);
        }
        Ok(())
    }

    /// The slot (`#N`) of the function attributes of an attribute set, where it has any.
    fn attribute_group(&self, set: &AttributeSet) -> Option<usize> {
        let attrs = set.get(&FUNCTION_SLOT).filter(|a| !a.is_empty())?;
        self.attribute_sets.iter().position(|s| s == attrs)
    }

    /// The attribute set a function or call names; empty where it names none.
    fn attributes(&self, list: Option<usize>) -> Result<AttributeSet> {
        list.map_or_else(|| Ok(AttributeSet::new()), |l| attribute_set(self.m, l))
    }

    /// `SlotTracker::processFunction` for a body, with its blocks' predecessors.
    fn local(&self, f: &'m Function) -> Result<Local<'m>> {
        let names: HashMap<ValueId, &str> = f.names.iter().map(|(v, n)| (*v, n.as_str())).collect();
        let block_names: HashMap<usize, &str> = f.block_names.iter().map(|(b, n)| (*b, n.as_str())).collect();
        let params = match self.m.values.get(f.value) {
            Some(Value::Function { ty, .. }) => match self.m.types.get(*ty) {
                Some(Type::Function { params, .. }) => params.len(),
                _ => 0,
            },
            _ => 0,
        };
        let mut blocks: Vec<Vec<&Instruction>> = vec![Vec::new(); f.blocks];
        for inst in &f.instructions {
            blocks
                .get_mut(inst.block)
                .ok_or_else(|| error(inst.at, format!("basic block {} of {}", inst.block, f.blocks)))?
                .push(inst);
        }
        let mut slots = HashMap::new();
        let mut block_slots = HashMap::new();
        let mut next = 0usize;
        for i in 0..params {
            let id = f.first.saturating_add(i);
            if !names.contains_key(&id) {
                slots.insert(id, next);
                next = next.saturating_add(1);
            }
        }
        for (b, insts) in blocks.iter().enumerate() {
            if !block_names.contains_key(&b) {
                block_slots.insert(b, next);
                next = next.saturating_add(1);
            }
            for inst in insts {
                if let Some((id, ty)) = inst.result
                    && !matches!(self.m.types.get(ty), Some(Type::Void))
                    && !names.contains_key(&id)
                {
                    slots.insert(id, next);
                    next = next.saturating_add(1);
                }
            }
        }
        // each terminator's uses of its successors, in the order they are made (a branch's true target first, a
        // switch's default before its cases); a block's use list holds them most recent first
        let mut uses: Vec<Vec<usize>> = vec![Vec::new(); f.blocks];
        for inst in &f.instructions {
            let targets: Vec<usize> = match &inst.op {
                Op::Branch { .. } | Op::CondBranch { .. } | Op::Switch { .. } => inst.op.blocks(),
                _ => Vec::new(),
            };
            for t in targets {
                if let Some(u) = uses.get_mut(t) {
                    u.push(inst.block);
                }
            }
        }
        for u in &mut uses {
            u.reverse();
        }
        // a USELIST_CODE_BB record gives each use (in that order) its position: a stable sort by them, where it
        // covers every use
        for (b, order) in &f.block_use_orders {
            if let Some(u) = uses.get_mut(*b)
                && u.len() == order.len()
            {
                let mut keyed: Vec<(u64, usize)> = order.iter().copied().zip(u.iter().copied()).collect();
                keyed.sort_by_key(|(k, _)| *k);
                *u = keyed.into_iter().map(|(_, p)| p).collect();
            }
        }
        Ok(Local {
            f,
            names,
            block_names,
            slots,
            block_slots,
            blocks,
            preds: uses,
        })
    }

    // ---- values ------------------------------------------------------------------------------------------------

    /// `writeOperand`: a value, after its type where `typed`.
    fn operand(&self, s: &mut String, local: Option<&Local<'m>>, id: ValueId, typed: bool) -> Result<()> {
        let (v, ty) = self.lookup(local, id)?;
        if typed {
            self.write_ty(s, ty);
            s.push(' ');
        }
        self.bare(s, local, id, v, ty)
    }

    /// `WriteAsOperandInternal`: its name, a constant's text, or its slot.
    fn bare(
        &self,
        s: &mut String,
        local: Option<&Local<'m>>,
        id: ValueId,
        v: &Value,
        ty: TypeId,
    ) -> Result<()> {
        let in_body = local.filter(|l| id >= l.f.first);
        let name = match in_body {
            Some(l) => l.names.get(&id),
            None => self.names.get(&id),
        };
        if let Some(n) = name {
            llvm_name(s, n, if in_body.is_some() { "%" } else { "@" });
            return Ok(());
        }
        match v {
            Value::Constant(c) => self.constant(s, local, c, ty)?,
            Value::Global { .. } | Value::Function { .. } => match self.global_slots.get(&id) {
                Some(n) => {
                    let _ = write!(s, "@{n}");
                }
                None => s.push_str("<badref>"),
            },
            Value::Local => match in_body.and_then(|l| l.slots.get(&id)) {
                Some(n) => {
                    let _ = write!(s, "%{n}");
                }
                None => s.push_str("<badref>"),
            },
            // `MetadataAsValue`: the metadata as an operand; a body's own is one of its values after its type
            Value::Metadata(md) => match in_body.filter(|l| *md >= l.f.first_metadata) {
                Some(l) => match l.f.metadata.get(md.saturating_sub(l.f.first_metadata)) {
                    Some(Metadata::Value { value, .. }) => self.operand(s, Some(l), *value, true)?,
                    _ => {
                        return Err(error(
                            self.m.at,
                            format!("metadata {md} of the body is not a value"),
                        ));
                    }
                },
                None => self.md_operand(s, Some(*md))?,
            },
        }
        Ok(())
    }

    /// A basic block as an operand, after `label ` where `typed`.
    fn block(&self, s: &mut String, l: &Local<'m>, b: usize, typed: bool) {
        if typed {
            s.push_str("label ");
        }
        match (l.block_names.get(&b), l.block_slots.get(&b)) {
            (Some(n), _) => llvm_name(s, n, "%"),
            (None, Some(n)) => {
                let _ = write!(s, "%{n}");
            }
            (None, None) => s.push_str("<badref>"),
        }
    }

    /// Whether a constant is its type's null value (`Constant::isNullValue`): zero, positive zero, a null pointer,
    /// or an aggregate of them.
    fn is_null(&self, local: Option<&Local<'m>>, id: ValueId) -> Result<bool> {
        let (v, ty) = self.lookup(local, id)?;
        let Value::Constant(c) = v else { return Ok(false) };
        Ok(match c {
            Constant::Null => true,
            Constant::Integer(v) => *v == 0,
            Constant::Float(bits) => float_bits(self.m.types.get(ty), *bits) == 0,
            Constant::Aggregate(ids) => {
                for e in ids {
                    if !self.is_null(local, *e)? {
                        return Ok(false);
                    }
                }
                true
            }
            Constant::Data(elements) => elements.iter().all(|e| *e == 0),
            Constant::String(bytes) => bytes.iter().all(|b| *b == 0),
            _ => false,
        })
    }

    /// Whether a constant is `undef`, as LLVM folds an aggregate of only `undef` into one.
    fn is_undef(&self, local: Option<&Local<'m>>, id: ValueId) -> Result<bool> {
        let (v, _) = self.lookup(local, id)?;
        Ok(match v {
            Value::Constant(Constant::Undef) => true,
            Value::Constant(Constant::Aggregate(ids)) if !ids.is_empty() => {
                for e in ids {
                    if !self.is_undef(local, *e)? {
                        return Ok(false);
                    }
                }
                true
            }
            _ => false,
        })
    }

    /// `WriteConstantInternal`, over the constant LLVM's uniquing makes of the record: an aggregate of nulls is
    /// `zeroinitializer`, one of `undef` is `undef`, an `i8` array of integers is a string.
    fn constant(&self, s: &mut String, local: Option<&Local<'m>>, c: &Constant, ty: TypeId) -> Result<()> {
        let t = self.m.types.get(ty);
        match c {
            Constant::Null => match t {
                Some(Type::Integer(1)) => s.push_str("false"),
                Some(Type::Integer(_)) => s.push('0'),
                Some(Type::Half | Type::Float | Type::Double) => s.push_str(&float_text(t, 0)),
                Some(Type::Pointer(..)) => s.push_str("null"),
                _ => s.push_str("zeroinitializer"),
            },
            Constant::Undef => s.push_str("undef"),
            Constant::Integer(v) => match t {
                Some(Type::Integer(1)) => s.push_str(if *v & 1 != 0 { "true" } else { "false" }),
                Some(Type::Integer(w)) => {
                    let _ = write!(s, "{}", signed(*v, *w));
                }
                _ => {
                    let _ = write!(s, "{v}");
                }
            },
            Constant::Float(bits) => s.push_str(&float_text(t, *bits)),
            Constant::Aggregate(ids) => {
                let mut null = true;
                let mut undef = !ids.is_empty();
                for e in ids {
                    null = null && self.is_null(local, *e)?;
                    undef = undef && self.is_undef(local, *e)?;
                }
                if null {
                    s.push_str("zeroinitializer");
                } else if undef {
                    s.push_str("undef");
                } else {
                    self.aggregate(s, local, ids, ty)?;
                }
            }
            Constant::Data(elements) => {
                if elements.iter().all(|e| *e == 0) {
                    s.push_str("zeroinitializer");
                    return Ok(());
                }
                let (open, close, e) = match t {
                    Some(Type::Array(_, e)) => ('[', ']', *e),
                    Some(Type::Vector(_, e)) => ('<', '>', *e),
                    _ => {
                        return Err(error(
                            self.m.at,
                            "constant data of a type that is not an array or vector",
                        ));
                    }
                };
                let et = self.m.types.get(e);
                if open == '[' && matches!(et, Some(Type::Integer(8))) {
                    let bytes: Vec<u8> = elements.iter().map(|b| (b & 0xFF) as u8).collect();
                    s.push_str("c\"");
                    escaped(s, &bytes);
                    s.push('"');
                    return Ok(());
                }
                s.push(open);
                for (i, bits) in elements.iter().enumerate() {
                    if i > 0 {
                        s.push_str(", ");
                    }
                    self.write_ty(s, e);
                    s.push(' ');
                    match et {
                        Some(Type::Integer(w)) => {
                            let _ = write!(s, "{}", signed(i64::from_ne_bytes(bits.to_ne_bytes()), *w));
                        }
                        _ => s.push_str(&float_text(et, *bits)),
                    }
                }
                s.push(close);
            }
            Constant::String(bytes) => {
                if bytes.iter().all(|b| *b == 0) {
                    s.push_str("zeroinitializer");
                } else {
                    s.push_str("c\"");
                    escaped(s, bytes);
                    s.push('"');
                }
            }
            Constant::Gep {
                base,
                indices,
                source,
                inbounds,
            } => {
                s.push_str("getelementptr");
                if *inbounds {
                    s.push_str(" inbounds");
                }
                s.push_str(" (");
                self.write_ty(s, *source);
                s.push_str(", ");
                self.operand(s, local, *base, true)?;
                for i in indices {
                    s.push_str(", ");
                    self.operand(s, local, *i, true)?;
                }
                s.push(')');
            }
            Constant::Cast { op, value } => {
                s.push_str(cast_name(*op));
                s.push_str(" (");
                self.operand(s, local, *value, true)?;
                s.push_str(" to ");
                self.write_ty(s, ty);
                s.push(')');
            }
            Constant::Binary { op, lhs, rhs, flags } => {
                let (_, lt) = self.lookup(local, *lhs)?;
                let float = is_float(self.scalar(lt));
                s.push_str(binary_name(*op, float));
                if !float {
                    integer_flags(s, *op, *flags);
                }
                s.push_str(" (");
                self.operand(s, local, *lhs, true)?;
                s.push_str(", ");
                self.operand(s, local, *rhs, true)?;
                s.push(')');
            }
            Constant::Compare {
                predicate: p,
                lhs,
                rhs,
            } => {
                s.push_str(if *p >= 32 { "icmp " } else { "fcmp " });
                s.push_str(predicate(*p));
                s.push_str(" (");
                self.operand(s, local, *lhs, true)?;
                s.push_str(", ");
                self.operand(s, local, *rhs, true)?;
                s.push(')');
            }
        }
        Ok(())
    }

    /// An array, structure or vector constant by its elements.
    fn aggregate(
        &self,
        s: &mut String,
        local: Option<&Local<'m>>,
        ids: &[ValueId],
        ty: TypeId,
    ) -> Result<()> {
        match self.m.types.get(ty) {
            Some(Type::Array(_, e)) => {
                // an array of i8 integers is a ConstantDataArray, which is a string
                if matches!(self.m.types.get(*e), Some(Type::Integer(8))) {
                    let mut bytes = Vec::with_capacity(ids.len());
                    for id in ids {
                        match self.lookup(local, *id)?.0 {
                            Value::Constant(Constant::Integer(v)) => bytes.push((v & 0xFF) as u8),
                            Value::Constant(Constant::Null) => bytes.push(0),
                            _ => break,
                        }
                    }
                    if bytes.len() == ids.len() {
                        s.push_str("c\"");
                        escaped(s, &bytes);
                        s.push('"');
                        return Ok(());
                    }
                }
                s.push('[');
                self.elements(s, local, ids)?;
                s.push(']');
            }
            Some(Type::Vector(..)) => {
                s.push('<');
                self.elements(s, local, ids)?;
                s.push('>');
            }
            Some(Type::Struct { packed, .. }) => {
                if *packed {
                    s.push('<');
                }
                s.push('{');
                if !ids.is_empty() {
                    s.push(' ');
                    self.elements(s, local, ids)?;
                    s.push(' ');
                }
                s.push('}');
                if *packed {
                    s.push('>');
                }
            }
            _ => {
                return Err(error(
                    self.m.at,
                    "an aggregate constant of a type that is not an aggregate",
                ));
            }
        }
        Ok(())
    }

    fn elements(&self, s: &mut String, local: Option<&Local<'m>>, ids: &[ValueId]) -> Result<()> {
        for (i, id) in ids.iter().enumerate() {
            if i > 0 {
                s.push_str(", ");
            }
            self.operand(s, local, *id, true)?;
        }
        Ok(())
    }

    /// A metadata operand of a node: `null`, a node's slot, a string, or a value after its type.
    fn md_operand(&self, s: &mut String, op: Option<MetadataId>) -> Result<()> {
        let Some(id) = op else {
            s.push_str("null");
            return Ok(());
        };
        match self.m.metadata.get(id) {
            Some(Metadata::Node(_) | Metadata::Distinct(_) | Metadata::Debug { .. }) => {
                self.md_ref(s, Node::Metadata(id));
            }
            Some(Metadata::String(bytes)) => {
                s.push_str("!\"");
                escaped(s, bytes);
                s.push('"');
            }
            Some(Metadata::Value { value, .. }) => self.operand(s, None, *value, true)?,
            None => return Err(error(self.m.at, format!("metadata {id} is missing"))),
        }
        Ok(())
    }

    fn md_ref(&self, s: &mut String, node: Node) {
        match self.md_slots.get(&node) {
            Some(n) => {
                let _ = write!(s, "!{n}");
            }
            None => s.push_str("<badref>"),
        }
    }

    /// `printMetadataAttachments`: each as `{separator}!kind !N`.
    fn attachments(&self, s: &mut String, attachments: &[crate::module::Attachment], separator: &str) {
        for (kind, node) in self.sorted_kinds(attachments) {
            s.push_str(separator);
            match self.m.kind_name(kind) {
                Some(name) => {
                    s.push('!');
                    md_identifier(s, name);
                }
                None => {
                    let _ = write!(s, "!<unknown kind #{kind}>");
                }
            }
            s.push(' ');
            self.md_ref(s, Node::Metadata(node));
        }
    }

    // ---- the module --------------------------------------------------------------------------------------------

    /// `AssemblyWriter::printModule`.
    fn module(&self, s: &mut String) -> Result<()> {
        let m = self.m;
        if let Some(dl) = m.datalayout.as_deref().filter(|d| !d.is_empty()) {
            let _ = writeln!(s, "target datalayout = \"{dl}\"");
        }
        if let Some(triple) = m.triple.as_deref().filter(|t| !t.is_empty()) {
            let _ = writeln!(s, "target triple = \"{triple}\"");
        }
        if let Some(asm) = m.asm.as_deref().filter(|a| !a.is_empty()) {
            s.push('\n');
            let mut rest = asm;
            loop {
                let (front, after) = rest.split_once('\n').unwrap_or((rest, ""));
                s.push_str("module asm \"");
                escaped(s, front.as_bytes());
                s.push_str("\"\n");
                rest = after;
                if rest.is_empty() {
                    break;
                }
            }
        }
        if !self.numbered.is_empty() || !self.named.is_empty() {
            s.push('\n');
            for (i, t) in self.numbered.iter().enumerate() {
                let _ = write!(s, "%{i} = type ");
                self.struct_body(s, *t);
                s.push('\n');
            }
            for t in &self.named {
                if let Some(Type::Struct { name: Some(n), .. } | Type::Opaque(Some(n))) = m.types.get(*t) {
                    llvm_name(s, n, "%");
                }
                s.push_str(" = type ");
                self.struct_body(s, *t);
                s.push('\n');
            }
        }
        let globals: Vec<ValueId> = (0..m.values.len())
            .filter(|id| matches!(m.values.get(*id), Some(Value::Global { .. })))
            .collect();
        if !globals.is_empty() {
            s.push('\n');
        }
        for id in globals {
            self.global(s, id)?;
            s.push('\n');
        }
        for (id, v) in m.values.iter().enumerate() {
            if let Value::Function { .. } = v {
                self.function(s, id)?;
            }
        }
        if !self.attribute_sets.is_empty() {
            s.push('\n');
            for (i, attrs) in self.attribute_sets.iter().enumerate() {
                let _ = writeln!(s, "attributes #{i} = {{ {} }}", join(attrs, true));
            }
        }
        if !m.named_metadata.is_empty() {
            s.push('\n');
        }
        for (name, nodes) in &m.named_metadata {
            s.push('!');
            md_identifier(s, name);
            s.push_str(" = !{");
            for (i, n) in nodes.iter().enumerate() {
                if i > 0 {
                    s.push_str(", ");
                }
                self.md_ref(s, Node::Metadata(*n));
            }
            s.push_str("}\n");
        }
        if !self.md_order.is_empty() {
            s.push('\n');
        }
        for (slot, node) in self.md_order.iter().enumerate() {
            let _ = write!(s, "!{slot} = ");
            let id = match *node {
                Node::Location(i) => {
                    let l = self
                        .locations
                        .get(i)
                        .ok_or_else(|| error(m.at, format!("location {i} is missing")))?;
                    self.location(s, l)?;
                    s.push('\n');
                    continue;
                }
                Node::Metadata(id) => id,
            };
            let (distinct, ops) = match m.metadata.get(id) {
                Some(Metadata::Node(ops)) => (false, ops),
                Some(Metadata::Distinct(ops)) => (true, ops),
                Some(Metadata::Debug { distinct, node }) => {
                    self.debug_node(s, *distinct, node)?;
                    s.push('\n');
                    continue;
                }
                _ => return Err(error(m.at, format!("metadata {id} is not a node"))),
            };
            if distinct {
                s.push_str("distinct ");
            }
            s.push_str("!{");
            for (i, op) in ops.iter().enumerate() {
                if i > 0 {
                    s.push_str(", ");
                }
                self.md_operand(s, *op)?;
            }
            s.push_str("}\n");
        }
        Ok(())
    }

    /// `AssemblyWriter::printGlobal`.
    fn global(&self, s: &mut String, id: ValueId) -> Result<()> {
        let (v, ty) = self.lookup(None, id)?;
        let Value::Global {
            value_ty,
            init,
            constant,
            address_space,
            properties: p,
            thread_local,
            externally_initialized,
            ..
        } = v
        else {
            return Ok(());
        };
        self.bare(s, None, id, v, ty)?;
        s.push_str(" = ");
        if init.is_none() && p.linkage == Linkage::External {
            s.push_str("external ");
        }
        s.push_str(linkage_text(p.linkage));
        s.push_str(visibility_text(p.visibility));
        s.push_str(dll_text(p.dll_storage));
        s.push_str(thread_local_text(*thread_local));
        if p.unnamed_addr {
            s.push_str("unnamed_addr ");
        }
        if *address_space != 0 {
            let _ = write!(s, "addrspace({address_space}) ");
        }
        if *externally_initialized {
            s.push_str("externally_initialized ");
        }
        s.push_str(if *constant { "constant " } else { "global " });
        self.write_ty(s, *value_ty);
        if let Some(init) = init {
            s.push(' ');
            self.operand(s, None, *init, false)?;
        }
        if let Some(section) = &p.section {
            s.push_str(", section \"");
            escaped(s, section.as_bytes());
            s.push('"');
        }
        if p.alignment != 0 {
            let _ = write!(s, ", align {}", p.alignment);
        }
        Ok(())
    }

    /// `AssemblyWriter::printFunction`.
    fn function(&self, s: &mut String, id: ValueId) -> Result<()> {
        let (v, ptr_ty) = self.lookup(None, id)?;
        let Value::Function {
            ty,
            declaration,
            attributes,
            properties: p,
            calling_conv: cc,
            gc,
        } = v
        else {
            return Ok(());
        };
        let Some(Type::Function { vararg, ret, params }) = self.m.types.get(*ty) else {
            return Err(error(
                self.m.at,
                format!("function {id} of a type that is not a function's"),
            ));
        };
        let attrs = self.attributes(*attributes)?;
        let body = if *declaration {
            None
        } else {
            self.bodies.get(&id).copied()
        };
        let local = body.map(|f| self.local(f)).transpose()?;
        s.push('\n');
        if let Some(fn_attrs) = attrs.get(&FUNCTION_SLOT) {
            let flags: Vec<Attr> = fn_attrs
                .iter()
                .filter(|a| !matches!(a, Attr::Str(..)))
                .cloned()
                .collect();
            if !flags.is_empty() {
                let _ = writeln!(s, "; Function Attrs: {}", join(&flags, false));
            }
        }
        s.push_str(if local.is_some() { "define " } else { "declare " });
        s.push_str(linkage_text(p.linkage));
        s.push_str(visibility_text(p.visibility));
        s.push_str(dll_text(p.dll_storage));
        if *cc != 0 {
            s.push_str(&calling_conv(*cc));
            s.push(' ');
        }
        if let Some(r) = attrs.get(&0).filter(|a| !a.is_empty()) {
            s.push_str(&join(r, false));
            s.push(' ');
        }
        self.write_ty(s, *ret);
        s.push(' ');
        self.bare(s, None, id, v, ptr_ty)?;
        s.push('(');
        for (i, param) in params.iter().enumerate() {
            if i > 0 {
                s.push_str(", ");
            }
            self.write_ty(s, *param);
            let slot = u64::try_from(i).unwrap_or(u64::MAX).saturating_add(1);
            if let Some(a) = attrs.get(&slot).filter(|a| !a.is_empty()) {
                s.push(' ');
                s.push_str(&join(a, false));
            }
            if let Some(l) = &local
                && let Some(name) = l.names.get(&l.f.first.saturating_add(i))
            {
                s.push(' ');
                llvm_name(s, name, "%");
            }
        }
        if *vararg {
            if !params.is_empty() {
                s.push_str(", ");
            }
            s.push_str("...");
        }
        s.push(')');
        if p.unnamed_addr {
            s.push_str(" unnamed_addr");
        }
        if let Some(n) = self.attribute_group(&attrs) {
            let _ = write!(s, " #{n}");
        }
        if let Some(section) = &p.section {
            s.push_str(" section \"");
            escaped(s, section.as_bytes());
            s.push('"');
        }
        if p.alignment != 0 {
            let _ = write!(s, " align {}", p.alignment);
        }
        if let Some(gc) = gc {
            let _ = write!(s, " gc \"{gc}\"");
        }
        let Some(l) = local else {
            s.push('\n');
            return Ok(());
        };
        self.attachments(s, &l.f.attachments, " ");
        s.push_str(" {");
        for (b, insts) in l.blocks.iter().enumerate() {
            self.basic_block(s, &l, b, insts)?;
        }
        s.push_str("}\n");
        Ok(())
    }

    /// `AssemblyWriter::printBasicBlock`.
    fn basic_block(&self, s: &mut String, l: &Local<'m>, b: usize, insts: &[&Instruction]) -> Result<()> {
        let preds = l.preds.get(b).map_or(&[][..], Vec::as_slice);
        if let Some(name) = l.block_names.get(&b) {
            s.push('\n');
            llvm_name(s, name, "");
            s.push(':');
        } else if !preds.is_empty() {
            s.push_str("\n; <label>:");
            match l.block_slots.get(&b) {
                Some(n) => {
                    let _ = write!(s, "{n}");
                }
                None => s.push_str("<badref>"),
            }
        }
        if b != 0 {
            pad_to(s, 50);
            s.push(';');
            if preds.is_empty() {
                s.push_str(" No predecessors!");
            } else {
                s.push_str(" preds = ");
                for (i, p) in preds.iter().enumerate() {
                    if i > 0 {
                        s.push_str(", ");
                    }
                    self.block(s, l, *p, false);
                }
            }
        }
        s.push('\n');
        for inst in insts {
            self.instruction(s, l, inst)?;
            s.push('\n');
        }
        Ok(())
    }

    /// Operands the way an instruction without a form of its own lists them: the type once where they share it,
    /// otherwise before each.
    fn plain(&self, s: &mut String, l: &Local<'m>, operands: &[ValueId], all_types: bool) -> Result<()> {
        let mut types = Vec::with_capacity(operands.len());
        for o in operands {
            types.push(self.lookup(Some(l), *o)?.1);
        }
        let all = all_types || types.windows(2).any(|w| w.first() != w.get(1));
        if !all && let Some(t) = types.first() {
            s.push(' ');
            self.write_ty(s, *t);
        }
        s.push(' ');
        for (i, o) in operands.iter().enumerate() {
            if i > 0 {
                s.push_str(", ");
            }
            self.operand(s, Some(l), *o, all)?;
        }
        Ok(())
    }

    /// `AssemblyWriter::printInstruction`, and dxc's comment after it.
    fn instruction(&self, s: &mut String, l: &Local<'m>, inst: &Instruction) -> Result<()> {
        s.push_str("  ");
        if let Some((id, ty)) = inst.result
            && !matches!(self.m.types.get(ty), Some(Type::Void))
        {
            match (l.names.get(&id), l.slots.get(&id)) {
                (Some(n), _) => llvm_name(s, n, "%"),
                (None, Some(n)) => {
                    let _ = write!(s, "%{n}");
                }
                (None, None) => s.push_str("<badref>"),
            }
            s.push_str(" = ");
        }
        let result_ty = inst.result.map(|(_, t)| t);
        match &inst.op {
            Op::Binary { op, lhs, rhs } => {
                let (_, lt) = self.lookup(Some(l), *lhs)?;
                let float = is_float(self.scalar(lt));
                s.push_str(binary_name(*op, float));
                if float {
                    fast_math(s, inst.flags);
                } else {
                    integer_flags(s, *op, inst.flags);
                }
                self.plain(s, l, &[*lhs, *rhs], false)?;
            }
            Op::Compare {
                predicate: p,
                lhs,
                rhs,
            } => {
                let float = *p < 32;
                s.push_str(if float { "fcmp" } else { "icmp" });
                if float {
                    fast_math(s, inst.flags);
                }
                s.push(' ');
                s.push_str(predicate(*p));
                self.plain(s, l, &[*lhs, *rhs], false)?;
            }
            Op::Cast { op, value } => {
                s.push_str(cast_name(*op));
                s.push(' ');
                self.operand(s, Some(l), *value, true)?;
                s.push_str(" to ");
                if let Some(t) = result_ty {
                    self.write_ty(s, t);
                }
            }
            Op::Select {
                condition,
                then,
                otherwise,
            } => {
                s.push_str("select");
                self.plain(s, l, &[*condition, *then, *otherwise], true)?;
            }
            Op::ExtractValue { aggregate, indices } => {
                s.push_str("extractvalue ");
                self.operand(s, Some(l), *aggregate, true)?;
                for i in indices {
                    let _ = write!(s, ", {i}");
                }
            }
            Op::InsertValue {
                aggregate,
                value,
                indices,
            } => {
                s.push_str("insertvalue ");
                self.operand(s, Some(l), *aggregate, true)?;
                s.push_str(", ");
                self.operand(s, Some(l), *value, true)?;
                for i in indices {
                    let _ = write!(s, ", {i}");
                }
            }
            Op::ExtractElement { vector, index } => {
                s.push_str("extractelement");
                self.plain(s, l, &[*vector, *index], false)?;
            }
            Op::InsertElement { vector, value, index } => {
                s.push_str("insertelement");
                self.plain(s, l, &[*vector, *value, *index], false)?;
            }
            Op::ShuffleVector { first, second, mask } => {
                s.push_str("shufflevector");
                self.plain(s, l, &[*first, *second, *mask], true)?;
            }
            Op::Call {
                function,
                args,
                attributes,
                calling_conv: cc,
                tail,
            } => self.call(s, l, inst, *function, args, *attributes, *cc, *tail)?,
            Op::Phi { incoming } => {
                s.push_str("phi ");
                if let Some(t) = result_ty {
                    self.write_ty(s, t);
                }
                s.push(' ');
                for (i, (v, b)) in incoming.iter().enumerate() {
                    if i > 0 {
                        s.push_str(", ");
                    }
                    s.push_str("[ ");
                    self.operand(s, Some(l), *v, false)?;
                    s.push_str(", ");
                    self.block(s, l, *b, false);
                    s.push_str(" ]");
                }
            }
            Op::Return(None) => s.push_str("ret void"),
            Op::Return(Some(v)) => {
                s.push_str("ret ");
                self.operand(s, Some(l), *v, true)?;
            }
            Op::Branch { target } => {
                s.push_str("br ");
                self.block(s, l, *target, true);
            }
            Op::CondBranch {
                condition,
                then,
                otherwise,
            } => {
                s.push_str("br ");
                self.operand(s, Some(l), *condition, true)?;
                s.push_str(", ");
                self.block(s, l, *then, true);
                s.push_str(", ");
                self.block(s, l, *otherwise, true);
            }
            Op::Switch {
                value,
                default,
                cases,
            } => {
                s.push_str("switch ");
                self.operand(s, Some(l), *value, true)?;
                s.push_str(", ");
                self.block(s, l, *default, true);
                s.push_str(" [");
                for (c, b) in cases {
                    s.push_str("\n    ");
                    self.operand(s, Some(l), *c, true)?;
                    s.push_str(", ");
                    self.block(s, l, *b, true);
                }
                s.push_str("\n  ]");
            }
            Op::Unreachable => s.push_str("unreachable"),
            Op::Alloca {
                ty,
                size,
                align,
                inalloca,
            } => {
                s.push_str("alloca ");
                if *inalloca {
                    s.push_str("inalloca ");
                }
                self.write_ty(s, *ty);
                let (v, size_ty) = self.lookup(Some(l), *size)?;
                let one = matches!(v, Value::Constant(Constant::Integer(1)));
                if !one || !matches!(self.m.types.get(size_ty), Some(Type::Integer(32))) {
                    s.push_str(", ");
                    self.operand(s, Some(l), *size, true)?;
                }
                if *align != 0 {
                    let _ = write!(s, ", align {align}");
                }
            }
            Op::Load {
                pointer,
                align,
                volatile,
                atomic,
            } => {
                s.push_str("load");
                if atomic.is_some() {
                    s.push_str(" atomic");
                }
                if *volatile {
                    s.push_str(" volatile");
                }
                s.push(' ');
                if let Some(t) = result_ty {
                    self.write_ty(s, t);
                }
                s.push_str(", ");
                self.operand(s, Some(l), *pointer, true)?;
                if let Some(a) = atomic {
                    atomic_text(s, *a);
                }
                if *align != 0 {
                    let _ = write!(s, ", align {align}");
                }
            }
            Op::Store {
                pointer,
                value,
                align,
                volatile,
                atomic,
            } => {
                s.push_str("store");
                if atomic.is_some() {
                    s.push_str(" atomic");
                }
                if *volatile {
                    s.push_str(" volatile");
                }
                self.plain(s, l, &[*value, *pointer], true)?;
                if let Some(a) = atomic {
                    atomic_text(s, *a);
                }
                if *align != 0 {
                    let _ = write!(s, ", align {align}");
                }
            }
            Op::Gep {
                base,
                indices,
                source,
                inbounds,
            } => {
                s.push_str("getelementptr");
                if *inbounds {
                    s.push_str(" inbounds");
                }
                s.push(' ');
                self.write_ty(s, *source);
                s.push(',');
                let operands: Vec<ValueId> = std::iter::once(*base).chain(indices.iter().copied()).collect();
                self.plain(s, l, &operands, false)?;
            }
            Op::AtomicRmw {
                pointer,
                value,
                op,
                volatile,
                atomic,
            } => {
                s.push_str("atomicrmw");
                if *volatile {
                    s.push_str(" volatile");
                }
                s.push_str(&rmw_name(*op));
                self.plain(s, l, &[*pointer, *value], false)?;
                atomic_text(s, *atomic);
            }
            Op::CmpXchg {
                pointer,
                compare,
                value,
                volatile,
                weak,
                success,
                failure,
            } => {
                s.push_str("cmpxchg");
                if *weak {
                    s.push_str(" weak");
                }
                if *volatile {
                    s.push_str(" volatile");
                }
                self.plain(s, l, &[*pointer, *compare, *value], false)?;
                if success.single_thread {
                    s.push_str(" singlethread");
                }
                s.push_str(ordering_name(success.ordering));
                s.push_str(ordering_name(*failure));
            }
            Op::Fence(atomic) => {
                s.push_str("fence");
                atomic_text(s, *atomic);
            }
        }
        // `getAllMetadata`: the location first (kind `dbg`), then the attachments
        if let Some(n) = self.location_node(inst.debug_loc) {
            s.push_str(", !dbg ");
            self.md_ref(s, n);
        }
        self.attachments(s, &inst.attachments, ", ");
        self.debug_comment(s, l, inst)?;
        if let Op::Call { function, args, .. } = &inst.op {
            self.dx_op_comment(s, l, *function, args)?;
        }
        Ok(())
    }

    /// dxc's `printInfoComment`: after a call of a `dx.op.` function whose first argument is a constant integer, the
    /// operation's name and operands (and an `annotateHandle`'s resource).
    fn dx_op_comment(
        &self,
        s: &mut String,
        l: &Local<'m>,
        function: ValueId,
        args: &[ValueId],
    ) -> Result<()> {
        let Some(first) = args.first() else { return Ok(()) };
        if !matches!(self.m.values.get(function), Some(Value::Function { .. }))
            || !self.names.get(&function).is_some_and(|n| n.starts_with("dx.op."))
        {
            return Ok(());
        }
        let (v, t) = self.lookup(Some(l), *first)?;
        let opcode = match (v, self.m.types.get(t)) {
            (Value::Constant(Constant::Integer(v)), Some(Type::Integer(w))) => zero_extended(*v, *w),
            (Value::Constant(Constant::Null), Some(Type::Integer(_))) => 0,
            _ => return Ok(()),
        };
        // AnnotateHandle(res, props): its properties, where they are a constant
        let properties = match args.get(2) {
            Some(props) if opcode == 216 => self.properties(l, *props)?,
            _ => None,
        };
        s.push_str(&annotate::comment(opcode, properties));
        Ok(())
    }

    /// The two dwords of a constant `%dx.types.ResourceProperties` (`loadPropsFromConstant`).
    fn properties(&self, l: &Local<'m>, id: ValueId) -> Result<Option<[u32; 2]>> {
        let (v, _) = self.lookup(Some(l), id)?;
        let Value::Constant(c) = v else { return Ok(None) };
        let dword = |id: ValueId| -> Result<u32> {
            match self.lookup(Some(l), id)?.0 {
                Value::Constant(Constant::Integer(v)) => Ok((*v as u64 & 0xFFFF_FFFF) as u32),
                Value::Constant(Constant::Null) => Ok(0),
                _ => Err(error(
                    self.m.at,
                    "resource properties that are not constant integers",
                )),
            }
        };
        match c {
            Constant::Null => Ok(Some([0, 0])),
            Constant::Aggregate(ids) if self.is_null(Some(l), id)? => {
                let _ = ids;
                Ok(Some([0, 0]))
            }
            Constant::Aggregate(ids) => match ids.as_slice() {
                [a, b] => Ok(Some([dword(*a)?, dword(*b)?])),
                _ => Err(error(self.m.at, "resource properties that are not two dwords")),
            },
            _ => Err(error(
                self.m.at,
                "resource properties of a constant dxc does not read",
            )),
        }
    }

    /// A call.
    #[allow(clippy::too_many_arguments)]
    fn call(
        &self,
        s: &mut String,
        l: &Local<'m>,
        inst: &Instruction,
        function: ValueId,
        args: &[ValueId],
        attributes: Option<usize>,
        cc: u64,
        tail: TailCall,
    ) -> Result<()> {
        match tail {
            TailCall::MustTail => s.push_str("musttail "),
            TailCall::Tail => s.push_str("tail "),
            TailCall::None => {}
        }
        s.push_str("call");
        if cc != 0 {
            s.push(' ');
            s.push_str(&calling_conv(cc));
        }
        let attrs = self.attributes(attributes)?;
        if let Some(r) = attrs.get(&0).filter(|a| !a.is_empty()) {
            s.push(' ');
            s.push_str(&join(r, false));
        }
        let (callee, callee_ty) = self.lookup(Some(l), function)?;
        let fty = match self.m.types.get(callee_ty) {
            Some(Type::Pointer(to, _)) => *to,
            _ => return Err(error(inst.at, "a call of a value that is not a function pointer")),
        };
        let Some(Type::Function { vararg, ret, .. }) = self.m.types.get(fty) else {
            return Err(error(inst.at, "a call of a value that is not a function pointer"));
        };
        s.push(' ');
        self.write_ty(s, if *vararg { fty } else { *ret });
        s.push(' ');
        self.bare(s, Some(l), function, callee, callee_ty)?;
        s.push('(');
        for (i, a) in args.iter().enumerate() {
            if i > 0 {
                s.push_str(", ");
            }
            let (v, t) = self.lookup(Some(l), *a)?;
            self.write_ty(s, t);
            let slot = u64::try_from(i).unwrap_or(u64::MAX).saturating_add(1);
            if let Some(pa) = attrs.get(&slot).filter(|a| !a.is_empty()) {
                s.push(' ');
                s.push_str(&join(pa, false));
            }
            s.push(' ');
            self.bare(s, Some(l), *a, v, t)?;
        }
        s.push(')');
        if let Some(n) = self.attribute_group(&attrs) {
            let _ = write!(s, " #{n}");
        }
        Ok(())
    }
}

/// LLVM's `TypeFinder::run`: the struct types in the order it meets them, through the globals, the functions' bodies
/// (each instruction's type, its constant operands and the metadata attached), then the named metadata.
struct Finder<'w, 'm> {
    w: &'w Writer<'m>,
    types: HashSet<TypeId>,
    /// Constants visited: module values by id, a body's own by (its function value, id).
    values: HashSet<(Option<ValueId>, ValueId)>,
    metadata: HashSet<MetadataId>,
    structs: Vec<TypeId>,
}

impl<'w, 'm> Finder<'w, 'm> {
    fn new(w: &'w Writer<'m>) -> Self {
        Finder {
            w,
            types: HashSet::new(),
            values: HashSet::new(),
            metadata: HashSet::new(),
            structs: Vec::new(),
        }
    }

    fn run(mut self) -> Vec<TypeId> {
        let m = self.w.m;
        for (id, v) in m.values.iter().enumerate() {
            if let Value::Global { init, .. } = v {
                if let Some(t) = m.value_types.get(id) {
                    self.ty(*t);
                }
                if let Some(init) = init {
                    self.value(None, *init);
                }
            }
        }
        for (id, v) in m.values.iter().enumerate() {
            let Value::Function { .. } = v else { continue };
            if let Some(t) = m.value_types.get(id) {
                self.ty(*t);
            }
            let Some(body) = self.w.bodies.get(&id).copied() else {
                continue;
            };
            for inst in &body.instructions {
                if let Some((_, t)) = inst.result {
                    self.ty(t);
                }
                for v in llvm_operands(&inst.op) {
                    self.value(Some(body), v);
                }
                for node in self.w.sorted_attachments(&inst.attachments) {
                    self.node(node);
                }
            }
        }
        for (_, nodes) in &m.named_metadata {
            for n in nodes {
                self.node(*n);
            }
        }
        self.structs
    }

    /// `incorporateType`: a type and its subtypes, depth first, each once.
    fn ty(&mut self, t: TypeId) {
        if !self.types.insert(t) {
            return;
        }
        let m = self.w.m;
        let mut stack = vec![t];
        while let Some(t) = stack.pop() {
            let subtypes: Vec<TypeId> = match m.types.get(t) {
                Some(Type::Struct { elements, .. }) => {
                    self.structs.push(t);
                    elements.clone()
                }
                Some(Type::Opaque(_)) => {
                    self.structs.push(t);
                    Vec::new()
                }
                Some(Type::Pointer(to, _) | Type::Array(_, to) | Type::Vector(_, to)) => vec![*to],
                Some(Type::Function { ret, params, .. }) => {
                    std::iter::once(*ret).chain(params.iter().copied()).collect()
                }
                _ => Vec::new(),
            };
            for s in subtypes.into_iter().rev() {
                if self.types.insert(s) {
                    stack.push(s);
                }
            }
        }
    }

    /// `incorporateValue`: a constant's type and its operands' (not a global value's).
    fn value(&mut self, body: Option<&Function>, id: ValueId) {
        let m = self.w.m;
        let (value, ty, key) = match body {
            Some(f) if id >= f.first => {
                let i = id.saturating_sub(f.first);
                (f.locals.get(i), f.local_types.get(i), (Some(f.value), id))
            }
            _ => (m.values.get(id), m.value_types.get(id), (None, id)),
        };
        // `incorporateValue` of a `MetadataAsValue`: the node, or the value a module's value-as-metadata is
        if let Some(Value::Metadata(md)) = value {
            if body.is_some_and(|f| *md >= f.first_metadata) {
                return;
            }
            match m.metadata.get(*md) {
                Some(Metadata::Value { value, .. }) => self.value(None, *value),
                Some(Metadata::Node(_) | Metadata::Distinct(_) | Metadata::Debug { .. }) => self.node(*md),
                _ => {}
            }
            return;
        }
        let (Some(Value::Constant(c)), Some(ty)) = (value, ty) else {
            return;
        };
        if !self.values.insert(key) {
            return;
        }
        self.ty(*ty);
        let operands: Vec<ValueId> = match c {
            Constant::Aggregate(ids) => ids.clone(),
            Constant::Gep { base, indices, .. } => {
                std::iter::once(*base).chain(indices.iter().copied()).collect()
            }
            Constant::Cast { value, .. } => vec![*value],
            Constant::Binary { lhs, rhs, .. } | Constant::Compare { lhs, rhs, .. } => vec![*lhs, *rhs],
            _ => Vec::new(),
        };
        for o in operands {
            self.value(body, o);
        }
    }

    /// `incorporateMDNode`: the constants a node's operands hold, through the nodes it names.
    fn node(&mut self, node: MetadataId) {
        if !self.metadata.insert(node) {
            return;
        }
        let m = self.w.m;
        let Some(ops) = self.w.node_operands(Node::Metadata(node)) else {
            return;
        };
        for op in ops.iter().flatten() {
            match m.metadata.get(*op) {
                Some(Metadata::Node(_) | Metadata::Distinct(_) | Metadata::Debug { .. }) => self.node(*op),
                Some(Metadata::Value { value, .. }) => self.value(None, *value),
                _ => {}
            }
        }
    }
}

/// An instruction's value operands in LLVM's operand order (a call's callee last, a store's value before its pointer,
/// a conditional branch's condition first).
fn llvm_operands(op: &Op) -> Vec<ValueId> {
    match op {
        Op::Call { function, args, .. } => args.iter().copied().chain(std::iter::once(*function)).collect(),
        Op::Store { pointer, value, .. } => vec![*value, *pointer],
        _ => op.operands(),
    }
}

/// `PrintLLVMName`: a name with its prefix, quoted (with `\XX` escapes) where it is not all letters, digits, `-`, `.`
/// and `_`, or starts with a digit.
fn llvm_name(s: &mut String, name: &str, prefix: &str) {
    s.push_str(prefix);
    let bytes = name.as_bytes();
    let plain = !bytes.first().is_some_and(u8::is_ascii_digit)
        && bytes
            .iter()
            .all(|c| c.is_ascii_alphanumeric() || matches!(c, b'-' | b'.' | b'_'));
    if plain {
        s.push_str(name);
    } else {
        s.push('"');
        escaped(s, bytes);
        s.push('"');
    }
}

/// `PrintEscapedString`: printable ASCII but `\` and `"` as is, every other byte as `\XX`.
fn escaped(s: &mut String, bytes: &[u8]) {
    for &c in bytes {
        if (0x20..0x7F).contains(&c) && c != b'\\' && c != b'"' {
            s.push(char::from(c));
        } else {
            let _ = write!(s, "\\{c:02X}");
        }
    }
}

/// `printMetadataIdentifier`: a kind or named-metadata name, with `\XX` for the characters an identifier lacks.
fn md_identifier(s: &mut String, name: &str) {
    for (i, &c) in name.as_bytes().iter().enumerate() {
        let ok = if i == 0 {
            c.is_ascii_alphabetic() || matches!(c, b'-' | b'$' | b'.' | b'_')
        } else {
            c.is_ascii_alphanumeric() || matches!(c, b'-' | b'$' | b'.' | b'_')
        };
        if ok {
            s.push(char::from(c));
        } else {
            let _ = write!(s, "\\{c:02X}");
        }
    }
    if name.is_empty() {
        s.push_str("<empty name> ");
    }
}

/// `formatted_raw_ostream::PadToColumn`: spaces to `column`, at least one.
fn pad_to(s: &mut String, column: usize) {
    let line = s.rfind('\n').map_or(0, |p| p.saturating_add(1));
    let mut col = 0usize;
    for &c in s.as_bytes().get(line..).unwrap_or_default() {
        col = col.saturating_add(1);
        if c == b'\t' {
            col = col.saturating_add(8usize.wrapping_sub(col & 7) & 7);
        }
    }
    let n = column.saturating_sub(col).max(1);
    s.extend(std::iter::repeat_n(' ', n));
}

/// A double as `raw_ostream << double` writes it (`%e`), where that reads back as the same value.
fn exponent_form(v: f64) -> Option<String> {
    let text = format!("{v:.6e}");
    let (mantissa, exp) = text.split_once('e')?;
    let exp: i32 = exp.parse().ok()?;
    let sign = if exp < 0 { '-' } else { '+' };
    let s = format!("{mantissa}e{sign}{:02}", exp.unsigned_abs());
    let first = s.as_bytes();
    let digit_start = matches!(first.first(), Some(b'-' | b'+'));
    if !first
        .get(usize::from(digit_start))
        .is_some_and(u8::is_ascii_digit)
    {
        return None;
    }
    (s.parse::<f64>().ok()? == v).then_some(s)
}

/// A float constant's text: `%e` where it reads back exactly, otherwise the bits of the double it widens to, in hex;
/// a half as `0xH` and its bits.
fn float_text(ty: Option<&Type>, bits: u64) -> String {
    match ty {
        Some(Type::Half) => format!("0xH{:04X}", bits & 0xFFFF),
        Some(Type::Float) => {
            let f = f32::from_bits((bits & 0xFFFF_FFFF) as u32);
            let d = if f.is_nan() {
                // APFloat widens a NaN's payload by shifting it, keeping its sign
                let b = f.to_bits();
                f64::from_bits((u64::from(b >> 31) << 63) | (0x7FF << 52) | (u64::from(b & 0x7F_FFFF) << 29))
            } else {
                f64::from(f)
            };
            double_text(d)
        }
        _ => double_text(f64::from_bits(bits)),
    }
}

fn double_text(d: f64) -> String {
    if d.is_finite()
        && let Some(s) = exponent_form(d)
    {
        return s;
    }
    format!("0x{:X}", d.to_bits())
}

/// A float constant's bits as its type holds them.
fn float_bits(ty: Option<&Type>, bits: u64) -> u64 {
    match ty {
        Some(Type::Half) => bits & 0xFFFF,
        Some(Type::Float) => bits & 0xFFFF_FFFF,
        _ => bits,
    }
}

/// An integer constant's value, zero-extended from its width (`getZExtValue`).
fn zero_extended(v: i64, width: u32) -> u64 {
    let bits = u64::from_ne_bytes(v.to_ne_bytes());
    match width {
        0 | 64.. => bits,
        w => bits & 1u64.wrapping_shl(w).wrapping_sub(1),
    }
}

/// `nuw` and `nsw` of an integer `add`, `sub`, `mul` or `shl`, `exact` of a `udiv`, `sdiv`, `lshr` or `ashr`.
fn integer_flags(s: &mut String, op: BinaryOp, flags: u64) {
    match op {
        BinaryOp::Add | BinaryOp::Sub | BinaryOp::Mul | BinaryOp::Shl => {
            if flags & 1 != 0 {
                s.push_str(" nuw");
            }
            if flags & 2 != 0 {
                s.push_str(" nsw");
            }
        }
        BinaryOp::UDiv | BinaryOp::SDiv | BinaryOp::LShr | BinaryOp::AShr if flags & 1 != 0 => {
            s.push_str(" exact")
        }
        _ => {}
    }
}

/// The fast-math flags of a float operation: `fast`, which implies the others, or each of them.
fn fast_math(s: &mut String, flags: u64) {
    if flags & 1 != 0 {
        s.push_str(" fast");
        return;
    }
    for (bit, name) in [(2, " nnan"), (4, " ninf"), (8, " nsz"), (16, " arcp")] {
        if flags & bit != 0 {
            s.push_str(name);
        }
    }
}

/// An integer's value, sign-extended from its width.
fn signed(v: i64, width: u32) -> i64 {
    if width >= 64 || width == 0 {
        v
    } else {
        let shift = 64u32.wrapping_sub(width);
        v.wrapping_shl(shift).wrapping_shr(shift)
    }
}

fn binary_name(op: BinaryOp, float: bool) -> &'static str {
    match (op, float) {
        (BinaryOp::Add, false) => "add",
        (BinaryOp::Add, true) => "fadd",
        (BinaryOp::Sub, false) => "sub",
        (BinaryOp::Sub, true) => "fsub",
        (BinaryOp::Mul, false) => "mul",
        (BinaryOp::Mul, true) => "fmul",
        (BinaryOp::UDiv, _) => "udiv",
        (BinaryOp::SDiv, false) => "sdiv",
        (BinaryOp::SDiv, true) => "fdiv",
        (BinaryOp::URem, _) => "urem",
        (BinaryOp::SRem, false) => "srem",
        (BinaryOp::SRem, true) => "frem",
        (BinaryOp::Shl, _) => "shl",
        (BinaryOp::LShr, _) => "lshr",
        (BinaryOp::AShr, _) => "ashr",
        (BinaryOp::And, _) => "and",
        (BinaryOp::Or, _) => "or",
        (BinaryOp::Xor, _) => "xor",
    }
}

fn cast_name(op: CastOp) -> &'static str {
    match op {
        CastOp::Trunc => "trunc",
        CastOp::ZExt => "zext",
        CastOp::SExt => "sext",
        CastOp::FpToUi => "fptoui",
        CastOp::FpToSi => "fptosi",
        CastOp::UiToFp => "uitofp",
        CastOp::SiToFp => "sitofp",
        CastOp::FpTrunc => "fptrunc",
        CastOp::FpExt => "fpext",
        CastOp::PtrToInt => "ptrtoint",
        CastOp::IntToPtr => "inttoptr",
        CastOp::BitCast => "bitcast",
        CastOp::AddrSpaceCast => "addrspacecast",
    }
}

/// `getPredicateText`.
fn predicate(p: u64) -> &'static str {
    match p {
        0 => "false",
        1 => "oeq",
        2 => "ogt",
        3 => "oge",
        4 => "olt",
        5 => "ole",
        6 => "one",
        7 => "ord",
        8 => "uno",
        9 => "ueq",
        10 => "ugt",
        11 => "uge",
        12 => "ult",
        13 => "ule",
        14 => "une",
        15 => "true",
        32 => "eq",
        33 => "ne",
        34 => "ugt",
        35 => "uge",
        36 => "ult",
        37 => "ule",
        38 => "sgt",
        39 => "sge",
        40 => "slt",
        41 => "sle",
        _ => "unknown",
    }
}

fn ordering_name(o: Ordering) -> &'static str {
    match o {
        Ordering::NotAtomic => "",
        Ordering::Unordered => " unordered",
        Ordering::Monotonic => " monotonic",
        Ordering::Acquire => " acquire",
        Ordering::Release => " release",
        Ordering::AcquireRelease => " acq_rel",
        Ordering::SequentiallyConsistent => " seq_cst",
    }
}

/// `writeAtomic`.
fn atomic_text(s: &mut String, a: Atomic) {
    if a.ordering == Ordering::NotAtomic {
        return;
    }
    if a.single_thread {
        s.push_str(" singlethread");
    }
    s.push_str(ordering_name(a.ordering));
}

/// `writeAtomicRMWOperation`.
fn rmw_name(op: u64) -> String {
    match op {
        0 => " xchg".to_owned(),
        1 => " add".to_owned(),
        2 => " sub".to_owned(),
        3 => " and".to_owned(),
        4 => " nand".to_owned(),
        5 => " or".to_owned(),
        6 => " xor".to_owned(),
        7 => " max".to_owned(),
        8 => " min".to_owned(),
        9 => " umax".to_owned(),
        10 => " umin".to_owned(),
        other => format!(" <unknown operation {other}>"),
    }
}

/// `PrintCallingConv`.
fn calling_conv(cc: u64) -> String {
    match cc {
        8 => "fastcc".to_owned(),
        9 => "coldcc".to_owned(),
        10 => "ghccc".to_owned(),
        12 => "webkit_jscc".to_owned(),
        13 => "anyregcc".to_owned(),
        14 => "preserve_mostcc".to_owned(),
        15 => "preserve_allcc".to_owned(),
        64 => "x86_stdcallcc".to_owned(),
        65 => "x86_fastcallcc".to_owned(),
        66 => "arm_apcscc".to_owned(),
        67 => "arm_aapcscc".to_owned(),
        68 => "arm_aapcs_vfpcc".to_owned(),
        69 => "msp430_intrcc".to_owned(),
        70 => "x86_thiscallcc".to_owned(),
        71 => "ptx_kernel".to_owned(),
        72 => "ptx_device".to_owned(),
        75 => "spir_func".to_owned(),
        76 => "spir_kernel".to_owned(),
        77 => "intel_ocl_bicc".to_owned(),
        78 => "x86_64_sysvcc".to_owned(),
        79 => "x86_64_win64cc".to_owned(),
        80 => "x86_vectorcallcc".to_owned(),
        other => format!("cc{other}"),
    }
}

fn linkage_text(l: Linkage) -> &'static str {
    match l {
        Linkage::External => "",
        Linkage::Private => "private ",
        Linkage::Internal => "internal ",
        Linkage::LinkOnceAny => "linkonce ",
        Linkage::LinkOnceOdr => "linkonce_odr ",
        Linkage::WeakAny => "weak ",
        Linkage::WeakOdr => "weak_odr ",
        Linkage::Common => "common ",
        Linkage::Appending => "appending ",
        Linkage::ExternWeak => "extern_weak ",
        Linkage::AvailableExternally => "available_externally ",
    }
}

fn visibility_text(v: u8) -> &'static str {
    match v {
        1 => "hidden ",
        2 => "protected ",
        _ => "",
    }
}

fn dll_text(v: u8) -> &'static str {
    match v {
        1 => "dllimport ",
        2 => "dllexport ",
        _ => "",
    }
}

fn thread_local_text(v: u8) -> &'static str {
    match v {
        1 => "thread_local ",
        2 => "thread_local(localdynamic) ",
        3 => "thread_local(initialexec) ",
        4 => "thread_local(localexec) ",
        _ => "",
    }
}

fn is_float(t: Option<&Type>) -> bool {
    matches!(t, Some(Type::Half | Type::Float | Type::Double))
}

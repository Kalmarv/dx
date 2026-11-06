//! Debug information in the listing: LLVM 3.7's `DI*` nodes as `AsmWriter.cpp` writes them (`writeDILocation` and the
//! others, through its `MDFieldPrinter`), and dxc's comment after an instruction of a program with debug information
//! (`DxcAssemblyAnnotationWriter::printInfoComment`: the source line, or a debug intrinsic's variable).
use std::fmt::Write as _;

use super::{Local, Node, Writer, escaped};
use crate::debug_info::{DebugLoc, DebugNode};
use crate::dwarf;
use crate::module::{Instruction, Metadata, MetadataId, Op, Value};
use crate::{Result, error};

const DW_TAG_BASE_TYPE: u32 = 0x24;
const DW_TAG_TEMPLATE_VALUE_PARAMETER: u32 = 0x30;
const DW_TAG_AUTO_VARIABLE: u32 = 0x100;
const DW_OP_DEREF: u64 = 0x06;
const DW_OP_PLUS: u64 = 0x22;
const DW_OP_BIT_PIECE: u64 = 0x9d;

/// The `DIFlag*` bits after the accessibility pair, in the order `DINode::splitFlags` takes them
/// (`DebugInfoFlags.def`).
const FLAGS: [(u32, &str); 13] = [
    (1 << 2, "DIFlagFwdDecl"),
    (1 << 3, "DIFlagAppleBlock"),
    (1 << 4, "DIFlagBlockByrefStruct"),
    (1 << 5, "DIFlagVirtual"),
    (1 << 6, "DIFlagArtificial"),
    (1 << 7, "DIFlagExplicit"),
    (1 << 8, "DIFlagPrototyped"),
    (1 << 9, "DIFlagObjcClassComplete"),
    (1 << 10, "DIFlagObjectPointer"),
    (1 << 11, "DIFlagVector"),
    (1 << 12, "DIFlagStaticMember"),
    (1 << 13, "DIFlagLValueReference"),
    (1 << 14, "DIFlagRValueReference"),
];

/// `MDFieldPrinter`: a node's fields, `, ` between them.
struct Fields<'w, 'm, 's> {
    w: &'w Writer<'m>,
    s: &'s mut String,
    first: bool,
}

impl Fields<'_, '_, '_> {
    fn separator(&mut self) {
        if !self.first {
            self.s.push_str(", ");
        }
        self.first = false;
    }

    /// `printTag`.
    fn tag(&mut self, tag: u32) {
        self.separator();
        self.s.push_str("tag: ");
        match dwarf::tag(u64::from(tag)) {
            Some(name) => self.s.push_str(name),
            None => {
                let _ = write!(self.s, "{tag}");
            }
        }
    }

    /// `printString`: the text of a metadata string (empty for none), left out where empty unless `always`.
    fn string(&mut self, name: &str, id: Option<MetadataId>, always: bool) -> Result<()> {
        let text: &[u8] = match id {
            None => &[],
            Some(id) => match self.w.m.metadata.get(id) {
                Some(Metadata::String(bytes)) => bytes,
                _ => {
                    return Err(error(
                        self.w.m.at,
                        format!("the {name} of a debug node is not a string"),
                    ));
                }
            },
        };
        if text.is_empty() && !always {
            return Ok(());
        }
        self.separator();
        let _ = write!(self.s, "{name}: \"");
        escaped(self.s, text);
        self.s.push('"');
        Ok(())
    }

    /// `printMetadata`: a reference, left out where null unless `always` (which writes `null`).
    fn metadata(&mut self, name: &str, id: Option<MetadataId>, always: bool) -> Result<()> {
        if id.is_none() && !always {
            return Ok(());
        }
        self.separator();
        let _ = write!(self.s, "{name}: ");
        self.w.md_operand(self.s, id)
    }

    /// `printInt`: left out where zero unless `always`.
    fn int<T: std::fmt::Display + Default + PartialEq>(&mut self, name: &str, value: T, always: bool) {
        if value == T::default() && !always {
            return;
        }
        self.separator();
        let _ = write!(self.s, "{name}: {value}");
    }

    /// `printBool`.
    fn boolean(&mut self, name: &str, value: bool) {
        self.separator();
        let _ = write!(self.s, "{name}: {value}");
    }

    /// `printDIFlags`: the accessibility, then each other flag by name, `|` between them, and any bits left over.
    fn flags(&mut self, name: &str, flags: u32) {
        if flags == 0 {
            return;
        }
        self.separator();
        let _ = write!(self.s, "{name}: ");
        let mut split: Vec<&str> = Vec::new();
        let mut rest = flags;
        match rest & 3 {
            0 => {}
            1 => split.push("DIFlagPrivate"),
            2 => split.push("DIFlagProtected"),
            _ => split.push("DIFlagPublic"),
        }
        rest &= !3;
        for (bit, flag) in FLAGS {
            if rest & bit != 0 {
                split.push(flag);
                rest &= !bit;
            }
        }
        let mut parts: Vec<String> = split.into_iter().map(str::to_owned).collect();
        if rest != 0 || parts.is_empty() {
            parts.push(rest.to_string());
        }
        self.s.push_str(&parts.join(" | "));
    }

    /// `printDwarfEnum`: a DWARF constant by its name, left out where zero (whatever the caller asks: LLVM 3.7 tests
    /// the value before the flag).
    fn dwarf(&mut self, name: &str, value: u32, names: fn(u64) -> Option<&'static str>) {
        if value == 0 {
            return;
        }
        self.separator();
        let _ = write!(self.s, "{name}: ");
        match names(u64::from(value)) {
            Some(n) => self.s.push_str(n),
            None => {
                let _ = write!(self.s, "{value}");
            }
        }
    }
}

/// The operands of a location node in LLVM's order: its scope, then where it was inlined, if anywhere.
pub(super) fn location_operands(l: &DebugLoc) -> Vec<Option<MetadataId>> {
    let mut ops = vec![l.scope];
    if l.inlined_at.is_some() {
        ops.push(l.inlined_at);
    }
    ops
}

/// `DIExpression::isValid`: each operation is one LLVM 3.7 reads, with its arguments, and a bit piece is last.
fn valid_expression(elements: &[u64]) -> bool {
    let mut i = 0usize;
    while i < elements.len() {
        let op = elements.get(i).copied().unwrap_or(0);
        let size = match op {
            DW_OP_BIT_PIECE => 3,
            DW_OP_PLUS => 2,
            _ => 1,
        };
        if i.saturating_add(size) > elements.len() {
            return false;
        }
        match op {
            DW_OP_BIT_PIECE => return i.saturating_add(size) == elements.len(),
            DW_OP_PLUS | DW_OP_DEREF => {}
            _ => return false,
        }
        i = i.saturating_add(size);
    }
    true
}

/// `writeDIExpression`: each operation by name with its arguments, or, where the expression is not valid, its
/// elements as numbers.
pub(super) fn expression(s: &mut String, elements: &[u64]) {
    s.push_str("!DIExpression(");
    let mut parts: Vec<String> = Vec::new();
    if valid_expression(elements) {
        let mut i = 0usize;
        while let Some(&op) = elements.get(i) {
            parts.push(dwarf::operation(op).map_or_else(|| op.to_string(), str::to_owned));
            let args = match op {
                DW_OP_BIT_PIECE => 2,
                DW_OP_PLUS => 1,
                _ => 0,
            };
            for a in elements.iter().skip(i.saturating_add(1)).take(args) {
                parts.push(a.to_string());
            }
            i = i.saturating_add(1).saturating_add(args);
        }
    } else {
        parts.extend(elements.iter().map(u64::to_string));
    }
    s.push_str(&parts.join(", "));
    s.push(')');
}

impl<'m> Writer<'m> {
    /// `writeDILocation`.
    pub(super) fn location(&self, s: &mut String, l: &DebugLoc) -> Result<()> {
        s.push_str("!DILocation(");
        let mut p = Fields {
            w: self,
            s,
            first: true,
        };
        p.int("line", l.line, true);
        p.int("column", l.column, false);
        p.metadata("scope", l.scope, true)?;
        p.metadata("inlinedAt", l.inlined_at, false)?;
        s.push(')');
        Ok(())
    }

    /// `WriteMDNodeBodyInternal` for a debug node: `distinct ` where it is, then the node's fields.
    pub(super) fn debug_node(&self, s: &mut String, distinct: bool, node: &DebugNode) -> Result<()> {
        if distinct {
            s.push_str("distinct ");
        }
        use DebugNode as N;
        if let N::Location {
            line,
            column,
            scope,
            inlined_at,
        } = node
        {
            let l = DebugLoc {
                line: *line,
                column: *column,
                scope: Some(*scope),
                inlined_at: *inlined_at,
            };
            return self.location(s, &l);
        }
        if let N::Expression(elements) = node {
            expression(s, elements);
            return Ok(());
        }
        let class = match node {
            N::Location { .. } => "DILocation",
            N::Generic { .. } => "GenericDINode",
            N::Subrange { .. } => "DISubrange",
            N::Enumerator { .. } => "DIEnumerator",
            N::BasicType { .. } => "DIBasicType",
            N::DerivedType { .. } => "DIDerivedType",
            N::CompositeType { .. } => "DICompositeType",
            N::SubroutineType { .. } => "DISubroutineType",
            N::File { .. } => "DIFile",
            N::CompileUnit { .. } => "DICompileUnit",
            N::Subprogram { .. } => "DISubprogram",
            N::LexicalBlock { .. } => "DILexicalBlock",
            N::LexicalBlockFile { .. } => "DILexicalBlockFile",
            N::Namespace { .. } => "DINamespace",
            N::Module { .. } => "DIModule",
            N::TemplateType { .. } => "DITemplateTypeParameter",
            N::TemplateValue { .. } => "DITemplateValueParameter",
            N::GlobalVariable { .. } => "DIGlobalVariable",
            N::LocalVariable { .. } => "DILocalVariable",
            N::Expression(_) => "DIExpression",
            N::ObjcProperty { .. } => "DIObjCProperty",
            N::ImportedEntity { .. } => "DIImportedEntity",
        };
        let _ = write!(s, "!{class}(");
        let mut p = Fields {
            w: self,
            s,
            first: true,
        };
        match node {
            N::Location { .. } | N::Expression(_) => {}
            N::Generic {
                tag,
                header,
                operands,
            } => {
                p.tag(*tag);
                p.string("header", *header, false)?;
                if !operands.is_empty() {
                    p.separator();
                    p.s.push_str("operands: {");
                    for (i, op) in operands.iter().enumerate() {
                        if i > 0 {
                            p.s.push_str(", ");
                        }
                        self.md_operand(p.s, *op)?;
                    }
                    p.s.push('}');
                }
            }
            N::Subrange { count, lower_bound } => {
                p.int("count", *count, true);
                p.int("lowerBound", *lower_bound, false);
            }
            N::Enumerator { value, name } => {
                p.string("name", *name, true)?;
                p.int("value", *value, true);
            }
            N::BasicType {
                tag,
                name,
                size,
                align,
                encoding,
            } => {
                if *tag != DW_TAG_BASE_TYPE {
                    p.tag(*tag);
                }
                p.string("name", *name, false)?;
                p.int("size", *size, false);
                p.int("align", *align, false);
                p.dwarf("encoding", *encoding, dwarf::encoding);
            }
            N::DerivedType {
                tag,
                name,
                file,
                line,
                scope,
                base_type,
                size,
                align,
                offset,
                flags,
                extra_data,
            } => {
                p.tag(*tag);
                p.string("name", *name, false)?;
                p.metadata("scope", *scope, false)?;
                p.metadata("file", *file, false)?;
                p.int("line", *line, false);
                p.metadata("baseType", *base_type, true)?;
                p.int("size", *size, false);
                p.int("align", *align, false);
                p.int("offset", *offset, false);
                p.flags("flags", *flags);
                p.metadata("extraData", *extra_data, false)?;
            }
            N::CompositeType {
                tag,
                name,
                file,
                line,
                scope,
                base_type,
                size,
                align,
                offset,
                flags,
                elements,
                runtime_lang,
                vtable_holder,
                template_params,
                identifier,
            } => {
                p.tag(*tag);
                p.string("name", *name, false)?;
                p.metadata("scope", *scope, false)?;
                p.metadata("file", *file, false)?;
                p.int("line", *line, false);
                p.metadata("baseType", *base_type, false)?;
                p.int("size", *size, false);
                p.int("align", *align, false);
                p.int("offset", *offset, false);
                p.flags("flags", *flags);
                p.metadata("elements", *elements, false)?;
                p.dwarf("runtimeLang", *runtime_lang, dwarf::language);
                p.metadata("vtableHolder", *vtable_holder, false)?;
                p.metadata("templateParams", *template_params, false)?;
                p.string("identifier", *identifier, false)?;
            }
            N::SubroutineType { flags, types } => {
                p.flags("flags", *flags);
                p.metadata("types", *types, true)?;
            }
            N::File { filename, directory } => {
                p.string("filename", *filename, true)?;
                p.string("directory", *directory, true)?;
            }
            N::CompileUnit {
                language,
                file,
                producer,
                optimized,
                flags,
                runtime_version,
                split_debug_filename,
                emission_kind,
                enums,
                retained_types,
                subprograms,
                globals,
                imports,
                dwo_id,
            } => {
                p.dwarf("language", *language, dwarf::language);
                p.metadata("file", *file, true)?;
                p.string("producer", *producer, false)?;
                p.boolean("isOptimized", *optimized);
                p.string("flags", *flags, false)?;
                p.int("runtimeVersion", *runtime_version, true);
                p.string("splitDebugFilename", *split_debug_filename, false)?;
                p.int("emissionKind", *emission_kind, true);
                p.metadata("enums", *enums, false)?;
                p.metadata("retainedTypes", *retained_types, false)?;
                p.metadata("subprograms", *subprograms, false)?;
                p.metadata("globals", *globals, false)?;
                p.metadata("imports", *imports, false)?;
                p.int("dwoId", *dwo_id, false);
            }
            N::Subprogram {
                scope,
                name,
                linkage_name,
                file,
                line,
                ty,
                local,
                definition,
                scope_line,
                containing_type,
                virtuality,
                virtual_index,
                flags,
                optimized,
                function,
                template_params,
                declaration,
                variables,
            } => {
                p.string("name", *name, false)?;
                p.string("linkageName", *linkage_name, false)?;
                p.metadata("scope", *scope, true)?;
                p.metadata("file", *file, false)?;
                p.int("line", *line, false);
                p.metadata("type", *ty, false)?;
                p.boolean("isLocal", *local);
                p.boolean("isDefinition", *definition);
                p.int("scopeLine", *scope_line, false);
                p.metadata("containingType", *containing_type, false)?;
                p.dwarf("virtuality", *virtuality, dwarf::virtuality);
                p.int("virtualIndex", *virtual_index, false);
                p.flags("flags", *flags);
                p.boolean("isOptimized", *optimized);
                p.metadata("function", *function, false)?;
                p.metadata("templateParams", *template_params, false)?;
                p.metadata("declaration", *declaration, false)?;
                p.metadata("variables", *variables, false)?;
            }
            N::LexicalBlock {
                scope,
                file,
                line,
                column,
            } => {
                p.metadata("scope", *scope, true)?;
                p.metadata("file", *file, false)?;
                p.int("line", *line, false);
                p.int("column", *column, false);
            }
            N::LexicalBlockFile {
                scope,
                file,
                discriminator,
            } => {
                p.metadata("scope", *scope, true)?;
                p.metadata("file", *file, false)?;
                p.int("discriminator", *discriminator, true);
            }
            N::Namespace {
                scope,
                file,
                name,
                line,
            } => {
                p.string("name", *name, false)?;
                p.metadata("scope", *scope, true)?;
                p.metadata("file", *file, false)?;
                p.int("line", *line, false);
            }
            N::Module {
                scope,
                name,
                config_macros,
                include_path,
                isysroot,
            } => {
                p.metadata("scope", *scope, true)?;
                p.string("name", *name, false)?;
                p.string("configMacros", *config_macros, false)?;
                p.string("includePath", *include_path, false)?;
                p.string("isysroot", *isysroot, false)?;
            }
            N::TemplateType { name, ty } => {
                p.string("name", *name, false)?;
                p.metadata("type", *ty, true)?;
            }
            N::TemplateValue { tag, name, ty, value } => {
                if *tag != DW_TAG_TEMPLATE_VALUE_PARAMETER {
                    p.tag(*tag);
                }
                p.string("name", *name, false)?;
                p.metadata("type", *ty, false)?;
                p.metadata("value", *value, true)?;
            }
            N::GlobalVariable {
                scope,
                name,
                linkage_name,
                file,
                line,
                ty,
                local,
                definition,
                variable,
                declaration,
            } => {
                p.string("name", *name, false)?;
                p.string("linkageName", *linkage_name, false)?;
                p.metadata("scope", *scope, true)?;
                p.metadata("file", *file, false)?;
                p.int("line", *line, false);
                p.metadata("type", *ty, false)?;
                p.boolean("isLocal", *local);
                p.boolean("isDefinition", *definition);
                p.metadata("variable", *variable, false)?;
                p.metadata("declaration", *declaration, false)?;
            }
            N::LocalVariable {
                tag,
                scope,
                name,
                file,
                line,
                ty,
                arg,
                flags,
            } => {
                p.tag(*tag);
                p.string("name", *name, false)?;
                p.int("arg", *arg, *tag != DW_TAG_AUTO_VARIABLE);
                p.metadata("scope", *scope, true)?;
                p.metadata("file", *file, false)?;
                p.int("line", *line, false);
                p.metadata("type", *ty, false)?;
                p.flags("flags", *flags);
            }
            N::ObjcProperty {
                name,
                file,
                line,
                getter,
                setter,
                attributes,
                ty,
            } => {
                p.string("name", *name, false)?;
                p.metadata("file", *file, false)?;
                p.int("line", *line, false);
                p.string("setter", *setter, false)?;
                p.string("getter", *getter, false)?;
                p.int("attributes", *attributes, false);
                p.metadata("type", *ty, false)?;
            }
            N::ImportedEntity {
                tag,
                scope,
                entity,
                line,
                name,
            } => {
                p.tag(*tag);
                p.string("name", *name, false)?;
                p.metadata("scope", *scope, true)?;
                p.metadata("entity", *entity, false)?;
                p.int("line", *line, false);
            }
        }
        s.push(')');
        Ok(())
    }

    /// The location node an instruction's debug location is (none where it names no scope, as `DebugLoc::get` makes
    /// none).
    pub(super) fn location_node(&self, loc: Option<DebugLoc>) -> Option<Node> {
        let loc = loc.filter(|l| l.scope.is_some())?;
        self.location_nodes.get(&loc).copied()
    }

    /// The debug node a metadata operand of a call names, where it names one.
    fn called_node(&self, l: &Local<'m>, arg: Option<&usize>) -> Option<&'m DebugNode> {
        let (v, _) = self.lookup(Some(l), *arg?).ok()?;
        let Value::Metadata(md) = v else { return None };
        match self.m.metadata.get(*md) {
            Some(Metadata::Debug { node, .. }) => Some(node),
            _ => None,
        }
    }

    /// dxc's comment after an instruction with debug information: a debug intrinsic's variable (` ; var:"name"`, its
    /// expression and the function it is in), or the source line and column of any other instruction located on a line.
    pub(super) fn debug_comment(&self, s: &mut String, l: &Local<'m>, inst: &Instruction) -> Result<()> {
        if let Op::Call { function, args, .. } = &inst.op
            && let Some(callee) = l.f.name(*function).or_else(|| self.names.get(function).copied())
            && matches!(callee, "llvm.dbg.declare" | "llvm.dbg.value")
        {
            let (variable, expr) = if callee == "llvm.dbg.declare" {
                (args.get(1), args.get(2))
            } else {
                (args.get(2), args.get(3))
            };
            if let (
                Some(DebugNode::LocalVariable { name, scope, .. }),
                Some(DebugNode::Expression(elements)),
            ) = (self.called_node(l, variable), self.called_node(l, expr))
            {
                s.push_str(" ; var:\"");
                s.push_str(&self.md_text(*name));
                s.push_str("\" ");
                if let Some(Value::Metadata(md)) =
                    expr.and_then(|e| self.lookup(Some(l), *e).ok()).map(|(v, _)| v)
                    && let Some(Metadata::Debug { distinct: true, .. }) = self.m.metadata.get(*md)
                {
                    s.push_str("distinct ");
                }
                expression(s, elements);
                if let Some(sub) = self.subprogram_name(*scope) {
                    let _ = write!(s, " func:\"{sub}\"");
                }
            }
            return Ok(());
        }
        if let Some(loc) = inst.debug_loc.filter(|l| l.scope.is_some() && l.line != 0) {
            let _ = write!(s, " ; line:{} col:{}", loc.line, loc.column);
        }
        Ok(())
    }

    /// A metadata string's text (empty for none or for another kind of metadata), as LLVM's `StringRef` prints it.
    fn md_text(&self, id: Option<MetadataId>) -> String {
        match id.and_then(|id| self.m.metadata.get(id)) {
            Some(Metadata::String(bytes)) => String::from_utf8_lossy(bytes).into_owned(),
            _ => String::new(),
        }
    }

    /// `DILocalScope::getSubprogram`'s name: through the lexical blocks enclosing a scope, to its subprogram.
    fn subprogram_name(&self, scope: Option<MetadataId>) -> Option<String> {
        let mut at = scope?;
        // a well-formed chain is short; a cycle of blocks ends the walk
        for _ in 0..self.m.metadata.len() {
            match self.m.metadata.get(at)? {
                Metadata::Debug {
                    node: DebugNode::Subprogram { name, .. },
                    ..
                } => return Some(self.md_text(*name)),
                Metadata::Debug {
                    node: DebugNode::LexicalBlock { scope, .. } | DebugNode::LexicalBlockFile { scope, .. },
                    ..
                } => at = (*scope)?,
                _ => return None,
            }
        }
        None
    }
}

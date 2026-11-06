//! The entry point's metadata, resource records, type annotations and signature parts of an SM6 container, as the
//! records the file stores: the entry point and what its properties state (thread group, geometry, mesh, hull and
//! domain state), its signature elements and their packing, the bound resource ranges of `dx.resources` with their
//! tags, the field annotations of `dx.typeAnnotations`, and the rows of an `ISG1`/`OSG1`/`PSG1` part, each with DXIL's
//! and D3D's own numbers, and the entry point's other property tags, the tail tags of its signature elements, the
//! optional fields of the resource records and the string attributes of the entry function. What the numbers mean for a
//! graphics API is the caller's to decide.
use crate::module::{Constant, Metadata, MetadataId, Module, Type, TypeId, Value, ValueId};
use crate::{Result, error};

/// One signature element of the entry point: its id (the `sigId` loadInput and storeOutput name), its first
/// register and column, and its size.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct Element {
    /// The id the `loadInput` and `storeOutput` operations name the element by.
    pub id: u32,
    /// The semantic name.
    pub name: String,
    /// The first semantic index.
    pub index: u32,
    /// DXIL component type (5 u32, 4 i32, 9 f32, ...).
    pub component_type: u8,
    /// DXIL semantic kind (0 arbitrary, 1 SV_VertexID, 3 SV_Position, 13 SV_IsFrontFace, ...).
    pub system_value: u8,
    /// DXIL interpolation mode (1 constant, 2 linear, 4 linear noperspective, ...).
    pub interpolation: u8,
    /// The first register the element occupies.
    pub row: u32,
    /// The first component (0 x to 3 w) of that register.
    pub column: u8,
    /// How many registers it spans.
    pub rows: u32,
    /// How many components of each register it uses.
    pub columns: u8,
    /// An element the packer did not place (system values read another way): no register.
    pub placed: bool,
}
/// A bound resource range: class (0 SRV, 1 UAV, 2 constant buffer, 3 sampler), range id, first register, count.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub struct Range {
    /// 0 SRV, 1 UAV, 2 constant buffer, 3 sampler.
    pub class: u8,
    /// The range id the resource operations name the range by.
    pub id: u32,
    /// The first register of the range.
    pub lower: u32,
    /// The number of registers; `u32::MAX` where the range is unbounded.
    pub count: u32,
    /// Constant buffers: their size in bytes; SRVs and UAVs: their shape (`DxilResourceKind`, 2 a 2D texture);
    /// samplers: their kind (0 default, 1 comparison, 2 mono).
    pub extra: u32,
    /// The register space.
    pub space: u32,
    /// An SRV's or UAV's element type tag (`DxilComponentType`), where its tags state one.
    pub element: Option<u32>,
    /// A structured SRV's or UAV's element stride in bytes, where its tags state one.
    pub stride: Option<u32>,
    /// An unordered-access view with a hidden counter (an append or consume buffer, `IncrementCounter`).
    pub counter: bool,
    /// The module global a library names the resource by (a program of a library makes its handles from the
    /// global's value).
    pub variable: Option<ValueId>,
}

/// A metadata node being read. A problem with it is reported at the bit of the bitcode its record starts at.
#[derive(Clone, Copy, Debug)]
struct Node<'a> {
    m: &'a Module,
    id: MetadataId,
    ops: &'a [Option<MetadataId>],
    /// What the node is, for the messages.
    what: &'static str,
}

impl<'a> Node<'a> {
    /// The node `id`; where it is not a node the error is at the bit `at` (the record that refers to it).
    fn new(m: &'a Module, at: usize, id: MetadataId, what: &'static str) -> Result<Self> {
        match m.metadata.get(id).and_then(Metadata::operands) {
            Some(ops) => Ok(Node { m, id, ops, what }),
            None => Err(error(at, format!("{what}: expected a metadata node"))),
        }
    }
    fn bit(&self) -> usize {
        self.m.metadata_at.get(self.id).copied().unwrap_or(self.m.at)
    }
    /// The error for something wrong in this node.
    fn fail(&self, detail: impl std::fmt::Display) -> crate::Error {
        error(self.bit(), format!("{}: {detail}", self.what))
    }
    /// The node an operand names, which must not be null.
    fn node(&self, id: Option<MetadataId>, what: &'static str) -> Result<Node<'a>> {
        let id = id.ok_or_else(|| self.fail(format!("{what} is null")))?;
        Node::new(self.m, self.bit(), id, what)
    }
    /// Operand `i`, which must exist (it may be null).
    fn op(&self, i: usize) -> Result<Option<MetadataId>> {
        self.ops
            .get(i)
            .copied()
            .ok_or_else(|| self.fail(format!("node has no operand {i}")))
    }
    /// Operand `i`, null where the node has none.
    fn maybe(&self, i: usize) -> Option<MetadataId> {
        self.ops.get(i).copied().flatten()
    }
    /// An integer constant metadata operand.
    fn int_of(&self, id: Option<MetadataId>, what: &str) -> Result<i64> {
        match id.and_then(|i| self.m.metadata.get(i)) {
            Some(Metadata::Value { value, .. }) => match self.m.values.get(*value) {
                Some(Value::Constant(Constant::Integer(v))) => Ok(*v),
                // Zero is stored as the null constant.
                Some(Value::Constant(Constant::Null)) => Ok(0),
                _ => Err(self.fail(format!("{what}: expected an integer constant"))),
            },
            _ => Err(self.fail(format!("{what}: expected an integer"))),
        }
    }
    fn int(&self, i: usize, what: &str) -> Result<i64> {
        self.int_of(self.op(i)?, what)
    }
    /// An integer operand in the range of `T`.
    fn number_of<T: TryFrom<i64>>(&self, id: Option<MetadataId>, what: &str) -> Result<T> {
        let v = self.int_of(id, what)?;
        T::try_from(v).map_err(|_| self.fail(format!("{what}: {v} is out of range")))
    }
    fn number<T: TryFrom<i64>>(&self, i: usize, what: &str) -> Result<T> {
        self.number_of(self.op(i)?, what)
    }
    /// A 32-bit operand as its bits: dxc writes a library's unbound register and space as -1 and an unbounded range's
    /// size as -1, which it lists as 4294967295.
    fn bits32(&self, i: usize, what: &str) -> Result<u32> {
        let v = self.int(i, what)?;
        u32::try_from(v)
            .or_else(|_| i32::try_from(v).map(i32::cast_unsigned))
            .map_err(|_| self.fail(format!("{what}: {v} is out of range")))
    }
    /// The string an operand names: empty where it names none; an error where it is not UTF-8.
    fn string_of(&self, id: Option<MetadataId>, what: &str) -> Result<String> {
        match id.and_then(|i| self.m.metadata.get(i)) {
            Some(Metadata::String(s)) => std::str::from_utf8(s).map(str::to_owned).map_err(|e| {
                self.fail(format!(
                    "{what}: not UTF-8 (valid up to byte {})",
                    e.valid_up_to()
                ))
            }),
            _ => Ok(String::new()),
        }
    }
}

/// The named metadata `name`: the bit its record starts at and the nodes it lists.
fn named<'a>(m: &'a Module, name: &str) -> Option<(usize, &'a [MetadataId])> {
    let i = m.named_metadata.iter().position(|(n, _)| n == name)?;
    let (_, ids) = m.named_metadata.get(i)?;
    Some((
        m.named_metadata_at.get(i).copied().unwrap_or(m.at),
        ids.as_slice(),
    ))
}

/// The shader kind a library's entry point states (properties tag 8): the numbers of a program's kind (7 ray
/// generation to 12 callable, 13 mesh).
pub fn library_kind(m: &Module) -> Result<u32> {
    let entry = the_entry(m)?;
    let properties = entry
        .node(entry.maybe(4), "entry point properties")
        .map_err(|_| entry.fail("a library entry point without properties"))?;
    for pair in properties.ops.chunks(2) {
        let [tag, value] = pair else {
            return Err(properties.fail("a tag without a value"));
        };
        if properties.int_of(*tag, "property tag")? == 8 {
            return properties.number_of(*value, "shader kind");
        }
    }
    Err(properties.fail("a library entry point that states no shader kind"))
}

/// The one entry point's record. A library also has a record with no function, which holds its resources.
fn the_entry(m: &Module) -> Result<Node<'_>> {
    let (at, entries) =
        named(m, "dx.entryPoints").ok_or_else(|| error(m.at, "the module has no dx.entryPoints metadata"))?;
    let mut with_function = Vec::new();
    for &id in entries {
        let entry = Node::new(m, at, id, "entry point")?;
        if entry.op(0)?.is_some() {
            with_function.push(entry);
        }
    }
    match with_function.as_slice() {
        [entry] => Ok(*entry),
        _ => Err(error(
            at,
            format!(
                "dx.entryPoints: expected exactly one entry point with a function, found {}",
                with_function.len()
            ),
        )),
    }
}

/// The entry point's function value.
pub fn entry(m: &Module) -> Result<ValueId> {
    let entry = the_entry(m)?;
    match entry.op(0)?.and_then(|i| m.metadata.get(i)) {
        Some(Metadata::Value { value, .. }) => Ok(*value),
        _ => Err(entry.fail("operand 0 names no function")),
    }
}

/// The entry point's thread group size (`numthreads`): the value of the properties' tag 4 (a mesh or amplification
/// program's, the first field of its state, tag 9 or 10). `None` when the entry point states none (every stage but
/// compute, mesh and amplification).
pub fn num_threads(m: &Module) -> Result<Option<[u32; 3]>> {
    let entry = the_entry(m)?;
    let Some(properties) = entry.maybe(4) else {
        return Ok(None);
    };
    let properties = entry.node(Some(properties), "entry point properties")?;
    for pair in properties.ops.chunks(2) {
        let [tag, value] = pair else {
            return Err(properties.fail("a tag without a value"));
        };
        let tag = properties.int_of(*tag, "property tag")?;
        if tag != 4 && tag != 9 && tag != 10 {
            continue;
        }
        let mut size = properties.node(*value, "numthreads")?;
        // a mesh or amplification program states them first in its state
        if tag == 9 || tag == 10 {
            size = size.node(size.op(0)?, "numthreads")?;
        }
        return Ok(Some([
            size.number(0, "numthreads x")?,
            size.number(1, "numthreads y")?,
            size.number(2, "numthreads z")?,
        ]));
    }
    Ok(None)
}

/// The entry point's shader flags: the value of the properties' tag 0, a 64-bit mask kept as stored. `None` when the
/// entry point states none (the properties are null, or have no tag 0). The compiler writes the tag in nearly every
/// entry point of the games read; this reader attaches no meaning to its bits.
pub fn shader_flags(m: &Module) -> Result<Option<u64>> {
    flags_of(the_entry(m)?)
}

/// The shader flags of the module as dxc's `DxilModule` reads them: those of the first entry of `dx.entryPoints`, which
/// for a library is the entry without a function that states the library's own properties.
pub fn module_shader_flags(m: &Module) -> Result<Option<u64>> {
    let (at, entries) =
        named(m, "dx.entryPoints").ok_or_else(|| error(m.at, "the module has no dx.entryPoints metadata"))?;
    let first = entries
        .first()
        .ok_or_else(|| error(at, "dx.entryPoints lists no entry point"))?;
    flags_of(Node::new(m, at, *first, "entry point")?)
}

/// The flags (properties tag 0) of an entry point.
fn flags_of(entry: Node<'_>) -> Result<Option<u64>> {
    let Some(properties) = entry.maybe(4) else {
        return Ok(None);
    };
    let properties = entry.node(Some(properties), "entry point properties")?;
    for pair in properties.ops.chunks(2) {
        let [tag, value] = pair else {
            return Err(properties.fail("a tag without a value"));
        };
        if properties.int_of(*tag, "property tag")? == 0 {
            let flags = properties.int_of(*value, "shader flags")?;
            return Ok(Some(u64::from_le_bytes(flags.to_le_bytes())));
        }
    }
    Ok(None)
}

/// The usage mask of each signature element (tag 3 of the element's trailing tag list: the components of the element
/// the program reads or writes, bit 0 the element's first component, so a scalar packed into component w states 1,
/// not 8), in the order of [`elements`]' inputs and outputs and [`patch_elements`]; `None` for an element whose trailing tag list is absent or has no tag 3. In the stock programs
/// the only tag the lists hold is 3 (138,044 of 145,462 elements of skate.'s, 459,288 of 545,303 of Elden Ring's);
/// any other tag is ignored (see [`element_tags`] for them).
pub fn usage_masks(m: &Module) -> Result<[Vec<Option<u8>>; 3]> {
    Ok(element_tags(m)?.map(|list| list.into_iter().map(|tags| tags.usage_mask).collect()))
}

/// The trailing tags of one signature element (the element record's operand 10, a list of tag and value pairs). The
/// compiler writes tag 0 for an output of another stream than 0, tag 2 for an input indexed dynamically and tag 3 for
/// the components in use. Of the 691,000 elements of skate.'s and Elden Ring's programs only tag 3 occurs.
#[derive(Clone, Debug, Default, PartialEq, Eq)]
pub struct ElementTags {
    /// Tag 0: the stream (of a geometry program) the element is written to; `None` where the element states none.
    pub stream: Option<u32>,
    /// Tag 2: the components of the element that are indexed dynamically, bit 0 the element's first component.
    pub dynamic_index_mask: Option<u8>,
    /// Tag 3: the usage mask ([`usage_masks`]).
    pub usage_mask: Option<u8>,
    /// Every other tag with an integer value, as stored.
    pub other: Vec<(i64, i64)>,
}

/// The trailing tags of each signature element, in the order of [`elements`]' inputs and outputs and
/// [`patch_elements`]; an element with no tag list has [`ElementTags::default`].
pub fn element_tags(m: &Module) -> Result<[Vec<ElementTags>; 3]> {
    let entry = the_entry(m)?;
    let Some(signatures) = entry.op(2)? else {
        return Ok([Vec::new(), Vec::new(), Vec::new()]);
    };
    let signatures = entry.node(Some(signatures), "signatures")?;
    let list = |i: usize| -> Result<Vec<ElementTags>> {
        let Some(list) = signatures.op(i)? else {
            return Ok(Vec::new());
        };
        let list = signatures.node(Some(list), "signature")?;
        list.ops
            .iter()
            .map(|e| {
                let e = list.node(*e, "signature element")?;
                let Some(tail) = e.maybe(10) else {
                    return Ok(ElementTags::default());
                };
                let tail = e.node(Some(tail), "element tags")?;
                let (pairs, rest) = tail.ops.as_chunks::<2>();
                if !rest.is_empty() {
                    return Err(tail.fail("a tag without its value"));
                }
                let mut tags = ElementTags::default();
                for [tag, value] in pairs {
                    match tail.int_of(*tag, "element tag")? {
                        0 => tags.stream = Some(tail.number_of(*value, "element stream")?),
                        2 => tags.dynamic_index_mask = Some(tail.number_of(*value, "dynamic index mask")?),
                        3 => tags.usage_mask = Some(tail.number_of(*value, "usage mask")?),
                        other => {
                            if let Ok(v) = tail.int_of(*value, "element tag value") {
                                tags.other.push((other, v));
                            }
                        }
                    }
                }
                Ok(tags)
            })
            .collect()
    };
    Ok([list(0)?, list(1)?, list(2)?])
}

/// The entry point's input and output elements, by id.
pub fn elements(m: &Module) -> Result<(Vec<Element>, Vec<Element>)> {
    let [inputs, outputs, _] = signature_lists(m)?;
    Ok((inputs, outputs))
}

/// A hull or domain program's patch-constant elements, by id.
pub fn patch_elements(m: &Module) -> Result<Vec<Element>> {
    let [_, _, patch] = signature_lists(m)?;
    Ok(patch)
}

/// What a hull program's entry point states about its patch (the properties' tag 3): the patch-constant function, the
/// control-point counts, the tessellator's domain, partitioning and output primitive and the largest factor.
#[derive(Clone, Debug, PartialEq)]
pub struct HullState {
    /// The patch-constant function.
    pub patch_constant: ValueId,
    /// The number of input control points.
    pub input_control_points: u32,
    /// The number of output control points.
    pub output_control_points: u32,
    /// The tessellator domain (`D3D11_TESSELLATOR_DOMAIN`).
    pub domain: u32,
    /// The partitioning (`D3D11_TESSELLATOR_PARTITIONING`).
    pub partitioning: u32,
    /// The output primitive (`D3D11_TESSELLATOR_OUTPUT_PRIMITIVE`).
    pub output_primitive: u32,
    /// The largest tessellation factor.
    pub max_tess_factor: f32,
}

/// The value of a properties tag of the entry point, if the entry point states it.
fn entry_property(m: &Module, wanted: i64) -> Result<Option<Node<'_>>> {
    let entry = the_entry(m)?;
    let Some(properties) = entry.maybe(4) else {
        return Ok(None);
    };
    let properties = entry.node(Some(properties), "entry point properties")?;
    for pair in properties.ops.chunks(2) {
        let [tag, value] = pair else {
            return Err(properties.fail("a tag without a value"));
        };
        if properties.int_of(*tag, "property tag")? == wanted {
            return properties.node(*value, "property").map(Some);
        }
    }
    Ok(None)
}

/// What a geometry program's entry point states (the properties' tag 1), as stored: the primitive it reads (`input`, a
/// `D3D_PRIMITIVE`: 1 point, 2 line, 3 triangle, 6 line and 7 triangle with adjacency), how many vertices it emits at
/// most, the streams it writes (a mask), the topology its stream makes (a `D3D_PRIMITIVE_TOPOLOGY`: 1 point list, 3
/// line strip, 5 triangle strip) and how many invocations run for a primitive.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub struct GeometryState {
    /// The input primitive (`D3D_PRIMITIVE`).
    pub input: u32,
    /// The most vertices it emits.
    pub max_vertices: u32,
    /// The streams it writes, a mask.
    pub streams: u32,
    /// The topology of its output stream (`D3D_PRIMITIVE_TOPOLOGY`).
    pub topology: u32,
    /// How many invocations run for a primitive.
    pub instances: u32,
}

/// A geometry program's state.
pub fn geometry_state(m: &Module) -> Result<GeometryState> {
    let state = entry_property(m, 1)?.ok_or_else(|| {
        the_entry(m).map_or_else(
            |e| e,
            |e| e.fail("a geometry program without its state (properties tag 1)"),
        )
    })?;
    Ok(GeometryState {
        input: state.number(0, "geometry input primitive")?,
        max_vertices: state.number(1, "geometry maximum vertices")?,
        streams: state.number(2, "geometry streams")?,
        topology: state.number(3, "geometry topology")?,
        instances: state.number(4, "geometry instances")?,
    })
}

/// What a mesh program's entry point states (the properties' tag 9) after its thread group, as stored: the most
/// vertices and primitives it writes, the topology of its primitives (1 line, 2 triangle) and the size in bytes of the
/// payload it reads from a task program. A null field is zero.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub struct MeshState {
    /// The most vertices it writes.
    pub max_vertices: u32,
    /// The most primitives it writes.
    pub max_primitives: u32,
    /// The topology of its primitives (1 line, 2 triangle).
    pub topology: u32,
    /// The size in bytes of the payload it reads from a task program.
    pub payload: u32,
}

/// A mesh program's state.
pub fn mesh_state(m: &Module) -> Result<MeshState> {
    let state = entry_property(m, 9)?.ok_or_else(|| {
        the_entry(m).map_or_else(
            |e| e,
            |e| e.fail("a mesh program without its state (properties tag 9)"),
        )
    })?;
    // a null field is zero
    let field = |k: usize, what: &str| -> Result<u32> {
        match state.op(k)? {
            None => Ok(0),
            some => state.number_of(some, what),
        }
    };
    Ok(MeshState {
        max_vertices: field(1, "mesh maximum vertices")?,
        max_primitives: field(2, "mesh maximum primitives")?,
        topology: field(3, "mesh topology")?,
        payload: field(4, "mesh payload size")?,
    })
}

/// A hull program's patch state.
pub fn hull_state(m: &Module) -> Result<HullState> {
    let state = entry_property(m, 3)?.ok_or_else(|| {
        the_entry(m).map_or_else(
            |e| e,
            |e| e.fail("a hull program without its patch state (properties tag 3)"),
        )
    })?;
    let small = |k: usize, what: &str| -> Result<u32> { state.number_of(state.maybe(k), what) };
    let patch_constant = match state.maybe(0).and_then(|i| m.metadata.get(i)) {
        Some(Metadata::Value { value, .. }) => *value,
        _ => return Err(state.fail("a hull program without its patch-constant function")),
    };
    let max = match state.maybe(6).and_then(|i| m.metadata.get(i)) {
        Some(Metadata::Value { value, .. }) => match m.values.get(*value) {
            Some(Value::Constant(Constant::Float(bits))) => {
                let bits = u32::try_from(*bits)
                    .map_err(|_| state.fail("the maximum tessellation factor is wider than a float"))?;
                f32::from_bits(bits)
            }
            _ => return Err(state.fail("the maximum tessellation factor is not a float")),
        },
        _ => return Err(state.fail("hull state without a maximum tessellation factor")),
    };
    Ok(HullState {
        patch_constant,
        input_control_points: small(1, "hull input control points")?,
        output_control_points: small(2, "hull output control points")?,
        domain: small(3, "hull domain")?,
        partitioning: small(4, "hull partitioning")?,
        output_primitive: small(5, "hull output primitive")?,
        max_tess_factor: max,
    })
}

/// A domain program's patch state (tag 2): the tessellator domain and the input control point count.
pub fn domain_state(m: &Module) -> Result<(u32, u32)> {
    let state = entry_property(m, 2)?.ok_or_else(|| {
        the_entry(m).map_or_else(
            |e| e,
            |e| e.fail("a domain program without its patch state (properties tag 2)"),
        )
    })?;
    Ok((
        state.number_of(state.maybe(0), "domain")?,
        state.number_of(state.maybe(1), "domain input control points")?,
    ))
}

/// One property of the entry point as stored: the tag and the metadata record holding the value (an integer constant
/// or a node), `None` where the value is null. The tags the compiler writes: 0 shader flags, 1 geometry state, 2 domain
/// state, 3 hull state, 4 thread group, 5 auto binding space, 6 ray payload size, 7 ray attribute size, 8 shader kind
/// (libraries), 9 mesh state, 10 amplification state, 11 wave size, 12 root signature, 23 wave size range.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub struct EntryProperty {
    /// The tag.
    pub tag: i64,
    /// The value's metadata record.
    pub value: Option<MetadataId>,
}

/// Every property of the entry point, in the order stored; none where the entry point states none.
pub fn entry_properties(m: &Module) -> Result<Vec<EntryProperty>> {
    let entry = the_entry(m)?;
    properties_of(entry)
}

fn properties_of(entry: Node<'_>) -> Result<Vec<EntryProperty>> {
    let Some(properties) = entry.maybe(4) else {
        return Ok(Vec::new());
    };
    let properties = entry.node(Some(properties), "entry point properties")?;
    let (pairs, rest) = properties.ops.as_chunks::<2>();
    if !rest.is_empty() {
        return Err(properties.fail("a tag without a value"));
    }
    pairs
        .iter()
        .map(|[tag, value]| {
            Ok(EntryProperty {
                tag: properties.int_of(*tag, "property tag")?,
                value: *value,
            })
        })
        .collect()
}

/// The integer a property states directly (tags 6, 7 and 8), or the first integer of the node it states (tags 5 and
/// 11); `None` where the entry point has no such property.
fn property_integer(m: &Module, wanted: i64) -> Result<Option<u32>> {
    let entry = the_entry(m)?;
    for property in properties_of(entry)? {
        if property.tag != wanted {
            continue;
        }
        let record = entry.node(property.value, "property").ok();
        return match record {
            Some(node) => node.number(0, "property value").map(Some),
            None => entry.number_of(property.value, "property value").map(Some),
        };
    }
    Ok(None)
}

/// The size in bytes of the ray payload a ray tracing program's entry point states (tag 6); `None` for a program
/// that states none (a ray generation program, or any other stage).
pub fn ray_payload_size(m: &Module) -> Result<Option<u32>> {
    property_integer(m, 6)
}

/// The size in bytes of the hit attributes a ray tracing program's entry point states (tag 7); `None` where it states none.
pub fn ray_attribute_size(m: &Module) -> Result<Option<u32>> {
    property_integer(m, 7)
}

/// The register space automatic bindings take, as the entry point states it (tag 5, a one-integer node); `None` where
/// it states none. The stock libraries state 0 on the record that holds their resources (which has no function) and
/// the compiler option `-auto-binding-space` changes that record's value: [`library_binding_space`] reads it.
pub fn auto_binding_space(m: &Module) -> Result<Option<u32>> {
    property_integer(m, 5)
}

/// The auto binding space the library's resource record (the entry record with no function) states (tag 5). `None`
/// where the module has no such record or it states none.
pub fn library_binding_space(m: &Module) -> Result<Option<u32>> {
    let (at, entries) =
        named(m, "dx.entryPoints").ok_or_else(|| error(m.at, "the module has no dx.entryPoints metadata"))?;
    for &id in entries {
        let entry = Node::new(m, at, id, "entry point")?;
        if entry.op(0)?.is_some() {
            continue;
        }
        for property in properties_of(entry)? {
            if property.tag == 5 {
                let node = entry.node(property.value, "auto binding space")?;
                return node.number(0, "auto binding space").map(Some);
            }
        }
    }
    Ok(None)
}

/// The wave size a compute, mesh or amplification program's entry point requires (tag 11, a node): its integers as
/// stored, a single one for a fixed size; `None` where the entry point states none.
pub fn wave_size(m: &Module) -> Result<Option<Vec<u32>>> {
    let Some(node) = entry_property(m, 11)? else {
        return Ok(None);
    };
    node.ops
        .iter()
        .map(|id| node.number_of(*id, "wave size"))
        .collect::<Result<Vec<u32>>>()
        .map(Some)
}

/// The payload size in bytes an amplification program's entry point states (the second field of its state, tag 10);
/// `None` for any other program. The first field is the thread group ([`num_threads`]).
pub fn amplification_payload_size(m: &Module) -> Result<Option<u32>> {
    let Some(state) = entry_property(m, 10)? else {
        return Ok(None);
    };
    state.number(1, "amplification payload size").map(Some)
}

/// The denormal mode an entry function states for 32-bit floats, as the string attribute `fp32-denorm-mode` has it
/// (`any`, `preserve` or `ftz`). `None` where the function carries no such attribute, which is the case in all of the
/// 69,728 programs of skate. and Elden Ring: the compiler writes the attribute only where the option asks for a mode.
pub fn fp32_denorm_mode(m: &Module) -> Result<Option<String>> {
    let function = entry(m)?;
    Ok(m.string_attribute(function, "fp32-denorm-mode")
        .map(str::to_owned))
}

fn signature_lists(m: &Module) -> Result<[Vec<Element>; 3]> {
    let entry = the_entry(m)?;
    let Some(signatures) = entry.op(2)? else {
        return Ok([Vec::new(), Vec::new(), Vec::new()]);
    };
    let signatures = entry.node(Some(signatures), "signatures")?;
    let list = |i: usize| -> Result<Vec<Element>> {
        let Some(list) = signatures.op(i)? else {
            return Ok(Vec::new());
        };
        let list = signatures.node(Some(list), "signature")?;
        list.ops
            .iter()
            .map(|e| {
                let e = list.node(*e, "signature element")?;
                let row = e.int(8, "row")?;
                let element = Element {
                    id: e.number(0, "element id")?,
                    name: e.string_of(e.op(1)?, "element name")?,
                    index: match e.op(4)? {
                        Some(list) => match e.node(Some(list), "semantic indices")?.ops.first() {
                            Some(first) => e.number_of(*first, "semantic index")?,
                            None => 0,
                        },
                        None => 0,
                    },
                    component_type: e.number(2, "component type")?,
                    system_value: e.number(3, "system value")?,
                    interpolation: e.number(5, "interpolation")?,
                    rows: e.number(6, "rows")?,
                    columns: e.number(7, "columns")?,
                    placed: row >= 0,
                    row: u32::try_from(row.max(0))
                        .map_err(|_| e.fail(format!("row {row} is out of range")))?,
                    column: u8::try_from(e.int(9, "column")?.max(0))
                        .map_err(|_| e.fail("column is out of range"))?,
                };
                // Four lanes per register; at most 32 registers.
                if element.rows == 0
                    || element.columns == 0
                    || u32::from(element.column)
                        .checked_add(u32::from(element.columns))
                        .is_none_or(|end| end > 4)
                    || element.row.checked_add(element.rows).is_none_or(|end| end > 32)
                {
                    return Err(e.fail("the element lies outside the 32 four-lane registers"));
                }
                Ok(element)
            })
            .collect()
    };
    Ok([list(0)?, list(1)?, list(2)?])
}

/// A resource's tag list (alternating tag and value): the element type (tag 0) and the structured stride (tag 1).
fn tags(resource: Node<'_>, list: Option<MetadataId>) -> Result<(Option<u32>, Option<u32>)> {
    let Some(list) = list else {
        return Ok((None, None));
    };
    let ops = resource.node(Some(list), "resource tags")?;
    let (pairs, rest) = ops.ops.as_chunks::<2>();
    if !rest.is_empty() {
        return Err(ops.fail("a tag without its value"));
    }
    let (mut element, mut stride) = (None, None);
    // the other tags' values are not read: a tag's value can be an `i1` (`true` is -1)
    for [tag, value] in pairs {
        match ops.int_of(*tag, "tag")? {
            0 => element = Some(ops.number_of(*value, "tag value")?),
            1 => stride = Some(ops.number_of(*value, "tag value")?),
            _ => {}
        }
    }
    Ok((element, stride))
}

/// The module global a resource record's variable names: the global itself, or the one it is a cast of.
fn variable_of(m: &Module, id: Option<MetadataId>) -> Option<ValueId> {
    let Some(Metadata::Value { value, .. }) = id.and_then(|i| m.metadata.get(i)) else {
        return None;
    };
    match m.values.get(*value)? {
        Value::Constant(Constant::Cast { value, .. }) => Some(*value),
        Value::Global { .. } => Some(*value),
        _ => None,
    }
}

/// The bound resource ranges of `dx.resources` (SRVs, UAVs, constant buffers, samplers), each with its variable's name
/// and the type its variable points to (the resource's handle type).
pub fn ranges(m: &Module) -> Result<Vec<(Range, String, Option<TypeId>)>> {
    let Some((at, [resources])) = named(m, "dx.resources") else {
        return Ok(Vec::new());
    };
    let lists = Node::new(m, at, *resources, "dx.resources")?;
    let mut out = Vec::new();
    for (class, list) in lists.ops.iter().enumerate() {
        let Some(list) = list else { continue };
        let class =
            u8::try_from(class).map_err(|_| lists.fail(format!("resource class {class} is out of range")))?;
        let list = lists.node(Some(*list), "resource list")?;
        for r in list.ops {
            let r = list.node(*r, "resource")?;
            // The record's variable is an undef pointer to the resource's type.
            let ty = match r.op(1)?.and_then(|i| m.metadata.get(i)) {
                Some(Metadata::Value { ty, .. }) => match m.types.get(*ty) {
                    Some(Type::Pointer(t, _)) => Some(*t),
                    _ => None,
                },
                _ => None,
            };
            let extra = r.number(6, "resource field")?;
            let (element, stride) = match class {
                0 => tags(r, r.maybe(8))?,
                1 => tags(r, r.maybe(10))?,
                _ => (None, None),
            };
            out.push((
                Range {
                    class,
                    id: r.number(0, "resource id")?,
                    lower: r.bits32(4, "lower bound")?,
                    count: r.bits32(5, "range size")?,
                    extra,
                    space: r.bits32(3, "register space")?,
                    element,
                    stride,
                    // a UAV's record states whether it has a counter after the shape and the coherence
                    counter: class == 1 && r.maybe(8).is_some() && r.int(8, "counter")? != 0,
                    variable: variable_of(m, r.op(1)?),
                },
                r.string_of(r.op(2)?, "resource name")?,
                ty,
            ));
        }
    }
    Ok(out)
}

/// The optional fields of a resource record that [`Range`] leaves out, keyed by the record's class and id.
#[derive(Clone, Debug, Default, PartialEq, Eq)]
pub struct ResourceExtras {
    /// The class (0 SRV, 1 UAV, 2 constant buffer, 3 sampler), as in [`Range::class`].
    pub class: u8,
    /// The range id, as in [`Range::id`].
    pub id: u32,
    /// A shader resource view's sample count (operand 7): 0 for a single-sampled view, 4 for a `Texture2DMS<_, 4>`.
    pub sample_count: Option<u32>,
    /// An unordered-access view declared `globallycoherent` (operand 7).
    pub globally_coherent: bool,
    /// An unordered-access view that is rasterizer ordered (operand 9).
    pub rasterizer_ordered: bool,
    /// Tag 2 of the record's tag list: the kind of the sampler-feedback texture, where it states one.
    pub sampler_feedback: Option<u32>,
    /// Tag 3 of the record's tag list: the view is the target of a 64-bit atomic operation.
    pub atomic64: bool,
    /// Every tag of the record's tag list with its value, as stored (0 element type, 1 stride, 2 sampler feedback
    /// kind, 3 64-bit atomics).
    pub tags: Vec<(i64, i64)>,
}

/// The optional fields of every resource record, in the order of [`ranges`]. A constant buffer's and a sampler's record
/// have a tag list as their last operand as well.
pub fn resource_extras(m: &Module) -> Result<Vec<ResourceExtras>> {
    let Some((at, [resources])) = named(m, "dx.resources") else {
        return Ok(Vec::new());
    };
    let lists = Node::new(m, at, *resources, "dx.resources")?;
    let mut out = Vec::new();
    for (class, list) in lists.ops.iter().enumerate() {
        let Some(list) = list else { continue };
        let class =
            u8::try_from(class).map_err(|_| lists.fail(format!("resource class {class} is out of range")))?;
        let list = lists.node(Some(*list), "resource list")?;
        for r in list.ops {
            let r = list.node(*r, "resource")?;
            // the tag list is the last operand: 8 for an SRV, 10 for a UAV, 7 for a constant buffer and a sampler
            let tag_operand = match class {
                0 => 8,
                1 => 10,
                _ => 7,
            };
            let mut tags = Vec::new();
            if let Some(tag_list) = r.maybe(tag_operand) {
                let tag_list = r.node(Some(tag_list), "resource tags")?;
                let (pairs, rest) = tag_list.ops.as_chunks::<2>();
                if !rest.is_empty() {
                    return Err(tag_list.fail("a tag without its value"));
                }
                for [tag, value] in pairs {
                    tags.push((
                        tag_list.int_of(*tag, "tag")?,
                        tag_list.int_of(*value, "tag value")?,
                    ));
                }
            }
            let tag_value = |wanted: i64| tags.iter().find(|(t, _)| *t == wanted).map(|(_, v)| *v);
            out.push(ResourceExtras {
                class,
                id: r.number(0, "resource id")?,
                sample_count: match (class, r.maybe(7)) {
                    (0, Some(_)) => Some(r.number(7, "sample count")?),
                    _ => None,
                },
                globally_coherent: class == 1 && r.maybe(7).is_some() && r.int(7, "globally coherent")? != 0,
                rasterizer_ordered: class == 1
                    && r.maybe(9).is_some()
                    && r.int(9, "rasterizer ordered")? != 0,
                sampler_feedback: match tag_value(2) {
                    Some(v) => Some(
                        u32::try_from(v)
                            .map_err(|_| r.fail(format!("sampler feedback kind {v} is out of range")))?,
                    ),
                    None => None,
                },
                atomic64: tag_value(3).is_some_and(|v| v != 0),
                tags,
            });
        }
    }
    Ok(out)
}

/// A bound resource as dxc's listing writes it in its Resource Bindings table (`PrintResourceBindings`): its range,
/// its variable's name and type, and its sample count, with the table's names for them.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct Binding {
    /// The range, as [`ranges`] reads it.
    pub range: Range,
    /// The resource's variable's name.
    pub name: String,
    /// The type its variable points to (the resource's handle type).
    pub ty: Option<TypeId>,
    /// A shader resource view's sample count: 0 for a single-sampled view and for a binding of another class.
    pub sample_count: u32,
}

impl Binding {
    /// Whether the binding is a view (an SRV or a UAV), which has a format and a shape.
    fn view(&self) -> bool {
        matches!(self.range.class, 0 | 1)
    }

    /// The Type column: `texture` (any SRV), `UAV`, `cbuffer` or `sampler`.
    pub fn class_name(&self) -> &'static str {
        match self.range.class {
            0 => "texture",
            1 => "UAV",
            2 => "cbuffer",
            _ => "sampler",
        }
    }

    /// The Format column: a view's element type ([`component_name`]), `byte` for a raw buffer and `struct` for a
    /// structured one; `NA` for a constant buffer or sampler.
    pub fn format_name(&self) -> &'static str {
        match (self.view(), self.range.extra) {
            (false, _) => "NA",
            (true, 11) => "byte",
            (true, 12) => "struct",
            (true, _) => component_name(self.range.element.unwrap_or(0)),
        }
    }

    /// The Dim column: a view's shape ([`dimension_name`]) with a multisampled texture's sample count (`2dMS4`), and
    /// for a raw or structured buffer how it is accessed (`r/o`, `r/w`, `r/w+cnt` with a hidden counter); `NA` for a
    /// constant buffer or sampler.
    pub fn dimension_name(&self) -> String {
        let r = &self.range;
        match (self.view(), r.extra) {
            (false, _) => "NA".to_owned(),
            (true, 11 | 12) if r.class == 0 => "r/o".to_owned(),
            (true, 11 | 12) if r.counter => "r/w+cnt".to_owned(),
            (true, 11 | 12) => "r/w".to_owned(),
            (true, 3 | 8) if self.sample_count != 0 => {
                format!("{}{}", dimension_name(r.extra), self.sample_count)
            }
            (true, kind) => dimension_name(kind).to_owned(),
        }
    }

    /// The ID column: the class's letter and the range id (`T0`, `U1`, `CB0`, `S2`).
    pub fn id_name(&self) -> String {
        let letter = match self.range.class {
            0 => "T",
            1 => "U",
            2 => "CB",
            _ => "S",
        };
        format!("{letter}{}", self.range.id)
    }

    /// The HLSL Bind column: the register's letter and number, and its space where not 0 (`t0`, `u2,space1`).
    pub fn bind_name(&self) -> String {
        let letter = match self.range.class {
            0 => "t",
            1 => "u",
            2 => "cb",
            _ => "s",
        };
        if self.range.space == 0 {
            format!("{letter}{}", self.range.lower)
        } else {
            format!("{letter}{},space{}", self.range.lower, self.range.space)
        }
    }
}

/// The bound resources of `dx.resources` in the order dxc's listing writes them: constant buffers, samplers, SRVs, then
/// UAVs, each class in the order of its list.
pub fn bindings(m: &Module) -> Result<Vec<Binding>> {
    let extras = resource_extras(m)?;
    let mut all: Vec<Binding> = ranges(m)?
        .into_iter()
        .map(|(range, name, ty)| {
            let sample_count = extras
                .iter()
                .find(|e| e.class == range.class && e.id == range.id)
                .and_then(|e| e.sample_count)
                .unwrap_or(0);
            Binding {
                range,
                name,
                ty,
                sample_count,
            }
        })
        .collect();
    let order = |class: u8| match class {
        2 => 0,
        3 => 1,
        0 => 2,
        _ => 3,
    };
    // a stable sort keeps each class in the order of its list
    all.sort_by_key(|b| order(b.range.class));
    Ok(all)
}

/// One field of a struct type, as its annotation in `dx.typeAnnotations` states it.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct FieldAnnotation {
    /// The field's name.
    pub name: String,
    /// Byte offset in the constant buffer.
    pub offset: u32,
    /// Its `DxilComponentType`: LLVM integers carry no signedness, the annotation does.
    pub component: Option<u32>,
    /// A matrix field's rows, columns and orientation (1 row-major, 2 column-major): LLVM lowers a matrix to an array
    /// of its lines, so only the annotation says it is one.
    pub matrix: Option<(u32, u32, u32)>,
}

/// A struct type's annotation in `dx.typeAnnotations`: its size in a constant buffer and its fields.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct StructAnnotation {
    /// The struct's size in bytes as a constant buffer lays it out (the annotation's first operand).
    pub size: u32,
    /// The annotation of each field, in the struct's order.
    pub fields: Vec<FieldAnnotation>,
}

/// Fields of a struct type from `dx.typeAnnotations` (field tag 6 the name, 3 the constant-buffer offset, 7 the
/// component type). Empty when the module has no annotation for it.
pub fn fields(m: &Module, t: TypeId) -> Result<Vec<FieldAnnotation>> {
    Ok(struct_annotation(m, t)?.map(|a| a.fields).unwrap_or_default())
}

/// The annotation `dx.typeAnnotations` states for a struct type (kind 0, then pairs of a struct-typed value and its
/// annotation: the size, one node per field, and from DXIL 1.5 a node of template arguments after them), where it
/// states one.
pub fn struct_annotation(m: &Module, t: TypeId) -> Result<Option<StructAnnotation>> {
    let Some((at, annotations)) = named(m, "dx.typeAnnotations") else {
        return Ok(None);
    };
    let field_count = match m.types.get(t) {
        Some(Type::Struct { elements, .. }) => elements.len(),
        _ => return Ok(None),
    };
    for &a in annotations {
        let a = Node::new(m, at, a, "type annotations")?;
        // Struct annotations: kind 0, then (struct type, annotation) pairs.
        if a.int(0, "annotation kind")? != 0 {
            continue;
        }
        let (pairs, rest) = a.ops.get(1..).unwrap_or_default().as_chunks::<2>();
        if !rest.is_empty() {
            return Err(a.fail("a struct type without its annotation"));
        }
        for [struct_type, annotation] in pairs {
            let ty = match struct_type.and_then(|i| m.metadata.get(i)) {
                Some(Metadata::Value { ty, .. }) => *ty,
                _ => continue,
            };
            if ty != t {
                continue;
            }
            let annotation = a.node(*annotation, "struct annotation")?;
            // an empty struct's annotation is its size alone
            let fields = match annotation.ops.len() {
                1 => &[][..],
                n if n == field_count.saturating_add(1) || n == field_count.saturating_add(2) => {
                    annotation.ops.get(1..=field_count).unwrap_or_default()
                }
                n => {
                    return Err(annotation.fail(format!("{n} operands for a struct of {field_count} fields")));
                }
            };
            let fields = fields
                .iter()
                .map(|f| {
                    let f = annotation.node(*f, "field annotation")?;
                    let (mut name, mut offset, mut component, mut matrix) = (String::new(), 0, None, None);
                    let (tags, rest) = f.ops.as_chunks::<2>();
                    if !rest.is_empty() {
                        return Err(f.fail("a tag without its value"));
                    }
                    for [tag, value] in tags {
                        match f.int_of(*tag, "field tag")? {
                            6 => name = f.string_of(*value, "field name")?,
                            3 => offset = f.number_of(*value, "field offset")?,
                            2 => {
                                let ops = f.node(*value, "matrix annotation")?;
                                matrix = Some((
                                    ops.number(0, "matrix rows")?,
                                    ops.number(1, "matrix columns")?,
                                    ops.number(2, "matrix orientation")?,
                                ));
                            }
                            7 => component = Some(f.number_of(*value, "field component type")?),
                            _ => {}
                        }
                    }
                    Ok(FieldAnnotation {
                        name,
                        offset,
                        component,
                        matrix,
                    })
                })
                .collect::<Result<Vec<_>>>()?;
            return Ok(Some(StructAnnotation {
                size: annotation.number(0, "struct size")?,
                fields,
            }));
        }
    }
    Ok(None)
}

/// The shader model `dx.shaderModel` states: the kind as dxc's targets name it (`ps`, `vs`, `lib`, `ms`, ...) and the
/// major and minor version.
pub fn shader_model(m: &Module) -> Result<Option<(String, u32, u32)>> {
    let Some((at, [model])) = named(m, "dx.shaderModel") else {
        return Ok(None);
    };
    let model = Node::new(m, at, *model, "dx.shaderModel")?;
    Ok(Some((
        model.string_of(model.op(0)?, "shader kind")?,
        model.number(1, "shader model major")?,
        model.number(2, "shader model minor")?,
    )))
}

/// The serialised view-id state `dx.viewIdState` holds (an `i32` array: the input scalar count, then per stream the
/// output scalar count and its dependency tables), where the module has it.
pub fn view_id_state(m: &Module) -> Result<Option<Vec<u32>>> {
    let Some((at, [state])) = named(m, "dx.viewIdState") else {
        return Ok(None);
    };
    let state = Node::new(m, at, *state, "dx.viewIdState")?;
    let value = match state.op(0)?.and_then(|i| m.metadata.get(i)) {
        Some(Metadata::Value { value, .. }) => *value,
        _ => return Err(state.fail("expected an array constant")),
    };
    let len = match m.value_types.get(value).and_then(|t| m.types.get(*t)) {
        Some(Type::Array(n, _)) => {
            usize::try_from(*n).map_err(|_| state.fail("an array past the address space"))?
        }
        _ => return Err(state.fail("expected an i32 array")),
    };
    let word = |v: &Value| -> Result<u32> {
        match v {
            // the low 32 bits of the sign-extended value
            Value::Constant(Constant::Integer(v)) => Ok(u32::try_from(v & 0xFFFF_FFFF).unwrap_or(0)),
            Value::Constant(Constant::Null) => Ok(0),
            _ => Err(state.fail("an element that is not an integer constant")),
        }
    };
    match m.values.get(value) {
        Some(Value::Constant(Constant::Null)) => Ok(Some(vec![0; len])),
        Some(Value::Constant(Constant::Data(words))) => {
            Ok(Some(words.iter().map(|w| (w & 0xFFFF_FFFF) as u32).collect()))
        }
        Some(Value::Constant(Constant::Aggregate(ids))) => ids
            .iter()
            .map(|id| word(m.values.get(*id).unwrap_or(&Value::Local)))
            .collect::<Result<Vec<_>>>()
            .map(Some),
        _ => Err(state.fail("expected an array constant")),
    }
}

/// One element of an `ISG1`/`OSG1`/`PSG1` part as stored.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct SignatureElement {
    /// The geometry stream the element is written to (0 for every other element).
    pub stream: u32,
    /// The semantic name.
    pub name: String,
    /// The semantic index.
    pub index: u32,
    /// `D3D_NAME`.
    pub system_value: u32,
    /// `D3D_REGISTER_COMPONENT_TYPE`.
    pub component_type: u32,
    /// The register the element is packed into.
    pub register: u32,
    /// The components the element occupies, one bit each (x is bit 0).
    pub mask: u8,
    /// The components a program reads (inputs) or never writes (outputs), as stored.
    pub read_write_mask: u8,
    /// Where the record starts, in bits of the part.
    pub bit: usize,
}

impl SignatureElement {
    /// The name dxc's listing gives the element's system value (`DxilProgramSigSemantic`, D3D's `D3D_NAME`): `POS`,
    /// `TARGET`, ...; `NONE` for none.
    pub fn system_value_name(&self) -> &'static str {
        match self.system_value {
            1 => "POS",
            2 => "CLIPDST",
            3 => "CULLDST",
            4 => "RTINDEX",
            5 => "VPINDEX",
            6 => "VERTID",
            7 => "PRIMID",
            8 => "INSTID",
            9 => "FFACE",
            10 => "SAMPLE",
            11 => "QUADEDGE",
            12 => "QUADINT",
            13 => "TRIEDGE",
            14 => "TRIINT",
            15 => "LINEDET",
            16 => "LINEDEN",
            23 => "BARYCEN",
            24 => "SHDINGRATE",
            25 => "CULLPRIM",
            64 => "TARGET",
            65 => "DEPTH",
            66 => "COVERAGE",
            67 => "DEPTHGE",
            68 => "DEPTHLE",
            69 => "STENCILREF",
            70 => "INNERCOV",
            _ => "NONE",
        }
    }

    /// The name dxc's listing gives the element's component type (`DxilProgramSigCompType`): `float`, `uint`, ...
    pub fn format_name(&self) -> &'static str {
        match self.component_type {
            1 => "uint",
            2 => "int",
            3 => "float",
            4 => "uint16",
            5 => "int16",
            6 => "fp16",
            7 => "uint64",
            8 => "int64",
            9 => "double",
            _ => "unknown",
        }
    }
}

/// The name dxc gives a DXIL component type (`CompType::GetName`: 4 `i32`, 5 `u32`, 9 `f32`, ...); `invalid` for 0
/// and unknown numbers.
pub fn component_name(component: u32) -> &'static str {
    match component {
        1 => "i1",
        2 => "i16",
        3 => "u16",
        4 => "i32",
        5 => "u32",
        6 => "i64",
        7 => "u64",
        8 => "f16",
        9 => "f32",
        10 => "f64",
        11 => "snorm_f16",
        12 => "unorm_f16",
        13 => "snorm_f32",
        14 => "unorm_f32",
        15 => "snorm_f64",
        16 => "unorm_f64",
        17 => "p32i8",
        18 => "p32u8",
        _ => "invalid",
    }
}

/// The name dxc's listing gives a resource kind's dimension (`DxilResourceBase::GetResDimName`: 2 `2d`, 10 `buf`, 12
/// `structbuf`, ...); `invalid` for 0 and unknown numbers.
pub fn dimension_name(kind: u32) -> &'static str {
    match kind {
        1 => "1d",
        2 => "2d",
        3 => "2dMS",
        4 => "3d",
        5 => "cube",
        6 => "1darray",
        7 => "2darray",
        8 => "2darrayMS",
        9 => "cubearray",
        10 => "buf",
        11 => "rawbuf",
        12 => "structbuf",
        13 => "cbuffer",
        14 => "sampler",
        15 => "tbuffer",
        16 => "ras",
        17 => "fbtex2d",
        18 => "fbtex2darray",
        _ => "invalid",
    }
}

/// The elements of a signature part (`ISG1`, `OSG1` or `PSG1`): a count and the offset of the first record, then
/// records of 32 bytes (stream, name offset, semantic index, system value, component type, register, mask and
/// read-write mask, minimum precision). A name ends within 256 bytes.
pub fn signature(part: &[u8]) -> Result<Vec<SignatureElement>> {
    let bit = |byte: usize| byte.saturating_mul(8);
    let v = primase_foundations::bytes::View::new(part);
    let word = |at: usize| -> Result<u32> {
        v.array::<4>(at)
            .map(u32::from_le_bytes)
            .map_err(|e| error(bit(at), e.to_string()))
    };
    // the word `delta` bytes after a record's start
    let field = |record: usize, delta: usize| -> Result<u32> {
        word(
            record
                .checked_add(delta)
                .ok_or_else(|| error(bit(record), "signature element offset"))?,
        )
    };
    let n = word(0)? as usize;
    let first = word(4)? as usize;
    // the records lie in the part: bound the count before anything is allocated
    let table = n
        .checked_mul(32)
        .and_then(|size| first.checked_add(size))
        .filter(|&end| end <= part.len())
        .ok_or_else(|| {
            error(
                0,
                format!(
                    "{n} records of 32 bytes from byte {first} do not fit the part's {} bytes",
                    part.len()
                ),
            )
        })?;
    let mut out = Vec::with_capacity(n);
    for i in 0..n {
        let e = i
            .checked_mul(32)
            .and_then(|o| o.checked_add(first))
            .filter(|&e| e < table)
            .ok_or_else(|| error(32, "signature element offset"))?;
        let name_at = field(e, 4)? as usize;
        let tail = part
            .get(name_at..)
            .ok_or_else(|| error(bit(name_at), "signature name offset"))?;
        let end = tail
            .iter()
            .position(|&b| b == 0)
            .filter(|&n| n <= 256)
            .ok_or_else(|| error(bit(name_at), "signature name"))?;
        let name = tail
            .get(..end)
            .and_then(|name| std::str::from_utf8(name).ok())
            .ok_or_else(|| error(bit(name_at), "signature name is not UTF-8"))?;
        let [mask, read_write_mask] = v
            .array::<2>(
                e.checked_add(24)
                    .ok_or_else(|| error(bit(e), "signature element offset"))?,
            )
            .map_err(|x| error(bit(e), x.to_string()))?;
        out.push(SignatureElement {
            stream: field(e, 0)?,
            name: name.to_owned(),
            index: field(e, 8)?,
            system_value: field(e, 12)?,
            component_type: field(e, 16)?,
            register: field(e, 20)?,
            mask,
            read_write_mask,
            bit: bit(e),
        });
    }
    Ok(out)
}

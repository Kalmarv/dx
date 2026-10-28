//! The pipeline state validation (`PSV0`) part of a Shader Model 6 program container: the runtime information, resource
//! records and signature elements a pipeline is validated against, which the validator writes from the program's own
//! metadata. Little-endian.
//!
//! ```text
//! u32 runtime-info size (36, 48 or 52), then the runtime info
//! u32 resource count; when it is not zero, u32 record size (16 or 24), then the records
//! u32 string-table size, then the table
//! u32 semantic-index count, then the indices (u32 each)
//! u32 element size (16) when there are any input, output or patch-constant elements, then the input, the output and
//!   the patch-constant elements
//! the rest: the input-to-output dependency tables, as words
//! ```
//!
//! The runtime info is 16 bytes whose meaning depends on the stage, the lowest and highest wave lane counts (u32 each),
//! then from 36 bytes the stage (u8), the uses-view-id flag (u8), a u16 (a geometry program's largest output vertex
//! count; in the low byte a hull or domain program's patch-constant vector count), the input, output and
//! patch-constant element counts (u8 each), the input vector count (u8) and four output vector counts (u8 each), from
//! 48 bytes the thread group size (three u32), and at 52 bytes the offset of the entry point's name in the string table.
//! The stage-dependent 16 bytes are: vertex, whether an `SV_Position` output exists (word 3); pixel, whether it writes
//! depth (byte 0) and whether it shades per sample (byte 1); hull, the input and output control point counts, the
//! domain and the output primitive; domain, the input control point count; geometry, the input primitive, the output
//! topology, the output stream mask and whether it writes a position. The record sizes follow the validator that wrote
//! the part: validator 1.5 writes a 36-byte runtime info and 16-byte resource records, 1.6 writes 48 and 24, and 1.10
//! writes 52 and 24 (the 16-byte records have no kind or flags). The reader reads these three sizes only.
//!
//! Every field above was checked against the metadata of the same program in the stock containers of skate. (19,240
//! with a `PSV0` part, validator 1.10) and Elden Ring (46,002; 10 with validator 1.5, 45,992 with 1.6): the layout
//! consumes each part to its last byte, and the stage, the thread group, the resource ranges, the elements' name,
//! semantic indices, size, kind, interpolation and placement, the vector counts and the stage unions equal what
//! [`crate::reflection`] reads from the metadata. The dependency tables are kept as stored words; the part's remainder
//! after the elements is as long as the vectors state (the input vectors' components times the words of the output
//! vectors' components).
use primase_foundations::bytes::View;

use crate::{Result, error};

/// Most resource records a part may state.
const MAX_RECORDS: usize = 1 << 20;

/// The runtime information of a `PSV0` part.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub struct RuntimeInfo {
    /// The stage-dependent 16 bytes, as four words (see the module documentation).
    pub stage_words: [u32; 4],
    /// The smallest wave lane count the program expects (0 where it states none).
    pub min_wave_lanes: u32,
    /// The largest wave lane count the program expects (`u32::MAX` where it states none).
    pub max_wave_lanes: u32,
    /// The shader kind (0 pixel, 1 vertex, 2 geometry, 3 hull, 4 domain, 5 compute, 13 mesh, ...), as in the program
    /// header.
    pub stage: u8,
    /// The program uses `SV_ViewID`.
    pub uses_view_id: bool,
    /// A geometry program's largest output vertex count; in the low byte a hull or domain program's patch-constant
    /// vector count.
    pub stage_data: u16,
    /// The input, output and patch-constant element counts as stored (the lengths of [`Psv::inputs`] and the others).
    pub element_counts: [u8; 3],
    /// How many input vectors (registers) the program reads.
    pub input_vectors: u8,
    /// How many output vectors it writes, per stream.
    pub output_vectors: [u8; 4],
    /// The thread group size, from 48 bytes of runtime info.
    pub num_threads: Option<[u32; 3]>,
    /// The offset of the entry point's name in the string table, from 52 bytes of runtime info.
    pub entry_name: Option<u32>,
}

/// A resource record.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub struct Resource {
    /// 1 sampler, 2 constant buffer, 3 typed SRV, 4 raw SRV, 5 structured SRV, 6 typed UAV, 7 raw UAV, 8 structured UAV,
    /// 9 structured UAV with a counter.
    pub resource_type: u32,
    /// The register space.
    pub space: u32,
    /// The first register.
    pub lower: u32,
    /// The last register (`u32::MAX` for an unbounded range).
    pub upper: u32,
    /// The resource kind (the metadata's `DxilResourceKind` for an SRV or UAV, 13 for a constant buffer, 14 for a
    /// sampler), in the 24-byte record only.
    pub kind: Option<u32>,
    /// The record's flags, in the 24-byte record only.
    pub flags: Option<u32>,
}

/// A signature element record (16 bytes).
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub struct Element {
    /// The offset of the semantic name in the string table (an empty string for a system value).
    pub name: u32,
    /// The offset of the element's first semantic index in the semantic-index table.
    pub indices: u32,
    /// How many registers the element spans.
    pub rows: u8,
    /// The first register.
    pub start_row: u8,
    /// How many components of each register it uses.
    pub columns: u8,
    /// The first component (0 x to 3 w).
    pub start_column: u8,
    /// The packer placed the element in registers.
    pub allocated: bool,
    /// DXIL semantic kind (0 arbitrary, 3 `SV_Position`, ...).
    pub semantic_kind: u8,
    /// The component type (1 u32, 2 i32, 3 f32: not the metadata's numbers, which are 5, 4 and 9).
    pub component_type: u8,
    /// DXIL interpolation mode.
    pub interpolation: u8,
    /// The components indexed dynamically, a 4-bit mask.
    pub dynamic_index_mask: u8,
    /// The output stream (0 to 3).
    pub stream: u8,
    /// The record's last byte, as stored.
    pub reserved: u8,
}

/// A `PSV0` part.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct Psv {
    /// The runtime information.
    pub runtime: RuntimeInfo,
    /// The resource records, in the part's order (constant buffers, samplers, SRVs, UAVs).
    pub resources: Vec<Resource>,
    /// The string table: names, null-terminated.
    pub strings: Vec<u8>,
    /// The semantic-index table.
    pub semantic_indices: Vec<u32>,
    /// The input elements.
    pub inputs: Vec<Element>,
    /// The output elements.
    pub outputs: Vec<Element>,
    /// The patch-constant elements.
    pub patch_constants: Vec<Element>,
    /// The part after the elements: the dependency tables, as words.
    pub dependencies: Vec<u32>,
}

impl Psv {
    /// The string at `offset` of the string table (an error where it is outside the table, has no end, or is not UTF-8).
    pub fn string(&self, offset: u32) -> Result<&str> {
        let rest = usize::try_from(offset)
            .ok()
            .and_then(|at| self.strings.get(at..))
            .ok_or_else(|| error(0, format!("PSV0: string {offset} past the string table")))?;
        let end = rest
            .iter()
            .position(|b| *b == 0)
            .ok_or_else(|| error(0, "PSV0: a string without its end"))?;
        std::str::from_utf8(rest.get(..end).unwrap_or_default())
            .map_err(|_| error(0, "PSV0: a string that is not UTF-8"))
    }

    /// The semantic indices of `element`, one for each of its rows.
    pub fn element_indices(&self, element: &Element) -> Result<&[u32]> {
        usize::try_from(element.indices)
            .ok()
            .and_then(|start| {
                let end = start.checked_add(usize::from(element.rows))?;
                self.semantic_indices.get(start..end)
            })
            .ok_or_else(|| error(0, "PSV0: an element's semantic indices lie past the index table"))
    }
}

/// Reads the `PSV0` part `data`. Anything outside the layout above (a runtime info or record of another size, a table
/// past the part's end, a remainder that is not whole words) is an error naming the bit.
pub fn read(data: &[u8]) -> Result<Psv> {
    let view = View::new(data);
    let bit = |at: usize| at.saturating_mul(8);
    let word = |at: usize| -> Result<u32> {
        view.array::<4>(at)
            .map(u32::from_le_bytes)
            .map_err(|e| error(bit(at), format!("PSV0: {e}")))
    };
    let count = |at: usize, what: &str| -> Result<usize> {
        usize::try_from(word(at)?).map_err(|_| error(bit(at), format!("PSV0: {what} past the address space")))
    };
    let advance = |at: usize, by: usize| {
        at.checked_add(by)
            .ok_or_else(|| error(bit(at), "PSV0: a table past the address space"))
    };

    let info_size = count(0, "the runtime info size")?;
    let mut at = 4usize;
    if !matches!(info_size, 36 | 48 | 52) {
        return Err(error(
            0,
            format!("PSV0: a runtime info of {info_size} bytes, where only 36, 48 and 52 are read"),
        ));
    }
    let info = view
        .slice(at, info_size)
        .map_err(|e| error(bit(at), format!("PSV0: {e}")))?;
    let info_word = |i: usize| -> Result<u32> {
        let start = i.saturating_mul(4);
        info.get(start..start.saturating_add(4))
            .and_then(|w| <[u8; 4]>::try_from(w).ok())
            .map(u32::from_le_bytes)
            .ok_or_else(|| error(bit(at), "PSV0: the runtime info is cut short"))
    };
    let byte = |i: usize| -> Result<u8> {
        info.get(i)
            .copied()
            .ok_or_else(|| error(bit(at), "PSV0: the runtime info is cut short"))
    };
    let runtime = RuntimeInfo {
        stage_words: [info_word(0)?, info_word(1)?, info_word(2)?, info_word(3)?],
        min_wave_lanes: info_word(4)?,
        max_wave_lanes: info_word(5)?,
        stage: byte(24)?,
        uses_view_id: byte(25)? != 0,
        stage_data: u16::from_le_bytes([byte(26)?, byte(27)?]),
        element_counts: [byte(28)?, byte(29)?, byte(30)?],
        input_vectors: byte(31)?,
        output_vectors: [byte(32)?, byte(33)?, byte(34)?, byte(35)?],
        num_threads: if info_size >= 48 {
            Some([info_word(9)?, info_word(10)?, info_word(11)?])
        } else {
            None
        },
        entry_name: if info_size >= 52 {
            Some(info_word(12)?)
        } else {
            None
        },
    };
    at = advance(at, info_size)?;

    let resource_count = count(at, "the resource count")?;
    at = advance(at, 4)?;
    let mut resources = Vec::new();
    if resource_count > 0 {
        if resource_count > MAX_RECORDS {
            return Err(error(bit(at), format!("PSV0: {resource_count} resource records")));
        }
        let size = count(at, "the resource record size")?;
        at = advance(at, 4)?;
        if !matches!(size, 16 | 24) {
            return Err(error(
                bit(at),
                format!("PSV0: resource records of {size} bytes, where only 16 and 24 are read"),
            ));
        }
        for _ in 0..resource_count {
            let long = size == 24;
            resources.push(Resource {
                resource_type: word(at)?,
                space: word(advance(at, 4)?)?,
                lower: word(advance(at, 8)?)?,
                upper: word(advance(at, 12)?)?,
                kind: if long { Some(word(advance(at, 16)?)?) } else { None },
                flags: if long { Some(word(advance(at, 20)?)?) } else { None },
            });
            at = advance(at, size)?;
        }
    }

    let strings_size = count(at, "the string table size")?;
    at = advance(at, 4)?;
    let strings = view
        .slice(at, strings_size)
        .map_err(|e| error(bit(at), format!("PSV0: {e}")))?
        .to_vec();
    at = advance(at, strings_size)?;

    let index_count = count(at, "the semantic index count")?;
    at = advance(at, 4)?;
    let index_bytes = view
        .slice(
            at,
            index_count
                .checked_mul(4)
                .ok_or_else(|| error(bit(at), "PSV0: the semantic index count"))?,
        )
        .map_err(|e| error(bit(at), format!("PSV0: {e}")))?;
    let semantic_indices = index_bytes
        .as_chunks::<4>()
        .0
        .iter()
        .map(|w| u32::from_le_bytes(*w))
        .collect();
    at = advance(at, index_bytes.len())?;

    let mut elements = [Vec::new(), Vec::new(), Vec::new()];
    if runtime.element_counts.iter().any(|n| *n > 0) {
        let size = count(at, "the element size")?;
        at = advance(at, 4)?;
        if size != 16 {
            return Err(error(
                bit(at),
                format!("PSV0: signature elements of {size} bytes, where only 16 are read"),
            ));
        }
        for (list, n) in elements.iter_mut().zip(runtime.element_counts) {
            for _ in 0..n {
                let raw = view
                    .array::<16>(at)
                    .map_err(|e| error(bit(at), format!("PSV0: {e}")))?;
                let [
                    n0,
                    n1,
                    n2,
                    n3,
                    i0,
                    i1,
                    i2,
                    i3,
                    rows,
                    start_row,
                    packed,
                    kind,
                    component,
                    interpolation,
                    masks,
                    reserved,
                ] = raw;
                list.push(Element {
                    name: u32::from_le_bytes([n0, n1, n2, n3]),
                    indices: u32::from_le_bytes([i0, i1, i2, i3]),
                    rows,
                    start_row,
                    columns: packed & 15,
                    start_column: (packed >> 4) & 3,
                    allocated: (packed >> 6) & 1 == 1,
                    semantic_kind: kind,
                    component_type: component,
                    interpolation,
                    dynamic_index_mask: masks & 15,
                    stream: (masks >> 4) & 3,
                    reserved,
                });
                at = advance(at, 16)?;
            }
        }
    }
    let [inputs, outputs, patch_constants] = elements;

    let rest = data.get(at..).unwrap_or_default();
    let (words, ragged) = rest.as_chunks::<4>();
    if !ragged.is_empty() {
        return Err(error(
            bit(at),
            format!(
                "PSV0: {} bytes after the elements, not a whole number of words",
                rest.len()
            ),
        ));
    }
    Ok(Psv {
        runtime,
        resources,
        strings,
        semantic_indices,
        inputs,
        outputs,
        patch_constants,
        dependencies: words.iter().map(|w| u32::from_le_bytes(*w)).collect(),
    })
}

/// The `PSV0` part of a container's directory, if it has one (a library has none; it has runtime data, [`crate::rdat`]).
pub fn part(chunks: &[dxcontainer::Chunk<'_>]) -> Result<Option<Psv>> {
    chunks
        .iter()
        .find(|c| &c.kind == b"PSV0")
        .map(|c| read(c.data))
        .transpose()
}

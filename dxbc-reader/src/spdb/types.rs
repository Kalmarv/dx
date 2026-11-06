//! The type records of the PDB's type stream (TPI, stream 2), as far as the listing needs them: the path of the
//! member, element and component a byte offset of a variable falls in (`.color.y`, `[2]`, `._m01`), as Microsoft's
//! disassembler finds it, the paths it cannot find included.
//!
//! The stream is a header (its size at byte 4, the first type index at 8, the records' size at 16), then records of
//! a 16-bit length (counting the kind), a 16-bit kind and the data, numbered from the first type index on.
use std::collections::BTreeMap;

use super::msf::Stream;
use crate::Result;

const LANES: [char; 4] = ['x', 'y', 'z', 'w'];

/// The name of component `n` of a vector: `x` to `w`, and `w` past it (no HLSL vector has more than four).
fn lane(n: u32) -> char {
    LANES
        .get(usize::try_from(n).unwrap_or(usize::MAX))
        .copied()
        .unwrap_or('w')
}

/// `LF_MODIFIER`: the modified type at 0.
const MODIFIER: u16 = 0x1518;
/// `LF_ALIAS`: a `typedef`, the type it names at 0.
const ALIAS: u16 = 0x150a;
/// `LF_CLASS`: as `LF_STRUCTURE`.
const CLASS: u16 = 0x1504;
/// `LF_STRUCTURE`: the member count at 0, the properties at 2 (bit 7 a forward reference, whose field list is 0), the
/// field list at 4, the size (a numeric leaf) at 16, then the name.
const STRUCTURE: u16 = 0x1505;
/// `LF_FIELDLIST`: member records back to back, each padded with bytes 0xf1 to 0xff.
const FIELD_LIST: u16 = 0x1203;
/// `LF_MEMBER`: attributes, the member's type at 2, its offset (a numeric leaf) at 6, then its name.
const MEMBER: u16 = 0x150d;
/// `LF_BCLASS`: a base class, as `LF_MEMBER` with no name; its members are the class's own.
const BASE_CLASS: u16 = 0x1400;
/// `LF_BINTERFACE`: an interface the class implements, as `LF_BCLASS`; it holds no data.
const BASE_INTERFACE: u16 = 0x151a;
/// `LF_STMEMBER`: a static member, attributes, its type at 2, then its name; no data in the struct.
const STATIC_MEMBER: u16 = 0x150e;
/// `LF_METHOD`: overloaded methods, their count, their method list at 2, then their name.
const METHOD: u16 = 0x150f;
/// `LF_NESTTYPE`: a type declared inside the struct, its index at 2, then its name.
const NESTED_TYPE: u16 = 0x1510;
/// `LF_ONEMETHOD`: a method, attributes (bits 2 to 4 its kind: 4 and 6 introduce a virtual one, followed by its
/// offset in the virtual table), its type at 2, then its name.
const ONE_METHOD: u16 = 0x1511;
/// `LF_STRIDED_ARRAY`: the element type at 0, the stride at 8, the size (a numeric leaf) at 12.
const STRIDED_ARRAY: u16 = 0x1516;
/// `LF_HLSL`: an HLSL object type; the kind at 4 (`0x200` an interface pointer, `0x220` to `0x223` the minimum-precision
/// scalars), the size (a numeric leaf) at 8: four words for an interface pointer, none for a texture or a sampler.
const HLSL: u16 = 0x1517;
/// The `LF_HLSL` kind of an interface pointer.
const INTERFACE_POINTER: u16 = 0x200;
/// `LF_VECTOR`: the element type at 0, the count at 4, the size (a numeric leaf) at 8.
const VECTOR: u16 = 0x151b;
/// `LF_MATRIX`: the element type at 0, rows at 4, columns at 8, the major stride at 12, bit 0 of byte 16 row-major,
/// the size (a numeric leaf) at 17.
const MATRIX: u16 = 0x151c;

/// What Microsoft's disassembler reports where it cannot name a byte of a variable.
const STATIC: &str = "could not get UDT child offset in PDB";
const OVERRUN: &str = "offset overruns length for type in PDB";
const VECTOR_MEMBER: &str = "invalid vector member";

/// The name of a byte of a variable after the variable's own: the path to it, and where it could not be found the
/// internal error Microsoft's disassembler writes after the path so far.
#[derive(Debug, Default, PartialEq, Eq)]
pub(crate) struct Path {
    pub(crate) text: String,
    pub(crate) error: Option<&'static str>,
}

/// The type stream's records, by type index: where each record's data starts and its kind.
pub(crate) struct Types<'a> {
    stream: &'a Stream,
    records: BTreeMap<u32, (u16, usize, usize)>,
}

impl<'a> Types<'a> {
    pub(crate) fn read(stream: &'a Stream) -> Result<Self> {
        let header = stream.size(4)?;
        let mut index = stream.u32(8)?;
        let end = stream.plus(header, stream.size(16)?)?;
        let mut at = header;
        let mut records = BTreeMap::new();
        while at < end {
            let len = usize::from(stream.u16(at)?);
            let kind = stream.u16(stream.plus(at, 2)?)?;
            let next = stream.plus(at, len.saturating_add(2))?;
            if len < 2 || next > end {
                return Err(stream.fail(at, format!("a type record of {len} bytes past the records' end")));
            }
            records.insert(index, (kind, at.saturating_add(4), next));
            index = index.saturating_add(1);
            at = next;
        }
        Ok(Self { stream, records })
    }

    /// A numeric leaf at `at`: its value and the byte after it. A value under `0x8000` is the leaf itself; `LF_USHORT`
    /// (`0x8002`) and `LF_ULONG` (`0x8004`) are followed by it.
    fn numeric(&self, at: usize) -> Result<(u32, usize)> {
        let s = self.stream;
        match s.u16(at)? {
            n if n < 0x8000 => Ok((u32::from(n), s.plus(at, 2)?)),
            0x8002 => Ok((u32::from(s.u16(s.plus(at, 2)?)?), s.plus(at, 4)?)),
            0x8004 => Ok((s.u32(s.plus(at, 2)?)?, s.plus(at, 6)?)),
            leaf => Err(s.fail(
                at,
                format!("numeric leaf {leaf:#06x}, where 0x8002 and 0x8004 are the ones known"),
            )),
        }
    }

    /// Type `index` past its modifiers and aliases: its index, kind and where its data starts; a built-in scalar type
    /// (an index under 0x1000) has no record, so no kind.
    fn underlying(&self, index: u32) -> Result<(u32, Option<(u16, usize)>)> {
        let s = self.stream;
        let mut index = index;
        for _ in 0..64 {
            if index < 0x1000 {
                return Ok((index, None));
            }
            let &(kind, at, _) = self
                .records
                .get(&index)
                .ok_or_else(|| s.fail(0, format!("type index {index:#x} has no record")))?;
            match kind {
                MODIFIER | ALIAS => index = s.u32(at)?,
                _ => return Ok((index, Some((kind, at)))),
            }
        }
        Err(s.fail(0, format!("type {index:#x} is modified more than 64 deep")))
    }

    /// The size in bytes of type `index`: a built-in scalar's from its CodeView number (2, 4 or 8 bytes), the others'
    /// from their records.
    fn length(&self, index: u32) -> Result<u32> {
        let s = self.stream;
        let (index, record) = self.underlying(index)?;
        let Some((kind, at)) = record else {
            return Ok(match index & 0xff {
                0x41 | 0x76 | 0x77 => 8,
                0x46 | 0x72 | 0x73 => 2,
                _ => 4,
            });
        };
        let at = match kind {
            STRUCTURE | CLASS => {
                return self
                    .numeric(s.plus(self.defined(index, kind, at)?, 16)?)
                    .map(|(n, _)| n);
            }
            VECTOR | HLSL => s.plus(at, 8)?,
            STRIDED_ARRAY => s.plus(at, 12)?,
            MATRIX => s.plus(at, 17)?,
            _ => {
                return Err(s.fail(
                    at,
                    format!("type {index:#x} of kind {kind:#06x}, which the listing does not name"),
                ));
            }
        };
        Ok(self.numeric(at)?.0)
    }

    /// The number of values a variable of type `index` holds: a scalar or an HLSL object one (an interface pointer
    /// one for each of its four words), a vector, matrix or array one for each component or element, a struct those
    /// of its data members (its bases' included).
    fn values(&self, index: u32) -> Result<u32> {
        let s = self.stream;
        let (resolved, record) = self.underlying(index)?;
        let Some((kind, at)) = record else {
            return Ok(1);
        };
        Ok(match kind {
            VECTOR => s.u32(s.plus(at, 4)?)?,
            MATRIX => s.u32(s.plus(at, 4)?)?.saturating_mul(s.u32(s.plus(at, 8)?)?),
            STRIDED_ARRAY => {
                let stride = s.u32(s.plus(at, 8)?)?;
                // the last element may end before the stride does
                let count = self
                    .length(resolved)?
                    .saturating_add(stride.saturating_sub(1))
                    .checked_div(stride);
                count.unwrap_or(0).saturating_mul(self.values(s.u32(at)?)?)
            }
            HLSL if s.u16(s.plus(at, 4)?)? == INTERFACE_POINTER => 4,
            STRUCTURE | CLASS => {
                let list = s.u32(s.plus(self.defined(resolved, kind, at)?, 4)?)?;
                let mut total = 0u32;
                for ty in self.data_members(list)? {
                    total = total.saturating_add(self.values(ty)?);
                }
                total
            }
            _ => 1,
        })
    }

    /// The path of byte `offset` within a variable of type `index`, as Microsoft's disassembler finds it: none for a
    /// variable of one value; `.x` to `.w` for a vector's component (a one-component vector's too), `.name` and the
    /// member's own path for a struct (none for a base class), `[n]` and the element's path for an array, `._mRC` for a
    /// matrix's element, `.x` to `.w` for an interface pointer's words, and Microsoft's words for a minimum-precision
    /// scalar. It stops with an internal error at a struct with a static member before the one the offset is in, an
    /// offset past its type's size (a texture or sampler has none), and one inside a vector's component. Refuses an
    /// index without a record, a kind other than these, and nesting over 64 deep.
    pub(crate) fn path(&self, index: u32, offset: u32) -> Result<Path> {
        let mut out = Path::default();
        if self.values(index)? == 1 {
            return Ok(out);
        }
        let (mut index, mut offset) = (index, offset);
        let s = self.stream;
        for _ in 0..64 {
            if offset >= self.length(index)? {
                out.error = Some(OVERRUN);
                return Ok(out);
            }
            let (resolved, record) = self.underlying(index)?;
            // the built-in scalar types
            let Some((kind, at)) = record else {
                return Ok(out);
            };
            match kind {
                VECTOR => {
                    let count = s.u32(s.plus(at, 4)?)?;
                    let component = self.length(index)?.checked_div(count).unwrap_or(0);
                    match (offset.checked_div(component), offset.checked_rem(component)) {
                        (Some(n), Some(0)) => {
                            out.text.push('.');
                            out.text.push(lane(n));
                        }
                        _ => out.error = Some(VECTOR_MEMBER),
                    }
                    return Ok(out);
                }
                STRUCTURE | CLASS => {
                    let list = s.u32(s.plus(self.defined(resolved, kind, at)?, 4)?)?;
                    match self.member(list, offset)? {
                        Ok((member, ty, start)) => {
                            // a base class's members are the struct's own
                            if let Some(member) = member {
                                out.text.push('.');
                                out.text.push_str(&member);
                            }
                            index = ty;
                            offset = offset.saturating_sub(start);
                        }
                        Err(error) => {
                            out.error = Some(error);
                            return Ok(out);
                        }
                    }
                }
                MATRIX => {
                    let stride = s.u32(s.plus(at, 12)?)?;
                    let row_major = s.u8(s.plus(at, 16)?)? & 1 != 0;
                    let major = offset.checked_div(stride).unwrap_or(0);
                    let minor = offset.checked_rem(stride).unwrap_or(0) / 4;
                    let (row, column) = if row_major { (major, minor) } else { (minor, major) };
                    out.text.push_str(&format!("._m{row}{column}"));
                    return Ok(out);
                }
                HLSL => {
                    match s.u16(s.plus(at, 4)?)? {
                        INTERFACE_POINTER => {
                            out.text.push('.');
                            out.text.push(lane(offset / 4));
                        }
                        other => out
                            .text
                            .push_str(&format!("<unknown HLSL built-in {other} offset {offset}>")),
                    }
                    return Ok(out);
                }
                STRIDED_ARRAY => {
                    let element = s.u32(at)?;
                    let stride = s.u32(s.plus(at, 8)?)?;
                    out.text
                        .push_str(&format!("[{}]", offset.checked_div(stride).unwrap_or(0)));
                    offset = offset.checked_rem(stride).unwrap_or(0);
                    index = element;
                }
                _ => {
                    return Err(s.fail(
                        at,
                        format!("type {resolved:#x} of kind {kind:#06x}, which the listing does not name"),
                    ));
                }
            }
        }
        Err(s.fail(0, format!("type {index:#x} nests more than 64 deep")))
    }

    /// Where the data of the struct or class `index` of `kind` (its data at `at`) starts: its own, or for a forward
    /// reference that of the record of the same kind and name that is not one.
    fn defined(&self, index: u32, kind: u16, at: usize) -> Result<usize> {
        let s = self.stream;
        if s.u16(s.plus(at, 2)?)? & 0x80 == 0 {
            return Ok(at);
        }
        let name = |at: usize| -> Result<String> {
            let (_, name_at) = self.numeric(s.plus(at, 16)?)?;
            Ok(s.string(name_at)?.0)
        };
        let wanted = name(at)?;
        for &(other, data, _) in self.records.values() {
            if other == kind && s.u16(s.plus(data, 2)?)? & 0x80 == 0 && name(data)? == wanted {
                return Ok(data);
            }
        }
        Err(s.fail(
            at,
            format!("type {index:#x} is a forward reference to {wanted}, which no record defines"),
        ))
    }

    /// The types of the data members of field list `list` (its base classes' included), in order.
    fn data_members(&self, list: u32) -> Result<Vec<u32>> {
        let s = self.stream;
        let &(kind, mut at, end) = self
            .records
            .get(&list)
            .ok_or_else(|| s.fail(0, format!("field list {list:#x} has no record")))?;
        if kind != FIELD_LIST {
            return Err(s.fail(
                at,
                format!("type {list:#x} is of kind {kind:#06x}, where a field list is 0x1203"),
            ));
        }
        let mut out = Vec::new();
        while at < end {
            let leaf = s.u16(at)?;
            let mut next = self.member_end(at, leaf)?;
            if matches!(leaf, MEMBER | BASE_CLASS) {
                out.push(s.u32(s.plus(at, 4)?)?);
            }
            // padding bytes 0xf1 to 0xff up to the next member
            while next < end && s.u8(next)? >= 0xf0 {
                next = next.saturating_add(1);
            }
            at = next;
        }
        Ok(out)
    }

    /// Where the field list member of kind `leaf` at `at` ends.
    fn member_end(&self, at: usize, leaf: u16) -> Result<usize> {
        let s = self.stream;
        match leaf {
            MEMBER => s.string(self.numeric(s.plus(at, 8)?)?.1).map(|(_, after)| after),
            BASE_CLASS | BASE_INTERFACE => self.numeric(s.plus(at, 8)?).map(|(_, after)| after),
            STATIC_MEMBER | METHOD | NESTED_TYPE => Ok(s.string(s.plus(at, 8)?)?.1),
            ONE_METHOD => {
                let virtual_offset = matches!((s.u16(s.plus(at, 2)?)? >> 2) & 7, 4 | 6);
                Ok(s.string(s.plus(at, if virtual_offset { 12 } else { 8 })?)?.1)
            }
            _ => Err(s.fail(
                at,
                format!(
                    "field list member of kind {leaf:#06x}, where 0x1400, 0x150d to 0x1511 and 0x151a are the ones \
                     known"
                ),
            )),
        }
    }

    /// The data member of field list `list` that byte `offset` falls in, as Microsoft's disassembler finds it: the
    /// first whose bytes hold it (else the last that starts before it), with its name (none for a base class), its
    /// type and its offset; or the internal error of a static member before it. Methods, nested types and interfaces
    /// hold no data.
    #[allow(clippy::type_complexity)]
    fn member(
        &self,
        list: u32,
        offset: u32,
    ) -> Result<std::result::Result<(Option<String>, u32, u32), &'static str>> {
        let s = self.stream;
        let &(kind, mut at, end) = self
            .records
            .get(&list)
            .ok_or_else(|| s.fail(0, format!("field list {list:#x} has no record")))?;
        if kind != FIELD_LIST {
            return Err(s.fail(
                at,
                format!("type {list:#x} is of kind {kind:#06x}, where a field list is 0x1203"),
            ));
        }
        let mut before = None;
        while at < end {
            let leaf = s.u16(at)?;
            let mut next = self.member_end(at, leaf)?;
            match leaf {
                MEMBER | BASE_CLASS => {
                    let ty = s.u32(s.plus(at, 4)?)?;
                    let (start, after) = self.numeric(s.plus(at, 8)?)?;
                    let name = match leaf {
                        MEMBER => Some(s.string(after)?.0),
                        _ => None,
                    };
                    if let Some(into) = offset.checked_sub(start) {
                        if into < self.length(ty)? {
                            return Ok(Ok((name, ty, start)));
                        }
                        before = Some((name, ty, start));
                    }
                }
                // it has no offset, which Microsoft's disassembler takes for an error
                STATIC_MEMBER => return Ok(Err(STATIC)),
                _ => {}
            }
            // padding bytes 0xf1 to 0xff up to the next member
            while next < end && s.u8(next)? >= 0xf0 {
                next = next.saturating_add(1);
            }
            at = next;
        }
        before.map(Ok).ok_or_else(|| {
            s.fail(
                at,
                format!("field list {list:#x} has no member at offset {offset}"),
            )
        })
    }
}

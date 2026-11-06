//! The type records of the PDB's type stream (TPI, stream 2), as far as the listing needs them: the path of the
//! member, element and component a byte offset of a variable falls in (`.color.y`, `[2]`, `._m01`).
//!
//! The stream is a header (its size at byte 4, the first type index at 8, the records' size at 16), then records of
//! a 16-bit length (counting the kind), a 16-bit kind and the data, numbered from the first type index on.
use std::collections::BTreeMap;

use super::msf::Stream;
use crate::Result;

const LANES: [char; 4] = ['x', 'y', 'z', 'w'];

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
/// `LF_STRIDED_ARRAY`: the element type at 0, the stride at 8.
const STRIDED_ARRAY: u16 = 0x1516;
/// `LF_HLSL`: an HLSL object type; the kind at 4, `0x200` an interface pointer (four words).
const HLSL: u16 = 0x1517;
/// `LF_VECTOR`: the element type at 0, the count at 4, the size (a numeric leaf) at 8.
const VECTOR: u16 = 0x151b;
/// `LF_MATRIX`: the element type at 0, rows at 4, columns at 8, the major stride at 12, bit 0 of byte 16 row-major.
const MATRIX: u16 = 0x151c;

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

    /// The path of byte `offset` within type `index`: empty for a scalar and a one-component vector, `.y` for a
    /// vector's component, `.name` and the member's own path for a struct, `[n]` and the element's path for an array,
    /// `._mRC` for a matrix's element, `.x` to `.w` for an interface pointer's words. Refuses an index without a
    /// record, a kind other than these, and nesting over 64 deep.
    pub(crate) fn path(&self, index: u32, offset: u32) -> Result<String> {
        let mut out = String::new();
        let (mut index, mut offset) = (index, offset);
        for _ in 0..64 {
            // the indices under 0x1000 are the built-in scalar types
            if index < 0x1000 {
                return Ok(out);
            }
            let s = self.stream;
            let &(kind, at, _) = self
                .records
                .get(&index)
                .ok_or_else(|| s.fail(0, format!("type index {index:#x} has no record")))?;
            match kind {
                MODIFIER | ALIAS => index = s.u32(at)?,
                VECTOR => {
                    let count = s.u32(s.plus(at, 4)?)?;
                    let (size, _) = self.numeric(s.plus(at, 8)?)?;
                    let component = size.checked_div(count).unwrap_or(0);
                    if count > 1 && component > 0 {
                        let lane =
                            usize::try_from(offset.checked_div(component).unwrap_or(0)).unwrap_or(usize::MAX);
                        out.push('.');
                        out.push(
                            *LANES
                                .get(lane)
                                .ok_or_else(|| s.fail(at, format!("offset {offset} past a vector")))?,
                        );
                    }
                    return Ok(out);
                }
                STRUCTURE | CLASS => {
                    let list = s.u32(s.plus(at, 4)?)?;
                    let list = match s.u16(s.plus(at, 2)?)? & 0x80 != 0 {
                        true => self.definition(index, kind, at)?,
                        false => list,
                    };
                    let (member, ty, start) = self.member(list, offset)?;
                    // a base class's members are the struct's own
                    if let Some(member) = member {
                        out.push('.');
                        out.push_str(&member);
                    }
                    index = ty;
                    offset = offset.saturating_sub(start);
                }
                MATRIX => {
                    let stride = s.u32(s.plus(at, 12)?)?;
                    let row_major = s.u8(s.plus(at, 16)?)? & 1 != 0;
                    let major = offset.checked_div(stride).unwrap_or(0);
                    let minor = offset.checked_rem(stride).unwrap_or(0) / 4;
                    let (row, column) = if row_major { (major, minor) } else { (minor, major) };
                    out.push_str(&format!("._m{row}{column}"));
                    return Ok(out);
                }
                HLSL => {
                    if s.u16(s.plus(at, 4)?)? == 0x200 {
                        let lane = usize::try_from(offset / 4).unwrap_or(usize::MAX);
                        out.push('.');
                        out.push(*LANES.get(lane).ok_or_else(|| {
                            s.fail(at, format!("offset {offset} past an interface pointer"))
                        })?);
                    }
                    return Ok(out);
                }
                STRIDED_ARRAY => {
                    let element = s.u32(at)?;
                    let stride = s.u32(s.plus(at, 8)?)?;
                    out.push_str(&format!("[{}]", offset.checked_div(stride).unwrap_or(0)));
                    offset = offset.checked_rem(stride).unwrap_or(0);
                    index = element;
                }
                _ => {
                    return Err(s.fail(
                        at,
                        format!("type {index:#x} of kind {kind:#06x}, which the listing does not name"),
                    ));
                }
            }
        }
        Err(self
            .stream
            .fail(0, format!("type {index:#x} nests more than 64 deep")))
    }

    /// The field list of the struct or class a forward reference (type `index` of `kind`, its data at `at`) names: that
    /// of the record of the same kind and name that is not one.
    fn definition(&self, index: u32, kind: u16, at: usize) -> Result<u32> {
        let s = self.stream;
        let name = |at: usize| -> Result<String> {
            let (_, name_at) = self.numeric(s.plus(at, 16)?)?;
            Ok(s.string(name_at)?.0)
        };
        let wanted = name(at)?;
        for &(other, data, _) in self.records.values() {
            if other == kind && s.u16(s.plus(data, 2)?)? & 0x80 == 0 && name(data)? == wanted {
                return s.u32(s.plus(data, 4)?);
            }
        }
        Err(s.fail(
            at,
            format!("type {index:#x} is a forward reference to {wanted}, which no record defines"),
        ))
    }

    /// The data member of field list `list` that byte `offset` falls in: the last that starts at or before it, its name
    /// (none for a base class), its type and its offset. Static members, methods, nested types and interfaces hold no
    /// data.
    fn member(&self, list: u32, offset: u32) -> Result<(Option<String>, u32, u32)> {
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
        let mut best = None;
        while at < end {
            let leaf = s.u16(at)?;
            let ty = s.u32(s.plus(at, 4)?)?;
            let mut next = match leaf {
                MEMBER | BASE_CLASS | BASE_INTERFACE => {
                    let (start, after) = self.numeric(s.plus(at, 8)?)?;
                    let (name, after) = match leaf {
                        MEMBER => {
                            let (name, after) = s.string(after)?;
                            (Some(name), after)
                        }
                        _ => (None, after),
                    };
                    if leaf != BASE_INTERFACE && start <= offset {
                        best = Some((name, ty, start));
                    }
                    after
                }
                STATIC_MEMBER | METHOD | NESTED_TYPE => s.string(s.plus(at, 8)?)?.1,
                ONE_METHOD => {
                    let virtual_offset = matches!((s.u16(s.plus(at, 2)?)? >> 2) & 7, 4 | 6);
                    s.string(s.plus(at, if virtual_offset { 12 } else { 8 })?)?.1
                }
                _ => {
                    return Err(s.fail(
                        at,
                        format!(
                            "field list member of kind {leaf:#06x}, where 0x1400, 0x150d to 0x1511 and 0x151a are the \
                             ones known"
                        ),
                    ));
                }
            };
            // padding bytes 0xf1 to 0xff up to the next member
            while next < end && s.u8(next)? >= 0xf0 {
                next = next.saturating_add(1);
            }
            at = next;
        }
        best.ok_or_else(|| {
            s.fail(
                at,
                format!("field list {list:#x} has no member at offset {offset}"),
            )
        })
    }
}

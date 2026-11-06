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
/// `LF_STRUCTURE`: the field list at 4.
const STRUCTURE: u16 = 0x1505;
/// `LF_FIELDLIST`: member records back to back.
const FIELD_LIST: u16 = 0x1203;
/// `LF_MEMBER`: attributes, the member's type at 2, its offset (a numeric leaf) at 6, then its name.
const MEMBER: u16 = 0x150d;
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
                MODIFIER => index = s.u32(at)?,
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
                STRUCTURE => {
                    let list = s.u32(s.plus(at, 4)?)?;
                    let (member, ty, start) = self.member(list, offset)?;
                    out.push('.');
                    out.push_str(&member);
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

    /// The member of field list `list` that byte `offset` falls in: the last that starts at or before it, its type and
    /// its offset.
    fn member(&self, list: u32, offset: u32) -> Result<(String, u32, u32)> {
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
            if leaf != MEMBER {
                return Err(s.fail(
                    at,
                    format!("field list member of kind {leaf:#06x}, where 0x150d is the one known"),
                ));
            }
            let ty = s.u32(s.plus(at, 4)?)?;
            let (start, name_at) = self.numeric(s.plus(at, 8)?)?;
            let (name, mut next) = s.string(name_at)?;
            // padding bytes 0xf1 to 0xff up to the next member
            while next < end && s.u8(next)? >= 0xf0 {
                next = next.saturating_add(1);
            }
            if start <= offset {
                best = Some((name, ty, start));
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

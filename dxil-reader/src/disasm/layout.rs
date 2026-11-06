//! LLVM 3.7's `DataLayout` for the types of a module, as dxc changes it: the ABI alignment, store and allocation size
//! of a type and the field offsets of a struct, from the module's `target datalayout` string and LLVM's defaults for
//! what it leaves out. dxc aligns a vector as its element and sizes it as its elements' allocations (a `<3 x float>`
//! is 12 bytes aligned to 4), where LLVM rounds it to a power of two.
use crate::module::{Module, Type, TypeId};
use crate::{Result, error};

#[derive(Clone, Copy, PartialEq, Eq)]
enum Kind {
    Integer,
    Float,
    Aggregate,
}

/// A parsed data layout: the alignments it states (bytes) and the pointer's size and alignment.
pub(super) struct Layout {
    /// (kind, bit width, ABI alignment in bytes), LLVM's defaults overridden by the string.
    alignments: Vec<(Kind, u32, u64)>,
    pointer_bits: u64,
    pointer_align: u64,
}

/// A number of bits as bytes.
fn bytes(bits: &str, at: usize) -> Result<u64> {
    let v: u64 = bits
        .parse()
        .map_err(|_| error(at, format!("data layout: {bits:?} is not a number")))?;
    Ok(v / 8)
}

impl Layout {
    /// `DataLayout::reset` and `parseSpecifier`.
    pub(super) fn new(text: &str, at: usize) -> Result<Self> {
        let mut layout = Layout {
            alignments: vec![
                (Kind::Integer, 1, 1),
                (Kind::Integer, 8, 1),
                (Kind::Integer, 16, 2),
                (Kind::Integer, 32, 4),
                (Kind::Integer, 64, 4),
                (Kind::Float, 16, 2),
                (Kind::Float, 32, 4),
                (Kind::Float, 64, 8),
                (Kind::Float, 128, 16),
                (Kind::Aggregate, 0, 0),
            ],
            pointer_bits: 64,
            pointer_align: 8,
        };
        for spec in text.split('-').filter(|s| !s.is_empty()) {
            let (head, rest) = spec.split_at(1);
            let fields: Vec<&str> = rest.split(':').collect();
            let kind = match head {
                "i" => Kind::Integer,
                "f" => Kind::Float,
                "a" => Kind::Aggregate,
                "p" => {
                    // p[space]:size:abi[:pref], the default space only
                    if fields.first().is_some_and(|s| !s.is_empty() && *s != "0") {
                        continue;
                    }
                    let size = fields
                        .get(1)
                        .ok_or_else(|| error(at, format!("data layout: {spec:?}")))?;
                    layout.pointer_bits = size
                        .parse()
                        .map_err(|_| error(at, format!("data layout: {spec:?}")))?;
                    layout.pointer_align = bytes(fields.get(2).copied().unwrap_or(size), at)?;
                    continue;
                }
                // endianness, mangling, stack alignment, native integer widths, and vector alignments, which dxc's
                // vectors don't use: no bearing on sizes
                "e" | "E" | "m" | "S" | "n" | "v" => continue,
                _ => {
                    return Err(error(
                        at,
                        format!("data layout: the specifier {spec:?} is not read"),
                    ));
                }
            };
            let width: u32 = match fields.first() {
                Some(w) if !w.is_empty() => w
                    .parse()
                    .map_err(|_| error(at, format!("data layout: {spec:?}")))?,
                _ => 0,
            };
            let abi = bytes(
                fields
                    .get(1)
                    .ok_or_else(|| error(at, format!("data layout: {spec:?} without an alignment")))?,
                at,
            )?;
            match layout
                .alignments
                .iter_mut()
                .find(|(k, w, _)| *k == kind && *w == width)
            {
                Some(entry) => entry.2 = abi,
                None => layout.alignments.push((kind, width, abi)),
            }
        }
        Ok(layout)
    }

    /// `getAlignmentInfo` for a type of `bits` with ABI alignment.
    fn alignment_info(&self, m: &Module, kind: Kind, bits: u32, t: TypeId) -> Result<u64> {
        let mut best: Option<(u32, u64)> = None;
        let mut largest: Option<(u32, u64)> = None;
        for (k, w, abi) in &self.alignments {
            if *k == kind && *w == bits {
                return Ok(*abi);
            }
            if kind == Kind::Integer && *k == Kind::Integer {
                if *w > bits && best.is_none_or(|(bw, _)| *w < bw) {
                    best = Some((*w, *abi));
                }
                if largest.is_none_or(|(lw, _)| *w > lw) {
                    largest = Some((*w, *abi));
                }
            }
        }
        if let Some((_, abi)) = best.or(if kind == Kind::Integer { largest } else { None }) {
            return Ok(abi);
        }
        Ok(self.store_size(m, t)?.max(1).next_power_of_two())
    }

    /// `getABITypeAlignment`.
    pub(super) fn abi_align(&self, m: &Module, t: TypeId) -> Result<u64> {
        match m.types.get(t) {
            Some(Type::Pointer(..) | Type::Label) => Ok(self.pointer_align),
            Some(Type::Array(_, e)) => self.abi_align(m, *e),
            Some(Type::Struct { packed: true, .. }) => Ok(1),
            Some(Type::Struct { .. }) => {
                let aggregate = self
                    .alignments
                    .iter()
                    .find(|(k, _, _)| *k == Kind::Aggregate)
                    .map_or(0, |(_, _, a)| *a);
                Ok(aggregate.max(self.struct_layout(m, t)?.1))
            }
            Some(Type::Integer(w)) => self.alignment_info(m, Kind::Integer, *w, t),
            Some(Type::Half) => self.alignment_info(m, Kind::Float, 16, t),
            Some(Type::Float) => self.alignment_info(m, Kind::Float, 32, t),
            Some(Type::Double) => self.alignment_info(m, Kind::Float, 64, t),
            Some(Type::Vector(_, e)) => self.abi_align(m, *e),
            _ => Err(error(m.at, "a type without a layout")),
        }
    }

    /// `getTypeSizeInBits`.
    fn size_in_bits(&self, m: &Module, t: TypeId) -> Result<u64> {
        match m.types.get(t) {
            Some(Type::Pointer(..) | Type::Label) => Ok(self.pointer_bits),
            Some(Type::Array(n, e)) => Ok(self.alloc_size(m, *e)?.saturating_mul(8).saturating_mul(*n)),
            Some(Type::Struct { .. }) => Ok(self.struct_layout(m, t)?.0.saturating_mul(8)),
            Some(Type::Integer(w)) => Ok(u64::from(*w)),
            Some(Type::Half) => Ok(16),
            Some(Type::Float) => Ok(32),
            Some(Type::Double) => Ok(64),
            Some(Type::Vector(n, e)) => Ok(self.alloc_size(m, *e)?.saturating_mul(8).saturating_mul(*n)),
            _ => Err(error(m.at, "a type without a layout")),
        }
    }

    fn store_size(&self, m: &Module, t: TypeId) -> Result<u64> {
        Ok(self.size_in_bits(m, t)?.div_ceil(8))
    }

    /// `getTypeAllocSize`: the store size rounded up to the ABI alignment.
    pub(super) fn alloc_size(&self, m: &Module, t: TypeId) -> Result<u64> {
        let align = self.abi_align(m, t)?.max(1);
        Ok(self.store_size(m, t)?.div_ceil(align).saturating_mul(align))
    }

    /// `StructLayout`: a struct's size, alignment and field offsets.
    pub(super) fn struct_layout(&self, m: &Module, t: TypeId) -> Result<(u64, u64, Vec<u64>)> {
        let Some(Type::Struct { elements, packed, .. }) = m.types.get(t) else {
            return Err(error(m.at, "the layout of a type that is not a struct"));
        };
        let (mut size, mut align) = (0u64, 0u64);
        let mut offsets = Vec::with_capacity(elements.len());
        for e in elements {
            let field_align = if *packed { 1 } else { self.abi_align(m, *e)?.max(1) };
            size = size.div_ceil(field_align).saturating_mul(field_align);
            align = align.max(field_align);
            offsets.push(size);
            size = size.saturating_add(self.alloc_size(m, *e)?);
        }
        let align = align.max(1);
        Ok((size.div_ceil(align).saturating_mul(align), align, offsets))
    }
}

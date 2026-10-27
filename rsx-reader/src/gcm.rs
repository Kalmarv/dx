//! The 24-byte `CellGcmTexture` descriptor libgcm uses to describe a texture, read as data.
//!
//! Every field is big endian. The descriptor carries GPU address metadata (`offset`, `location`); both are kept as
//! stored and neither says anything about where a payload lies in a file. Whether a descriptor describes storage
//! that can be decoded is a separate question for the caller: this module reads the fields and refuses only a
//! descriptor of the wrong length.
//!
//! References for libgcm's vocabulary:
//! <https://github.com/ps3dev/PSL1GHT/blob/master/ppu/include/rsx/gcm_sys.h> (`gcmTexture`).

/// A descriptor of the wrong size.
#[derive(Clone, Debug, PartialEq, Eq, thiserror::Error)]
pub enum Error {
    /// A `CellGcmTexture` is exactly 24 bytes.
    #[error("CellGcmTexture requires 24 bytes, got {0}")]
    DescriptorLength(usize),
}

/// The 24-byte descriptor, including GPU address metadata.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub struct CellGcmTexture {
    /// The pixel format byte. Bit `0x20` (LN) selects linear storage with a constant base pitch and bit `0x40`
    /// (UN) selects unnormalized coordinates; the format proper is `format & !0x60`.
    pub format: u8,
    /// The mip count.
    pub mipmap: u8,
    /// 1, 2 or 3 (a volume).
    pub dimension: u8,
    /// 1 for a cube map.
    pub cubemap: u8,
    /// The libgcm component remap word; identity is `0xaae4`.
    pub remap: u32,
    /// The width in texels.
    pub width: u16,
    /// The height in texels.
    pub height: u16,
    /// The depth in texels (1 unless a volume).
    pub depth: u16,
    /// The memory location code, as stored.
    pub location: u8,
    /// The padding byte after the location, as stored.
    pub pad: u8,
    /// The base row pitch in bytes, meaningful for linear storage.
    pub pitch: u32,
    /// The GPU address offset, as stored.
    pub offset: u32,
}

impl CellGcmTexture {
    /// Parse exactly one descriptor as data.
    ///
    /// # Errors
    /// [`Error::DescriptorLength`] when `data` is not 24 bytes.
    pub fn parse(data: &[u8]) -> Result<Self, Error> {
        let &[
            format,
            mipmap,
            dimension,
            cubemap,
            r0,
            r1,
            r2,
            r3,
            w0,
            w1,
            h0,
            h1,
            d0,
            d1,
            location,
            pad,
            p0,
            p1,
            p2,
            p3,
            o0,
            o1,
            o2,
            o3,
        ] = <&[u8; 24]>::try_from(data).map_err(|_| Error::DescriptorLength(data.len()))?;
        Ok(Self {
            format,
            mipmap,
            dimension,
            cubemap,
            remap: u32::from_be_bytes([r0, r1, r2, r3]),
            width: u16::from_be_bytes([w0, w1]),
            height: u16::from_be_bytes([h0, h1]),
            depth: u16::from_be_bytes([d0, d1]),
            location,
            pad,
            pitch: u32::from_be_bytes([p0, p1, p2, p3]),
            offset: u32::from_be_bytes([o0, o1, o2, o3]),
        })
    }

    /// LN: linear storage with a constant base pitch.
    pub fn linear(self) -> bool {
        self.format & 0x20 != 0
    }

    /// UN: unnormalized sampling coordinates. It does not change pixel storage.
    pub fn unnormalized_coordinates(self) -> bool {
        self.format & 0x40 != 0
    }
}

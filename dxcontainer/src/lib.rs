//! Reader for the DXBC container, the file format Direct3D shader programs are stored in: Shader Model 4 and 5 programs
//! (`SHDR`, `SHEX`, signatures, `RDEF`) and Shader Model 6 programs (`DXIL`, `PSV0`, `RDAT`, ...) alike. [`chunks`] reads
//! the container's part directory and [`checksum`] computes the digest the compiler stores in it. [`feature_flags`]
//! reads the `SFI0` part, the shader's required features, with names for the bits ([`feature_name`]).
//!
//! The layout: a header (`DXBC`, a 16-byte digest, version 1, the container's size, the number of parts), the directory of
//! the parts' offsets right after it, then the parts one after another in the directory's order, each its four-character
//! kind, its length and its bytes, the last ending where the container does. Shader Model 6 parts are not padded to 4
//! bytes, so an offset need not be a multiple of 4. This holds for every fixture committed in `dxbc-reader` and `dxil-reader`
//! (the tests read each to its exact end and compare [`checksum`] with the stored digest).
//!
//! The reader reads to the exact end: a part anywhere else, a gap, a byte after the last part, a kind twice, a size other
//! than the container's or a version other than 1 is an [`Error`] naming the byte. The digest is not verified (it is not an
//! authenticity check); [`checksum`] is for a caller that wants to compare it.
//!
//! ```
//! // A container with one empty `ISGN` part: header, one directory entry, the part.
//! let mut bytes = b"DXBC".to_vec();
//! bytes.extend_from_slice(&[0; 16]); // digest
//! for word in [1u32, 44, 1, 36] {
//!     bytes.extend_from_slice(&word.to_le_bytes()); // version, size, part count, the part's offset
//! }
//! bytes.extend_from_slice(b"ISGN");
//! bytes.extend_from_slice(&0u32.to_le_bytes()); // the part's length
//!
//! let parts = dxcontainer::chunks(&bytes).expect("a well-formed container");
//! assert_eq!(&parts[0].kind, b"ISGN");
//! assert!(parts[0].data.is_empty());
//! assert!(dxcontainer::checksum(&bytes).is_some());
//! ```
#![deny(missing_docs)]
#![deny(clippy::disallowed_methods, clippy::disallowed_types)]
#![deny(
    clippy::arithmetic_side_effects,
    clippy::indexing_slicing,
    clippy::cast_possible_truncation
)]

use primase_foundations::bytes::View;

/// What is wrong with a container, and where (a byte offset in it).
#[derive(Clone, Debug, PartialEq, Eq, thiserror::Error)]
#[error("DXBC container at byte {offset}: {detail}")]
pub struct Error {
    /// The byte offset in the container where the problem is.
    pub offset: usize,
    /// What was expected there, or what was found instead.
    pub detail: String,
}

fn error(offset: usize, detail: impl Into<String>) -> Error {
    Error {
        offset,
        detail: detail.into(),
    }
}

/// A part of a container: its four-character kind and its bytes.
#[derive(Clone, Copy, Debug)]
pub struct Chunk<'a> {
    /// The part's four-character kind (`DXIL`, `RDEF`, ...).
    pub kind: [u8; 4],
    /// The part's bytes, without its kind and length.
    pub data: &'a [u8],
}

/// The part directory of the container `bytes`, in the container's order. See the module documentation for what is refused.
pub fn chunks(bytes: &[u8]) -> Result<Vec<Chunk<'_>>, Error> {
    let view = View::new(bytes);
    let word = |at: usize| -> Result<usize, Error> {
        let word = view.array::<4>(at).map_err(|e| error(at, e.to_string()))?;
        usize::try_from(u32::from_le_bytes(word)).map_err(|_| error(at, "a word past the address space"))
    };
    if bytes.get(..4) != Some(b"DXBC") {
        return Err(error(0, "the magic is not DXBC"));
    }
    if word(20)? != 1 {
        return Err(error(20, "the container's version is not 1"));
    }
    if word(24)? != bytes.len() {
        return Err(error(
            24,
            format!(
                "the container states a size of {}, it has {} bytes",
                word(24)?,
                bytes.len()
            ),
        ));
    }
    let count = word(28)?;
    let directory_end = count
        .checked_mul(4)
        .and_then(|n| n.checked_add(32))
        .filter(|end| *end <= bytes.len())
        .ok_or_else(|| {
            error(
                28,
                format!("a directory of {count} parts does not fit the container"),
            )
        })?;
    let mut parts: Vec<Chunk<'_>> = Vec::new();
    let mut next = directory_end;
    for i in 0..count {
        let entry = i
            .checked_mul(4)
            .and_then(|n| n.checked_add(32))
            .ok_or_else(|| error(28, "a directory past the address space"))?;
        let start = word(entry)?;
        if start != next {
            let shown = view.array::<4>(start).map_or_else(
                |_| "past the end".to_owned(),
                |kind| String::from_utf8_lossy(&kind).into_owned(),
            );
            return Err(error(
                entry,
                if start < next {
                    format!(
                        "overlapping parts: part {i} ({shown}) starts at {start}, before the previous part ends at {next}"
                    )
                } else {
                    format!(
                        "{} bytes between parts: part {i} ({shown}) starts at {start}, where the previous part ends at {next}",
                        start.saturating_sub(next)
                    )
                },
            ));
        }
        let kind = view.array::<4>(start).map_err(|e| error(start, e.to_string()))?;
        let shown = String::from_utf8_lossy(&kind).into_owned();
        let length = word(
            start
                .checked_add(4)
                .ok_or_else(|| error(start, "a part past the address space"))?,
        )?;
        let data_at = start
            .checked_add(8)
            .ok_or_else(|| error(start, "a part past the address space"))?;
        let data = view
            .slice(data_at, length)
            .map_err(|e| error(start, format!("part {i} ({shown}): {e}")))?;
        if parts.iter().any(|p| p.kind == kind) {
            return Err(error(start, format!("a part kind twice: {shown}")));
        }
        next = data_at
            .checked_add(length)
            .ok_or_else(|| error(start, "a part past the address space"))?;
        parts.push(Chunk { kind, data });
    }
    if next != bytes.len() {
        return Err(error(
            next,
            format!("{} bytes after the last part", bytes.len().saturating_sub(next)),
        ));
    }
    Ok(parts)
}

/// The digest a container stores at bytes 4 to 20: MD5's block function over its bytes from 20 on, the last block padded as the
/// compiler does (the bit count first, then the rest, `0x80`, zeros, and at 60 the bit count over 4, or 1; a rest of 56 bytes
/// or more padded in a block of its own first). `None` for fewer than 20 bytes.
pub fn checksum(container: &[u8]) -> Option<[u8; 16]> {
    let data = container.get(20..)?;
    let bits = u32::try_from(data.len()).ok()?.wrapping_mul(8);
    let (blocks, rest) = data.as_chunks::<64>();
    let mut state = primase_foundations::hash::MD5_INIT;
    for block in blocks {
        primase_foundations::hash::md5_block(&mut state, block);
    }
    let mut last = [0u8; 64];
    if rest.len() < 56 {
        last.get_mut(4..)?.get_mut(..rest.len())?.copy_from_slice(rest);
        *last.get_mut(rest.len().checked_add(4)?)? = 0x80;
    } else {
        let mut first = [0u8; 64];
        first.get_mut(..rest.len())?.copy_from_slice(rest);
        *first.get_mut(rest.len())? = 0x80;
        primase_foundations::hash::md5_block(&mut state, &first);
    }
    last.get_mut(..4)?.copy_from_slice(&bits.to_le_bytes());
    last.get_mut(60..)?
        .copy_from_slice(&((bits >> 2) | 1).to_le_bytes());
    primase_foundations::hash::md5_block(&mut state, &last);
    Some(primase_foundations::hash::md5_bytes(state))
}

/// Which bytecode a container's program part holds. It decides what the bits of the container's `SFI0` part name: the
/// two compilers share the first bits and then diverge.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum Bytecode {
    /// Shader Model 4 or 5 (`fxc`): an `SHDR` or `SHEX` part.
    Dxbc,
    /// Shader Model 6 (`dxc`): a `DXIL` part.
    Dxil,
}

impl Bytecode {
    /// The bytecode `parts` hold: `None` for a container with no program part or with both kinds.
    pub fn of(parts: &[Chunk<'_>]) -> Option<Self> {
        let has = |kinds: &[&[u8; 4]]| parts.iter().any(|p| kinds.contains(&&p.kind));
        match (has(&[b"SHDR", b"SHEX"]), has(&[b"DXIL"])) {
            (true, false) => Some(Self::Dxbc),
            (false, true) => Some(Self::Dxil),
            _ => None,
        }
    }
}

/// The name of bit `bit` of the `SFI0` shader feature flags of `bytecode`, `None` for a bit with no name here.
///
/// A name is the description the producing compiler prints for the flag. Every named bit was read off the compiler's
/// own output: programs that need one feature each were compiled with `fxc` (Shader Model 4.0 to 5.0) and `dxc`
/// (Shader Model 6.0 to 6.7), and each container's flags were compared with the compiler's own listing of what the
/// program requires. That covers bits 0 to 13 for `fxc` (bit 1 only with a Shader Model 4 pixel program that uses a
/// raw buffer; there it also sets the program's `enableRawAndStructuredBuffers` global flag) and, for `dxc`, bits 0,
/// 2 to 6, 8 to 20, 22 to 26 and 28 to 30. The unnamed bits (for `dxc` 1, 7, 21, 27 and everything from 31 on) were
/// produced by none of those programs.
///
/// In the games' stock containers (the 69,728 `DXIL` containers of skate. and Elden Ring, and 21 of Unity's 4,854
/// `DXBC` ones; Sekiro's and Riders Republic's have no `SFI0` part) the bits that occur are, for `DXIL`, 2, 3, 4, 11,
/// 14, 15, 20 and 25, and for `DXBC` 1 and 4. Against the program itself: bit 14 is set in every program that uses
/// wave or quad operations and in no other, bit 3 in every program that declares more than 8 UAV slots and no other,
/// bit 25 in every program that creates a handle from a descriptor heap and no other, bit 20 in every program that
/// uses a ray query (and in 16 that do not).
pub fn feature_name(bytecode: Bytecode, bit: u32) -> Option<&'static str> {
    let shared = match bit {
        0 => "Double-precision floating point",
        2 => "UAVs at every shader stage",
        3 => "64 UAV slots",
        4 => "Minimum-precision data types",
        5 => "Double-precision extensions for 11.1",
        6 => "Shader extensions for 11.1",
        8 => "Tiled resources",
        9 => "PS Output Stencil Ref",
        10 => "PS Inner Coverage",
        11 => "Typed UAV Load Additional Formats",
        12 => "Raster Ordered UAVs",
        13 => "SV_RenderTargetArrayIndex or SV_ViewportArrayIndex from any shader feeding rasterizer",
        _ => "",
    };
    if !shared.is_empty() {
        return Some(shared);
    }
    match bytecode {
        Bytecode::Dxbc => match bit {
            1 => Some("Raw and Structured buffers"),
            7 => Some("Comparison filtering for feature level 9"),
            _ => None,
        },
        Bytecode::Dxil => match bit {
            14 => Some("Wave level operations"),
            15 => Some("64-Bit integer"),
            16 => Some("View Instancing"),
            17 => Some("Barycentrics"),
            18 => Some("Use native low precision"),
            19 => Some("Shading Rate"),
            20 => Some("Raytracing tier 1.1 features"),
            22 => Some("64-bit Atomics on Typed Resources"),
            23 => Some("64-bit Atomics on Group Shared"),
            24 => Some("Derivatives in mesh and amplification shaders"),
            25 => Some("Resource descriptor heap indexing"),
            26 => Some("Sampler descriptor heap indexing"),
            28 => Some("64-bit Atomics on Heap Resources"),
            29 => Some("Advanced Texture Ops"),
            30 => Some("Writeable MSAA Textures"),
            _ => None,
        },
    }
}

/// A container's shader feature flags: its `SFI0` part (eight bytes, a little-endian `u64`) and the bytecode that says
/// what the bits mean.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub struct FeatureFlags {
    /// The bytecode of the container's program.
    pub bytecode: Bytecode,
    /// The flags as stored.
    pub bits: u64,
}

impl FeatureFlags {
    /// Whether bit `bit` is set.
    pub fn has(self, bit: u32) -> bool {
        self.bits.checked_shr(bit).is_some_and(|rest| rest & 1 == 1)
    }

    /// The names of the set bits that have one ([`feature_name`]), lowest bit first.
    pub fn names(self) -> Vec<&'static str> {
        (0..u64::BITS)
            .filter(|&b| self.has(b))
            .filter_map(|b| feature_name(self.bytecode, b))
            .collect()
    }

    /// The set bits that have no name, as a mask.
    pub fn unnamed(self) -> u64 {
        (0..u64::BITS)
            .filter(|&b| self.has(b) && feature_name(self.bytecode, b).is_none())
            .fold(0, |mask, b| mask | 1u64.checked_shl(b).unwrap_or(0))
    }
}

/// The shader feature flags of `container`: `None` for a container with no `SFI0` part (Sekiro's and Riders Republic's
/// `DXBC` containers have none; the part is there in all 69,728 `DXIL` containers of skate. and Elden Ring). Refuses a
/// container [`chunks`] refuses, an `SFI0` part of other than eight bytes, and an `SFI0` part in a container whose
/// bytecode is unknown (no program part, or both kinds): the bits mean nothing without it.
pub fn feature_flags(container: &[u8]) -> Result<Option<FeatureFlags>, Error> {
    let parts = chunks(container)?;
    let Some(part) = parts.iter().find(|p| &p.kind == b"SFI0") else {
        return Ok(None);
    };
    let at = part
        .data
        .as_ptr()
        .addr()
        .saturating_sub(container.as_ptr().addr());
    let bits = <[u8; 8]>::try_from(part.data)
        .map_err(|_| error(at, format!("the SFI0 part has {} bytes, not 8", part.data.len())))?;
    let bytecode = Bytecode::of(&parts).ok_or_else(|| {
        error(
            at,
            "an SFI0 part in a container with no single kind of program part",
        )
    })?;
    Ok(Some(FeatureFlags {
        bytecode,
        bits: u64::from_le_bytes(bits),
    }))
}

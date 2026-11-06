//! The multi-stream file (MSF 7.0) an `SPDB` part is: a superblock, then blocks of one size, which a directory
//! assembles into numbered streams.
//!
//! The superblock is 56 bytes: the 32-byte signature, then the words block size, free block map, block count, the
//! directory's size in bytes, a reserved word and the block that lists the directory's blocks. The directory is the
//! stream count, each stream's size (`0xffffffff` for none) and then each stream's blocks in stream order.
use crate::{Error, Result, error};

const SIGNATURE: &[u8; 32] = b"Microsoft C/C++ MSF 7.00\r\n\x1aDS\0\0\0";

/// One stream: its bytes in order, and where each block of it lies in the part, for errors.
pub(crate) struct Stream {
    name: String,
    pub(crate) data: Vec<u8>,
    blocks: Vec<usize>,
    block_size: usize,
}

impl Stream {
    /// The word of the part that byte `at` of the stream lies in.
    fn word(&self, at: usize) -> usize {
        let index = at.checked_div(self.block_size).unwrap_or(0);
        let within = at.checked_rem(self.block_size).unwrap_or(0);
        let block = self.blocks.get(index).copied().unwrap_or(0);
        block.saturating_mul(self.block_size).saturating_add(within) / 4
    }

    /// An error at byte `at` of the stream.
    pub(crate) fn fail(&self, at: usize, detail: impl std::fmt::Display) -> Error {
        error(self.word(at), format!("SPDB {} byte {at}: {detail}", self.name))
    }

    /// `len` bytes at `at`.
    pub(crate) fn bytes(&self, at: usize, len: usize) -> Result<&[u8]> {
        at.checked_add(len)
            .and_then(|end| self.data.get(at..end))
            .ok_or_else(|| {
                self.fail(
                    at,
                    format!("{len} bytes past the stream's {} bytes", self.data.len()),
                )
            })
    }

    fn array<const N: usize>(&self, at: usize) -> Result<[u8; N]> {
        self.bytes(at, N)?
            .try_into()
            .map_err(|_| self.fail(at, format!("{N} bytes")))
    }

    pub(crate) fn u8(&self, at: usize) -> Result<u8> {
        Ok(u8::from_le_bytes(self.array(at)?))
    }

    pub(crate) fn u16(&self, at: usize) -> Result<u16> {
        Ok(u16::from_le_bytes(self.array(at)?))
    }

    pub(crate) fn u32(&self, at: usize) -> Result<u32> {
        Ok(u32::from_le_bytes(self.array(at)?))
    }

    /// The 32-bit word at `at` as a size or an offset.
    pub(crate) fn size(&self, at: usize) -> Result<usize> {
        let value = self.u32(at)?;
        usize::try_from(value).map_err(|_| self.fail(at, format!("{value} exceeds the address space")))
    }

    /// `at + delta`, an error where it overflows.
    pub(crate) fn plus(&self, at: usize, delta: usize) -> Result<usize> {
        at.checked_add(delta)
            .ok_or_else(|| self.fail(at, format!("{delta} bytes further overflow the address space")))
    }

    /// The zero-terminated string at `at` (Latin-1, as the compiler writes paths), and the byte after its zero.
    pub(crate) fn string(&self, at: usize) -> Result<(String, usize)> {
        let tail = self.data.get(at..).ok_or_else(|| {
            self.fail(
                at,
                format!("a string past the stream's {} bytes", self.data.len()),
            )
        })?;
        let len = tail
            .iter()
            .position(|&b| b == 0)
            .ok_or_else(|| self.fail(at, "a string with no terminating zero in the stream"))?;
        let text = tail
            .get(..len)
            .unwrap_or_default()
            .iter()
            .map(|&b| char::from(b))
            .collect();
        Ok((text, at.saturating_add(len).saturating_add(1)))
    }
}

/// The streams of the MSF in `part`, by number; a stream the directory says is absent is empty. Refuses a part that
/// does not start with the MSF 7.0 signature, a block size other than 512, 1024, 2048 or 4096, and a block outside
/// the part.
pub(crate) fn streams(part: &[u8]) -> Result<Vec<Stream>> {
    if part.get(..32) != Some(SIGNATURE.as_slice()) {
        return Err(error(
            0,
            "the SPDB part does not start with the MSF 7.00 signature",
        ));
    }
    let word = |n: usize| -> Result<usize> {
        let at = 32usize.saturating_add(n.saturating_mul(4));
        part.get(at..at.saturating_add(4))
            .and_then(|b| b.try_into().ok())
            .map(u32::from_le_bytes)
            .and_then(|v| usize::try_from(v).ok())
            .ok_or_else(|| error(at / 4, "the SPDB part ends inside the MSF superblock"))
    };
    let block_size = word(0)?;
    if !matches!(block_size, 512 | 1024 | 2048 | 4096) {
        return Err(error(
            8,
            format!("MSF block size {block_size}, where it is 512, 1024, 2048 or 4096"),
        ));
    }
    let (directory_size, map_block) = (word(3)?, word(5)?);
    let block = |n: usize| -> Result<&[u8]> {
        n.checked_mul(block_size)
            .and_then(|at| part.get(at..at.checked_add(block_size)?))
            .ok_or_else(|| {
                error(
                    0,
                    format!("MSF block {n} lies outside the SPDB part's {} bytes", part.len()),
                )
            })
    };
    // the directory's blocks are listed in the block `map_block` names
    let count = directory_size.div_ceil(block_size);
    let map = block(map_block)?;
    let mut directory_blocks = Vec::new();
    for n in 0..count {
        let at = n.saturating_mul(4);
        let entry = map
            .get(at..at.saturating_add(4))
            .and_then(|b| b.try_into().ok())
            .map(u32::from_le_bytes)
            .and_then(|v| usize::try_from(v).ok())
            .ok_or_else(|| {
                error(
                    map_block.saturating_mul(block_size) / 4,
                    "the MSF directory's block list overflows its block",
                )
            })?;
        directory_blocks.push(entry);
    }
    let assemble = |name: String, blocks: Vec<usize>, size: usize| -> Result<Stream> {
        let mut data = Vec::with_capacity(size);
        for &n in &blocks {
            data.extend_from_slice(block(n)?);
        }
        data.truncate(size);
        Ok(Stream {
            name,
            data,
            blocks,
            block_size,
        })
    };
    let directory = assemble("stream directory".into(), directory_blocks, directory_size)?;
    let stream_count = directory.size(0)?;
    let mut at = directory.plus(4, stream_count.saturating_mul(4))?;
    let mut streams = Vec::new();
    for n in 0..stream_count {
        let size = directory.u32(4usize.saturating_add(n.saturating_mul(4)))?;
        let size = if size == 0xffff_ffff {
            0
        } else {
            usize::try_from(size)
                .map_err(|_| directory.fail(at, format!("stream {n}'s size exceeds the address space")))?
        };
        let mut blocks = Vec::new();
        for _ in 0..size.div_ceil(block_size) {
            blocks.push(directory.size(at)?);
            at = directory.plus(at, 4)?;
        }
        streams.push(assemble(format!("stream {n}"), blocks, size)?);
    }
    Ok(streams)
}

//! Readers for PlayStation 3 RSX graphics data: shader program containers (`CgBinaryProgram`, vertex and fragment), the
//! fragment program microcode inside them, and the `CellGcmTexture` texture descriptor. All data is big endian.
//!
//! The container reader keeps microcode encoded; it does not infer shader behaviour from parameter names. Everything a
//! reader cannot read is an error naming the byte offset (see [`cgbinary::Error`], [`fragment::Error`]). Layout sources and scope are in the
//! crate's README.
//!
//! ```
//! use rsx_reader::gcm::CellGcmTexture;
//!
//! // A 24-byte descriptor: format 0xA5 (linear), 1 mip, 2D, a 256x128 image, identity remap.
//! let mut bytes = [0u8; 24];
//! bytes[0] = 0xa5;
//! bytes[1] = 1;
//! bytes[2] = 2;
//! bytes[4..8].copy_from_slice(&0xaae4u32.to_be_bytes());
//! bytes[8..10].copy_from_slice(&256u16.to_be_bytes());
//! bytes[10..12].copy_from_slice(&128u16.to_be_bytes());
//! bytes[12..14].copy_from_slice(&1u16.to_be_bytes());
//!
//! let texture = CellGcmTexture::parse(&bytes).expect("exactly 24 bytes");
//! assert_eq!((texture.width, texture.height), (256, 128));
//! assert!(texture.linear());
//! ```
#![deny(
    clippy::arithmetic_side_effects,
    clippy::indexing_slicing,
    clippy::cast_possible_truncation
)]
#![deny(missing_docs)]
#![deny(clippy::disallowed_methods, clippy::disallowed_types)]

pub mod cgbinary;
pub mod fragment;
pub mod gcm;
pub mod vertex;

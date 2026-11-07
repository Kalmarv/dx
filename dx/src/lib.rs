//! What the `dx` command does, as functions its tests call in-process: finding programs and listing them
//! ([`files`]), checking listings against Microsoft's ([`check`]), and the reflection and container JSON of
//! `dx reflect` and `dx info` ([`reflect`]). Not published; the readers are the crates to depend on.
pub mod check;
pub mod files;
pub mod reflect;

//! Finding programs and their listings on disk, and telling a container from a Direct3D 9 token stream.
use std::path::{Path, PathBuf};

/// The extensions of listings, which a folder walk does not take for programs.
const LISTINGS: &[&str] = &["txt", "asm", "lst", "md", "toml", "json", "hlsl"];

/// `path` itself, or every file under the folder `path` that is not a listing, in name order.
pub fn programs(path: &Path) -> Result<Vec<PathBuf>, String> {
    if !path.is_dir() {
        return Ok(vec![path.to_owned()]);
    }
    let mut found = Vec::new();
    let mut folders = vec![path.to_owned()];
    while let Some(folder) = folders.pop() {
        let entries = std::fs::read_dir(&folder).map_err(|e| format!("{}: {e}", folder.display()))?;
        for entry in entries {
            let entry = entry.map_err(|e| format!("{}: {e}", folder.display()))?;
            let p = entry.path();
            if p.is_dir() {
                folders.push(p);
            } else if !p
                .extension()
                .and_then(|e| e.to_str())
                .is_some_and(|e| LISTINGS.contains(&e.to_ascii_lowercase().as_str()))
            {
                found.push(p);
            }
        }
    }
    found.sort();
    Ok(found)
}

/// Microsoft's listing of `program` stored beside it: `NAME.txt`, `NAME.asm`, or the program's file name with `.asm`
/// or `.txt` appended.
pub fn stored_listing(program: &Path) -> Option<PathBuf> {
    let mut candidates = vec![program.with_extension("txt"), program.with_extension("asm")];
    for ext in ["asm", "txt"] {
        let mut name = program.as_os_str().to_owned();
        name.push(".");
        name.push(ext);
        candidates.push(PathBuf::from(name));
    }
    candidates.into_iter().find(|p| p.is_file())
}

/// The listing of a program file: a `DXBC` container's Shader Model 4 or 5 program.
pub fn listing(bytes: &[u8]) -> Result<String, String> {
    if bytes.starts_with(b"DXBC") {
        return dxbc_reader::disassemble(bytes).map_err(|e| e.to_string());
    }
    Err("not a DXBC container".to_owned())
}

/// The shader model and stage a program's listing names on its version line (`ps_5_0`), for grouping counts.
pub fn target(listing: &str) -> Option<String> {
    listing
        .lines()
        .find(|l| {
            let l = l.trim_end();
            l.len() >= 6
                && !l.starts_with("//")
                && ["vs_", "ps_", "gs_", "hs_", "ds_", "cs_"].iter().any(|p| l.starts_with(p))
                && !l.contains(' ')
        })
        .map(|l| l.trim_end().to_owned())
}

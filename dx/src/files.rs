//! Finding programs and their listings on disk, and telling a container from a Direct3D 9 token stream.
use std::fs::File;
use std::io::Read;
use std::path::{Path, PathBuf};

/// The programs at `path`: `path` itself, or every file under the folder `path` that starts as a `DXBC` container or
/// a Direct3D 9 token stream does, in name order. Also the number of the folder's other files, which are left out.
pub fn programs(path: &Path) -> Result<(Vec<PathBuf>, usize), String> {
    if !path.is_dir() {
        return Ok((vec![path.to_owned()], 0));
    }
    let mut found = Vec::new();
    let mut others = 0usize;
    let mut folders = vec![path.to_owned()];
    while let Some(folder) = folders.pop() {
        let entries = std::fs::read_dir(&folder).map_err(|e| format!("{}: {e}", folder.display()))?;
        for entry in entries {
            let entry = entry.map_err(|e| format!("{}: {e}", folder.display()))?;
            let p = entry.path();
            if p.is_dir() {
                folders.push(p);
            } else if starts_as_program(&p)? {
                found.push(p);
            } else {
                others = others.saturating_add(1);
            }
        }
    }
    found.sort();
    Ok((found, others))
}

/// Whether the file's first four bytes are those of a `DXBC` container or a Direct3D 9 token stream. Listings never
/// are: a version token's `0xff` byte is not text.
fn starts_as_program(path: &Path) -> Result<bool, String> {
    let mut head = [0u8; 4];
    let mut file = File::open(path).map_err(|e| format!("{}: {e}", path.display()))?;
    match file.read_exact(&mut head) {
        Ok(()) => Ok(&head == b"DXBC" || d3d9_version(&head)),
        Err(e) if e.kind() == std::io::ErrorKind::UnexpectedEof => Ok(false),
        Err(e) => Err(format!("{}: {e}", path.display())),
    }
}

/// Microsoft's listing of `program` stored beside it. With no flags, the program's file name with `.asm` or `.txt`
/// appended, or else (when `shared_stem` is false) `NAME.txt` or `NAME.asm`; with flags, the same names with
/// `.flagNN.asm` (`NN` the flags word in two hex digits). `shared_stem` says that another program in the folder has
/// the same name but its extension (`NAME.vpo` beside `NAME.ppo`), so that only a listing named after the whole file
/// name is its own.
pub fn stored_listing(program: &Path, flags: u32, shared_stem: bool) -> Option<PathBuf> {
    let endings = if flags == 0 {
        vec!["asm".to_owned(), "txt".to_owned()]
    } else {
        vec![format!("flag{flags:02x}.asm")]
    };
    let whole = endings.iter().map(|ending| {
        let mut name = program.as_os_str().to_owned();
        name.push(".");
        name.push(ending);
        PathBuf::from(name)
    });
    let stem = endings
        .iter()
        .filter(|_| !shared_stem)
        .map(|ending| program.with_extension(ending));
    whole.chain(stem).find(|p| p.is_file())
}

/// What a program file is.
pub enum Kind {
    /// A `DXBC` container of a Shader Model 4 or 5 program.
    Dxbc,
    /// A `DXBC` container of a Shader Model 6 program (it has a `DXIL` part).
    Dxil,
    /// A Direct3D 9 token stream.
    D3d9,
}

/// Whether `bytes` are a `DXBC` container (of a Shader Model 4 or 5 program, or of a DXIL one) or a Direct3D 9 token
/// stream.
pub fn kind(bytes: &[u8]) -> Result<Kind, String> {
    if bytes.starts_with(b"DXBC") {
        let directory = dxcontainer::chunks(bytes).map_err(|e| e.to_string())?;
        return Ok(if directory.iter().any(|c| &c.kind == b"DXIL") {
            Kind::Dxil
        } else {
            Kind::Dxbc
        });
    }
    if d3d9_version(bytes) {
        return Ok(Kind::D3d9);
    }
    Err("neither a DXBC container nor a Direct3D 9 token stream".to_owned())
}

/// Whether `bytes` start as a Direct3D 9 token stream does, with its version token: 0xfffe (vertex) or 0xffff (pixel)
/// in the high half.
fn d3d9_version(bytes: &[u8]) -> bool {
    bytes
        .get(2..4)
        .is_some_and(|h| h == [0xfe, 0xff] || h == [0xff, 0xff])
}

/// The listing of a program file with Microsoft's `D3D_DISASM_*` `flags`: a `DXBC` container's Shader Model 4 or 5
/// program, or a Direct3D 9 token stream; a DXIL program's as `dxc -dumpbin` writes it, which has no flags.
pub fn listing(bytes: &[u8], flags: u32) -> Result<String, String> {
    match kind(bytes)? {
        Kind::Dxbc => {
            let options = dxbc_reader::Options::from_flags(flags).map_err(|e| e.to_string())?;
            dxbc_reader::disassemble_with(bytes, &options).map_err(|e| e.to_string())
        }
        Kind::Dxil if flags != 0 => Err(format!(
            "a DXIL program's listing (dxc -dumpbin) has no flags, so --flags {flags:#04x} is refused"
        )),
        Kind::Dxil => dxil_reader::disasm::disassemble(bytes).map_err(|e| e.to_string()),
        Kind::D3d9 => {
            let options = d3d9_reader::Options::from_flags(flags).map_err(|e| e.to_string())?;
            d3d9_reader::disassemble_with(bytes, &options).map_err(|e| e.to_string())
        }
    }
}

/// The shader model and stage of a program, for grouping counts: a DXIL program's from its program header
/// (`ps_6_0`), another's from the version line its listing names (`ps_5_0`).
pub fn target(bytes: &[u8], listing: &str) -> Option<String> {
    if let Ok(Kind::Dxil) = kind(bytes) {
        return dxil_reader::part(bytes).ok().and_then(|p| p.target());
    }
    listing
        .lines()
        .filter(|l| !l.starts_with("//"))
        // after the offset and number prefixes of D3D_DISASM_ENABLE_INSTRUCTION_OFFSET and _NUMBERING
        .map(|l| {
            l.split_once(": ")
                .filter(|(at, _)| at.trim_start().starts_with("0x"))
                .map_or(l, |(_, rest)| rest)
                .trim()
        })
        .find(|l| {
            l.len() >= 6
                && ["vs_", "ps_", "gs_", "hs_", "ds_", "cs_", "tx_"]
                    .iter()
                    .any(|p| l.starts_with(p))
                && !l.contains(' ')
        })
        .map(str::to_owned)
}

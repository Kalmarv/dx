//! `cargo run -p dxbc-reader --example pairs_dxbc -- <file or folder>...`: for every Shader Model 4 or 5 program under
//! the paths, print one tab-separated line per distinct texture read: the FNV-1a 64 hash of the file, its path, the stage,
//! the texture register, the sampler register (`-` for a load, `?` where the instruction's sampler is indexed), whether the
//! instruction compares, the sampler's declared mode (`-` where it declares none), how many such instructions the program
//! has and their opcode names. DXIL containers and other files are skipped (see the `pairs_dxil` example of `dxil-reader`).
use std::collections::BTreeMap;
use std::path::{Path, PathBuf};

fn fnv1a64(bytes: &[u8]) -> u64 {
    bytes.iter().fold(0xcbf2_9ce4_8422_2325, |h, &b| {
        (h ^ u64::from(b)).wrapping_mul(0x0100_0000_01b3)
    })
}

fn files(path: &Path, out: &mut Vec<PathBuf>) -> std::io::Result<()> {
    if path.is_dir() {
        let mut entries: Vec<PathBuf> = std::fs::read_dir(path)?
            .map(|e| e.map(|e| e.path()))
            .collect::<Result<_, _>>()?;
        entries.sort();
        for entry in entries {
            files(&entry, out)?;
        }
    } else {
        out.push(path.to_owned());
    }
    Ok(())
}

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let mut paths = Vec::new();
    for argument in std::env::args().skip(1) {
        files(Path::new(&argument), &mut paths)?;
    }
    let (mut programs, mut skipped) = (0_usize, 0_usize);
    for path in &paths {
        let bytes = std::fs::read(path)?;
        let has_code = dxbc_reader::parts(&bytes)
            .is_ok_and(|parts| parts.iter().any(|c| matches!(&c.kind, b"SHDR" | b"SHEX")));
        if !has_code {
            skipped += 1;
            continue;
        }
        let program = match dxbc_reader::code(&bytes).and_then(|code| dxbc_reader::decode(&code)) {
            Ok(program) => program,
            Err(e) => {
                eprintln!("{}: {e}", path.display());
                continue;
            }
        };
        programs += 1;
        let hash = fnv1a64(&bytes);
        // (texture, sampler, comparison, declared mode) -> instruction count and opcode names
        let mut pairs: BTreeMap<(String, String, bool, String), (usize, BTreeMap<&'static str, usize>)> =
            BTreeMap::new();
        for read in dxbc_reader::texture_reads(&program) {
            let texture = if read.texture_indexed {
                format!("t[{}+]", read.texture)
            } else {
                format!("t{}", read.texture)
            };
            let sampler = match (read.sampler, read.sampler_indexed) {
                (None, _) => "-".to_owned(),
                (Some(slot), true) => format!("s[{slot}+]"),
                (Some(slot), false) => format!("s{slot}"),
            };
            let mode = read
                .sampler_mode
                .map_or_else(|| "-".to_owned(), |m| m.to_string());
            let entry = pairs
                .entry((texture, sampler, read.comparison, mode))
                .or_default();
            entry.0 += 1;
            *entry.1.entry(dxbc_reader::opcode_name(read.opcode)).or_default() += 1;
        }
        for ((texture, sampler, comparison, mode), (count, names)) in pairs {
            let names: Vec<String> = names.iter().map(|(n, c)| format!("{n}x{c}")).collect();
            println!(
                "{hash:016x}\t{}\t{}\t{texture}\t{sampler}\t{}\t{mode}\t{count}\t{}",
                path.display(),
                program.kind.name(),
                u8::from(comparison),
                names.join(",")
            );
        }
    }
    eprintln!("{programs} programs, {skipped} files skipped");
    Ok(())
}

//! `cargo run -p dxil-reader --example pairs_dxil -- <file or folder>...`: for every Shader Model 6 program under the
//! paths, print one tab-separated line per distinct texture read: the FNV-1a 64 hash of the file, its path, the stage,
//! the texture's space and register (`t5`, `u2`; `t*` where the register is computed, `?` where the handle is not
//! resolved), the sampler's space and register (`-` for a load), whether the operation compares, the sampler's declared
//! kind (`-` where it states none), how many such calls the program has and their operation names. DXBC programs of
//! Shader Model 4 and 5 and other files are skipped (see the `pairs_dxbc` example of `dxbc-reader`).
use std::collections::BTreeMap;
use std::path::{Path, PathBuf};

use dxil_reader::sampling::{Handle, texture_reads};

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

fn operation(opcode: u16) -> String {
    let name = match opcode {
        60 => "sample",
        61 => "sampleBias",
        62 => "sampleLevel",
        63 => "sampleGrad",
        64 => "sampleCmp",
        65 => "sampleCmpLevelZero",
        66 => "textureLoad",
        68 => "bufferLoad",
        73 => "textureGather",
        74 => "textureGatherCmp",
        81 => "calculateLOD",
        139 => "rawBufferLoad",
        other => return other.to_string(),
    };
    name.to_owned()
}

/// The space and register columns of a handle.
fn columns(handle: Option<Handle>) -> (String, String) {
    let Some(h) = handle else {
        return ("?".to_owned(), "?".to_owned());
    };
    let letter = ["t", "u", "b", "s"]
        .get(usize::from(h.class))
        .copied()
        .unwrap_or("?");
    let register = h
        .register
        .map_or_else(|| format!("{letter}*"), |r| format!("{letter}{r}"));
    (h.space.to_string(), register)
}

fn stage(kind: u32) -> String {
    ["ps", "vs", "gs", "hs", "ds", "cs", "lib"]
        .get(usize::try_from(kind).unwrap_or(usize::MAX))
        .map_or_else(|| format!("kind{kind}"), |s| (*s).to_owned())
}

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let mut paths = Vec::new();
    for argument in std::env::args().skip(1) {
        files(Path::new(&argument), &mut paths)?;
    }
    let (mut programs, mut skipped) = (0_usize, 0_usize);
    for path in &paths {
        let bytes = std::fs::read(path)?;
        let Ok(chunks) = dxil_reader::parts(&bytes) else {
            skipped += 1;
            continue;
        };
        let module = match dxil_reader::module(&chunks, b"DXIL") {
            Ok(Some(module)) => module,
            Ok(None) => {
                skipped += 1;
                continue;
            }
            Err(e) => {
                eprintln!("{}: {e}", path.display());
                continue;
            }
        };
        let kind = dxil_reader::part(&bytes)?.program_version >> 16;
        let reads = match texture_reads(&module) {
            Ok(reads) => reads,
            Err(e) => {
                eprintln!("{}: {e}", path.display());
                continue;
            }
        };
        let samplers: Vec<_> = dxil_reader::reflection::ranges(&module)?
            .into_iter()
            .filter(|(range, _, _)| range.class == 3)
            .map(|(range, _, _)| range)
            .collect();
        programs += 1;
        let hash = fnv1a64(&bytes);
        // (texture, sampler, comparison, declared kind) -> call count and operation names
        type Key = ((String, String), (String, String), bool, String);
        let mut pairs: BTreeMap<Key, (usize, BTreeMap<String, usize>)> = BTreeMap::new();
        for read in reads {
            let sampler = if read.sampled {
                columns(read.sampler)
            } else {
                ("-".to_owned(), "-".to_owned())
            };
            let declared = read
                .sampler
                .and_then(|h| {
                    let register = h.register?;
                    samplers.iter().find(|r| {
                        r.space == h.space
                            && register >= r.lower
                            && register
                                .checked_sub(r.lower)
                                .is_some_and(|offset| offset < r.count)
                    })
                })
                .map_or_else(|| "-".to_owned(), |r| r.extra.to_string());
            let entry = pairs
                .entry((columns(read.texture), sampler, read.comparison, declared))
                .or_default();
            entry.0 += 1;
            *entry.1.entry(operation(read.opcode)).or_default() += 1;
        }
        for ((texture, sampler, comparison, declared), (count, names)) in pairs {
            let names: Vec<String> = names.iter().map(|(n, c)| format!("{n}x{c}")).collect();
            println!(
                "{hash:016x}\t{}\t{}\t{}\t{}\t{}\t{}\t{}\t{declared}\t{count}\t{}",
                path.display(),
                stage(kind),
                texture.0,
                texture.1,
                sampler.0,
                sampler.1,
                u8::from(comparison),
                names.join(",")
            );
        }
    }
    eprintln!("{programs} programs, {skipped} files skipped");
    Ok(())
}

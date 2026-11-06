//! `dx`: Direct3D shader programs from the command line. `dx disasm` writes Microsoft's listing of a program (or checks
//! it against listings Microsoft's tools wrote), `dx reflect` its bindings, signatures and buffer layouts as JSON, `dx
//! info` its container's parts.
use std::path::{Path, PathBuf};
use std::process::ExitCode;

use clap::{Parser, Subcommand};

mod check;
mod files;
mod reflect;

#[derive(Parser)]
#[command(name = "dx", version, about = "Read compiled Direct3D shader programs")]
struct Cli {
    #[command(subcommand)]
    command: Command,
}

#[derive(Subcommand)]
enum Command {
    /// Write the listing of each program as Microsoft's disassembler does (`D3DDisassemble`, `fxc /dumpbin`).
    Disasm {
        /// A compiled program (.cso, .dxbc, .fxc, a raw Direct3D 9 token stream) or a folder of them: every file in it
        /// that starts as a container or token stream does.
        path: PathBuf,
        /// Compare each program's listing with Microsoft's stored beside it (`NAME.<ext>.asm`, `NAME.<ext>.txt`, or
        /// `NAME.asm` or `NAME.txt` where no other program is NAME) and count identical, differing and failed
        /// programs by shader model and stage. Fails when no program has a stored listing.
        #[arg(long)]
        check: bool,
        /// With --check, list every differing program with its first differing line.
        #[arg(long, short)]
        verbose: bool,
        /// Microsoft's `D3D_DISASM_*` flags, in hex (`0x04` numbers instructions, `0x20` writes their offsets,
        /// `0x40` leaves out the header, `0x80` writes literals in hex); with --check, compared with
        /// `NAME.<ext>.flagNN.asm` (or `NAME.flagNN.asm`, as above).
        #[arg(long, value_parser = flags, default_value = "0")]
        flags: u32,
    },
    /// Write what a program's container states about it, as JSON or text.
    ///
    /// The RDEF part's bindings and buffer layouts, the signatures, the STAT counters, the feature flags and the level 9 mappings of a DXBC container; the constant
    /// table of a Direct3D 9 program. Each record has D3D's numbers and the names Microsoft's disassembler gives them.
    Reflect {
        /// A compiled program (.cso, .dxbc, .fxc, a raw Direct3D 9 token stream).
        path: PathBuf,
        /// Write JSON rather than indented text.
        #[arg(long)]
        json: bool,
    },
    /// Write a program file's container: its parts, sizes and digest.
    ///
    /// For a DXBC container its parts with their offsets and sizes, its digest and whether it matches, its target;
    /// for a Direct3D 9 program, its version and its counts of records.
    Info {
        /// A compiled program (.cso, .dxbc, .fxc, a raw Direct3D 9 token stream).
        path: PathBuf,
        /// Write JSON rather than indented text.
        #[arg(long)]
        json: bool,
    },
}

fn main() -> ExitCode {
    let cli = Cli::parse();
    let result = match cli.command {
        Command::Disasm {
            path,
            check: true,
            verbose,
            flags,
        } => check::run(&path, flags, verbose),
        Command::Disasm { path, flags, .. } => disasm(&path, flags),
        Command::Reflect { path, json } => describe(&path, json, reflect::reflect),
        Command::Info { path, json } => describe(&path, json, reflect::info),
    };
    match result {
        Ok(code) => code,
        Err(message) => {
            eprintln!("dx: {message}");
            ExitCode::FAILURE
        }
    }
}

/// A flags word in hex, with or without `0x`.
fn flags(text: &str) -> Result<u32, String> {
    let digits = text.strip_prefix("0x").unwrap_or(text);
    u32::from_str_radix(digits, 16).map_err(|e| format!("{text}: not a hex flags word: {e}"))
}

/// The listing of every program under `path`; a folder's each after a `// FILE` line.
fn disasm(path: &Path, flags: u32) -> Result<ExitCode, String> {
    let (paths, _) = files::programs(path)?;
    let many = path.is_dir();
    if many && paths.is_empty() {
        return Err(format!("{}: no programs in the folder", path.display()));
    }
    let mut failed = false;
    for path in paths {
        let bytes = std::fs::read(&path).map_err(|e| format!("{}: {e}", path.display()))?;
        match files::listing(&bytes, flags) {
            Ok(text) => {
                if many {
                    println!("// {}", path.display());
                }
                print!("{text}");
                if flags & 0x10 == 0 && files::has_debug_part(&bytes) {
                    eprintln!(
                        "dx: {}: the SPDB part's source lines and variable locations are not written (this is \
                         Microsoft's listing with --flags 0x10)",
                        path.display()
                    );
                }
            }
            Err(e) => {
                eprintln!("dx: {}: {e}", path.display());
                failed = true;
            }
        }
    }
    Ok(if failed {
        ExitCode::FAILURE
    } else {
        ExitCode::SUCCESS
    })
}

/// What `read` makes of the file at `path`, as JSON or as indented text.
fn describe(
    path: &Path,
    json: bool,
    read: fn(&[u8]) -> Result<serde_json::Value, String>,
) -> Result<ExitCode, String> {
    let bytes = std::fs::read(path).map_err(|e| format!("{}: {e}", path.display()))?;
    let value = read(&bytes).map_err(|e| format!("{}: {e}", path.display()))?;
    if json {
        let text = serde_json::to_string_pretty(&value).map_err(|e| e.to_string())?;
        println!("{text}");
    } else {
        print!("{}", reflect::text(&value));
    }
    Ok(ExitCode::SUCCESS)
}

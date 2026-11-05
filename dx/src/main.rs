//! `dx`: Direct3D shader programs from the command line. `dx disasm` writes Microsoft's listing of a program (or checks
//! it against listings Microsoft's tools wrote), `dx reflect` its bindings, signatures and buffer layouts as JSON, `dx
//! info` its container's parts.
use std::path::{Path, PathBuf};
use std::process::ExitCode;

use clap::{Parser, Subcommand};

mod check;
mod files;

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
        /// A compiled program (.cso, .dxbc, .fxc, a raw Direct3D 9 token stream) or a folder of them.
        path: PathBuf,
        /// Compare each program's listing with Microsoft's stored beside it (`NAME.txt`, `NAME.asm` or
        /// `NAME.<ext>.asm`) and count identical, differing and failed programs by shader model and stage.
        #[arg(long)]
        check: bool,
        /// With --check, list every differing program with its first differing line.
        #[arg(long, short)]
        verbose: bool,
        /// Microsoft's `D3D_DISASM_*` flags, in hex (`0x04` numbers instructions, `0x20` writes their offsets,
        /// `0x40` leaves out the header, `0x80` writes literals in hex); with --check, compared with
        /// `NAME.flagNN.asm`.
        #[arg(long, value_parser = flags, default_value = "0")]
        flags: u32,
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
    let paths = files::programs(path)?;
    let many = path.is_dir();
    let mut failed = false;
    for path in paths {
        let bytes = std::fs::read(&path).map_err(|e| format!("{}: {e}", path.display()))?;
        match files::listing(&bytes, flags) {
            Ok(text) => {
                if many {
                    println!("// {}", path.display());
                }
                print!("{text}");
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

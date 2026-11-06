//! The workspace's own tasks: `cargo xtask <task>` (the alias is in `.cargo/config.toml`).
//!
//! Each generator writes the final text of a committed file itself (no formatter runs over it) and records, in the
//! file's `@generated` header, the hash of every input and of what it wrote. `cargo test -p xtask` checks the recorded
//! hash against the file, so a hand edit fails; running the task again with `--check` regenerates and compares, so a
//! file that no longer follows its inputs fails.
use std::path::PathBuf;
use std::process::ExitCode;

use clap::{Parser, Subcommand};

mod dxil_ops;
mod generated;

#[derive(Parser)]
#[command(about = "The dx workspace's own tasks")]
struct Cli {
    #[command(subcommand)]
    task: Task,
}

#[derive(Subcommand)]
enum Task {
    /// Write `dxil-reader/src/disasm/ops.rs`, the name and operands dxc's listing gives each DXIL operation, from a
    /// DirectXShaderCompiler checkout at the release the listings are compared with.
    DxilOps {
        /// A DirectXShaderCompiler checkout at the pinned tag (`dxil_ops::TAG`).
        #[arg(long)]
        source: PathBuf,
        /// Compare with the committed file instead of writing it; fail where they differ.
        #[arg(long)]
        check: bool,
    },
}

fn main() -> ExitCode {
    let result = match Cli::parse().task {
        Task::DxilOps { source, check } => dxil_ops::run(&source, check),
    };
    match result {
        Ok(summary) => {
            println!("{summary}");
            ExitCode::SUCCESS
        }
        Err(why) => {
            eprintln!("error: {why}");
            ExitCode::FAILURE
        }
    }
}

/// The workspace's root folder (this package's parent).
fn root() -> PathBuf {
    PathBuf::from(env!("CARGO_MANIFEST_DIR")).join("..")
}

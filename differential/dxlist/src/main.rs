//! dxlist DIR FLAGS...: for each program `NAME.dxbc` (a DXBC container) or `NAME.bin` (a Direct3D 9 token stream) in
//! DIR, and each flags word (hex), write dx's listing to `NAME.dx.FF.txt`, its refusal to `NAME.dx.FF.err`, or
//! `NAME.dx.FF.panic` when it panicked; then print the number of programs. The differential's (differential/README.md).
use std::path::Path;
use std::process::ExitCode;

fn listing(bytes: &[u8], d3d9: bool, flags: u32) -> Result<String, String> {
    if d3d9 {
        let options = d3d9_reader::Options::from_flags(flags).map_err(|e| e.to_string())?;
        d3d9_reader::disassemble_with(bytes, &options).map_err(|e| e.to_string())
    } else {
        let options = dxbc_reader::Options::from_flags(flags).map_err(|e| e.to_string())?;
        dxbc_reader::disassemble_with(bytes, &options).map_err(|e| e.to_string())
    }
}

fn run(args: &[String]) -> Result<usize, String> {
    let [dir, flags @ ..] = args else {
        return Err("usage: dxlist DIR FLAGS...".to_owned());
    };
    let dir = Path::new(dir);
    let flags = flags
        .iter()
        .map(|f| u32::from_str_radix(f.trim_start_matches("0x"), 16).map_err(|e| format!("flags {f}: {e}")))
        .collect::<Result<Vec<u32>, String>>()?;
    let mut programs = 0;
    for entry in std::fs::read_dir(dir).map_err(|e| format!("{}: {e}", dir.display()))? {
        let path = entry.map_err(|e| format!("{}: {e}", dir.display()))?.path();
        let name = path
            .file_name()
            .unwrap_or_default()
            .to_string_lossy()
            .into_owned();
        let (stem, d3d9) = if let Some(s) = name.strip_suffix(".dxbc") {
            (s.to_owned(), false)
        } else if let Some(s) = name.strip_suffix(".bin") {
            (s.to_owned(), true)
        } else {
            continue;
        };
        let bytes = std::fs::read(&path).map_err(|e| format!("{}: {e}", path.display()))?;
        for &f in &flags {
            // a panic is a finding of its own, and the rest are still listed
            let (ending, text) = match std::panic::catch_unwind(|| listing(&bytes, d3d9, f)) {
                Ok(Ok(text)) => ("txt", text),
                Ok(Err(e)) => ("err", e),
                Err(_) => ("panic", "panicked".to_owned()),
            };
            let out = dir.join(format!("{stem}.dx.{f:02x}.{ending}"));
            std::fs::write(&out, text).map_err(|e| format!("{}: {e}", out.display()))?;
        }
        programs += 1;
    }
    Ok(programs)
}

fn main() -> ExitCode {
    let args: Vec<String> = std::env::args().skip(1).collect();
    match run(&args) {
        Ok(programs) => {
            println!("{programs}");
            ExitCode::SUCCESS
        }
        Err(e) => {
            eprintln!("dxlist: {e}");
            ExitCode::FAILURE
        }
    }
}

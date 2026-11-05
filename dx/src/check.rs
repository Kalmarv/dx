//! `dx disasm --check`: each program's listing against Microsoft's stored beside it, byte for byte, counted by shader
//! model and stage as identical, differing (by the first line that differs) and failed (dx refused the program).
use std::collections::BTreeMap;
use std::path::Path;
use std::process::ExitCode;

use crate::files;

#[derive(Default)]
struct Counts {
    identical: usize,
    differing: usize,
    failed: usize,
}

/// The first line where `ours` and `theirs` differ: its number (from 1) and both texts.
fn first_difference<'a>(ours: &'a str, theirs: &'a str) -> Option<(usize, &'a str, &'a str)> {
    let mut a = ours.split('\n');
    let mut b = theirs.split('\n');
    let mut n = 0usize;
    loop {
        n = n.saturating_add(1);
        match (a.next(), b.next()) {
            (None, None) => return None,
            (x, y) if x == y => {}
            (x, y) => return Some((n, x.unwrap_or("<end>"), y.unwrap_or("<end>"))),
        }
    }
}

/// The kind of a differing line, for grouping: the header, a declaration or instruction by its mnemonic, or the end.
fn reason(theirs: &str, ours: &str) -> String {
    let line = if theirs == "<end>" { ours } else { theirs };
    let t = line.trim_start();
    if t.starts_with("//") {
        let words: Vec<&str> = t.trim_start_matches('/').split_whitespace().take(2).collect();
        return format!("comment: {}", words.join(" "));
    }
    let word = t.split([' ', '(']).next().unwrap_or("");
    format!("code: {word}")
}

pub fn run(path: &Path, verbose: bool) -> Result<ExitCode, String> {
    let mut by_target: BTreeMap<String, Counts> = BTreeMap::new();
    let mut reasons: BTreeMap<String, (usize, String)> = BTreeMap::new();
    let mut failures: BTreeMap<String, (usize, String)> = BTreeMap::new();
    let mut without = 0usize;
    for program in files::programs(path)? {
        let Some(stored) = files::stored_listing(&program) else {
            without = without.saturating_add(1);
            continue;
        };
        let bytes = std::fs::read(&program).map_err(|e| format!("{}: {e}", program.display()))?;
        let theirs = std::fs::read(&stored).map_err(|e| format!("{}: {e}", stored.display()))?;
        // Microsoft's disassembler writes LF and ends its blob in a NUL; fxc's /Fc and listings saved in text mode on
        // Windows end their lines in CRLF
        let theirs = String::from_utf8_lossy(&theirs).replace("\r\n", "\n");
        let theirs = theirs.trim_end_matches('\0');
        let target = files::target(theirs).unwrap_or_else(|| "unknown".to_owned());
        let counts = by_target.entry(target).or_default();
        let name = program.display().to_string();
        match files::listing(&bytes) {
            Err(e) => {
                counts.failed = counts.failed.saturating_add(1);
                let key = e.split(':').nth(1).unwrap_or(&e).trim().to_owned();
                let entry = failures.entry(key).or_insert((0, format!("{name}: {e}")));
                entry.0 = entry.0.saturating_add(1);
            }
            Ok(ours) => match first_difference(&ours, theirs) {
                None => counts.identical = counts.identical.saturating_add(1),
                Some((line, a, b)) => {
                    counts.differing = counts.differing.saturating_add(1);
                    let example = format!("{name}:{line}\n    ms: {b:?}\n    dx: {a:?}");
                    if verbose {
                        println!("{example}");
                    }
                    let entry = reasons.entry(reason(b, a)).or_insert((0, example));
                    entry.0 = entry.0.saturating_add(1);
                }
            },
        }
    }
    println!("{:<10} {:>9} {:>9} {:>7}", "target", "identical", "differing", "failed");
    let mut total = Counts::default();
    for (target, c) in &by_target {
        println!("{target:<10} {:>9} {:>9} {:>7}", c.identical, c.differing, c.failed);
        total.identical = total.identical.saturating_add(c.identical);
        total.differing = total.differing.saturating_add(c.differing);
        total.failed = total.failed.saturating_add(c.failed);
    }
    println!(
        "{:<10} {:>9} {:>9} {:>7}",
        "total", total.identical, total.differing, total.failed
    );
    if without != 0 {
        println!("{without} files without a stored listing were skipped");
    }
    let mut sorted: Vec<_> = reasons.into_iter().collect();
    sorted.sort_by(|a, b| b.1.0.cmp(&a.1.0));
    if !sorted.is_empty() {
        println!("\ndiffering, by the first differing line:");
    }
    for (reason, (n, example)) in sorted {
        println!("{n:>6}  {reason}\n        e.g. {example}");
    }
    if !failures.is_empty() {
        println!("\nfailed:");
    }
    for (reason, (n, example)) in failures {
        println!("{n:>6}  {reason}\n        e.g. {example}");
    }
    Ok(if total.differing == 0 && total.failed == 0 {
        ExitCode::SUCCESS
    } else {
        ExitCode::FAILURE
    })
}

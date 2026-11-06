//! The disassembler against dxc 1.9.2609's own listings (`dxc -dumpbin`) of every fixture: `disasm/listings/<name>.txt`
//! for `<name>.dxil` of `fixtures/` and `disasm/`, which `disasm/generate.py` compiles and lists. A container without
//! its listing fails, as a listing that differs does. With `DISASM_DIFF_DIR` set, each differing pair is written there
//! (`<name>.got`, `<name>.want`).
use std::path::{Path, PathBuf};

#[test]
fn every_listing_matches_dxc() {
    let tests = Path::new(env!("CARGO_MANIFEST_DIR")).join("tests");
    let listings = tests.join("disasm/listings");
    let mut containers: Vec<PathBuf> = ["fixtures", "disasm"]
        .iter()
        .flat_map(|d| std::fs::read_dir(tests.join(d)).unwrap())
        .map(|e| e.unwrap().path())
        .filter(|p| p.extension().is_some_and(|e| e == "dxil"))
        .collect();
    containers.sort();
    let out = std::env::var_os("DISASM_DIFF_DIR").map(PathBuf::from);
    let mut failures = Vec::new();
    for container in &containers {
        let name = container.file_stem().unwrap().to_str().unwrap();
        let Ok(expected) = std::fs::read_to_string(listings.join(format!("{name}.txt"))) else {
            failures.push(format!("{name}: no listing"));
            continue;
        };
        let got = dxil_reader::disasm::disassemble(&std::fs::read(container).unwrap())
            .unwrap_or_else(|e| format!("error: {e}\n"));
        if got != expected {
            let line = got
                .lines()
                .zip(expected.lines())
                .position(|(a, b)| a != b)
                .unwrap_or_else(|| got.lines().count().min(expected.lines().count()));
            failures.push(format!("{name}: differs from line {}", line + 1));
            if let Some(dir) = &out {
                std::fs::write(dir.join(format!("{name}.got")), &got).unwrap();
                std::fs::write(dir.join(format!("{name}.want")), &expected).unwrap();
            }
        }
    }
    assert!(
        failures.is_empty(),
        "{} of {} containers:\n{}",
        failures.len(),
        containers.len(),
        failures.join("\n")
    );
    assert_eq!(containers.len(), 151, "containers compared");
}

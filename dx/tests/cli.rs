#![allow(clippy::unwrap_used)]
//! The `dx` command over folders laid out as corpora are: programs beside Microsoft's listings of them, other files
//! among them. The programs and listings are dxbc-reader's fixtures (`fxc` and `D3DDisassemble` of d3dcompiler_47
//! 10.0.26100.4654).
use std::path::{Path, PathBuf};
use std::process::Command;

const FIXTURES: &str = concat!(env!("CARGO_MANIFEST_DIR"), "/../dxbc-reader/tests/disasm");

/// An empty folder of its own for one test, removed when the test ends.
struct Folder(PathBuf);

impl std::ops::Deref for Folder {
    type Target = Path;
    fn deref(&self) -> &Path {
        &self.0
    }
}

impl Drop for Folder {
    fn drop(&mut self) {
        let _ = std::fs::remove_dir_all(&self.0);
    }
}

fn folder(test: &str) -> Folder {
    let path = std::env::temp_dir().join(format!("dx-cli-{}-{test}", std::process::id()));
    let _ = std::fs::remove_dir_all(&path);
    std::fs::create_dir_all(&path).unwrap();
    Folder(path)
}

/// A fixture program, or Microsoft's listing of one (`listings/NAME`), copied to `to`.
fn copy(fixture: &str, to: &Path) {
    std::fs::copy(Path::new(FIXTURES).join(fixture), to).unwrap();
}

/// The exit status, standard output and standard error of `dx ARGS`.
fn dx(args: &[&str]) -> (bool, String, String) {
    let out = Command::new(env!("CARGO_BIN_EXE_dx"))
        .args(args)
        .output()
        .unwrap();
    let text = |b: Vec<u8>| String::from_utf8(b).unwrap();
    (out.status.success(), text(out.stdout), text(out.stderr))
}

/// The counts line of `--check`'s table for `target`, its words.
fn counts<'a>(stdout: &'a str, target: &str) -> Vec<&'a str> {
    stdout
        .lines()
        .map(|l| l.split_whitespace().collect::<Vec<_>>())
        .find(|w| w.first() == Some(&target))
        .unwrap_or_else(|| panic!("no {target} line in\n{stdout}"))
}

#[test]
fn check_takes_the_listing_named_by_the_whole_file_name() {
    // a .ppo and a .vpo with one stem, as Sekiro's programs are, each with its own listing; a listing named by the
    // stem alone is the .ppo's and must not be taken for the .vpo's
    let dir = folder("whole-name");
    copy("cs_memory.cs40.dxbc", &dir.join("a.ppo"));
    copy("gs_streams.gs40.dxbc", &dir.join("a.vpo"));
    copy(
        "listings/cs_memory.cs40.flag04.asm",
        &dir.join("a.ppo.flag04.asm"),
    );
    copy(
        "listings/gs_streams.gs40.flag04.asm",
        &dir.join("a.vpo.flag04.asm"),
    );
    copy("listings/cs_memory.cs40.flag04.asm", &dir.join("a.flag04.asm"));
    copy("listings/cs_memory.cs40.asm", &dir.join("a.ppo.asm"));
    copy("listings/gs_streams.gs40.asm", &dir.join("a.vpo.asm"));
    let d = dir.to_str().unwrap();
    for flags in ["0x04", "0"] {
        let (ok, stdout, stderr) = dx(&["disasm", "--check", "--flags", flags, d]);
        assert!(ok, "--flags {flags}:\n{stdout}{stderr}");
        assert_eq!(
            counts(&stdout, "total"),
            ["total", "2", "0", "0"],
            "--flags {flags}:\n{stdout}"
        );
    }
}

#[test]
fn check_takes_the_listing_named_by_the_stem_where_no_other_program_shares_it() {
    let dir = folder("stem");
    copy("cs_memory.cs40.dxbc", &dir.join("a.ppo"));
    copy("listings/cs_memory.cs40.flag04.asm", &dir.join("a.flag04.asm"));
    let (ok, stdout, stderr) = dx(&["disasm", "--check", "--flags", "04", dir.to_str().unwrap()]);
    assert!(ok, "{stdout}{stderr}");
    assert_eq!(counts(&stdout, "cs_4_0"), ["cs_4_0", "1", "0", "0"]);
}

#[test]
fn check_fails_on_a_differing_listing() {
    let dir = folder("differing");
    copy("cs_memory.cs40.dxbc", &dir.join("a.dxbc"));
    let theirs = std::fs::read_to_string(Path::new(FIXTURES).join("listings/cs_memory.cs40.asm")).unwrap();
    std::fs::write(dir.join("a.dxbc.asm"), theirs.replacen("cs_4_0", "cs_4_1", 1)).unwrap();
    let (ok, stdout, _) = dx(&["disasm", "--check", dir.to_str().unwrap()]);
    assert!(!ok, "{stdout}");
    assert_eq!(counts(&stdout, "total"), ["total", "0", "1", "0"]);
}

#[test]
fn check_fails_when_no_program_has_a_listing_beside_it() {
    // the listings in a subfolder of their own, where --check does not look for them
    let dir = folder("nothing");
    copy("cs_memory.cs40.dxbc", &dir.join("a.dxbc"));
    std::fs::create_dir(dir.join("listings")).unwrap();
    copy("listings/cs_memory.cs40.asm", &dir.join("listings/a.asm"));
    let (ok, stdout, stderr) = dx(&["disasm", "--check", dir.to_str().unwrap()]);
    assert!(!ok, "{stdout}");
    assert!(
        stderr.contains("no program with a stored listing to compare"),
        "{stderr}"
    );
    assert!(
        stdout.contains("1 programs without a stored listing were skipped"),
        "{stdout}"
    );
}

#[test]
fn a_folder_holds_only_the_files_that_are_programs() {
    // a corpus folder with the scripts and tables made beside it
    let dir = folder("others");
    copy("cs_memory.cs40.dxbc", &dir.join("a.dxbc"));
    copy("listings/cs_memory.cs40.asm", &dir.join("a.dxbc.asm"));
    std::fs::write(dir.join("generate.py"), "print('hi')\n").unwrap();
    std::fs::write(dir.join("feat.pkl"), [0x80, 0x04, 0x95, 0, 0, 0]).unwrap();
    std::fs::write(dir.join("summary.tsv"), "name\tcount\n").unwrap();
    std::fs::write(dir.join("empty"), []).unwrap();
    let d = dir.to_str().unwrap();

    let (ok, stdout, stderr) = dx(&["disasm", d]);
    assert!(ok, "{stderr}");
    let theirs = std::fs::read_to_string(Path::new(FIXTURES).join("listings/cs_memory.cs40.asm")).unwrap();
    let (first, listing) = stdout.split_once('\n').unwrap();
    assert_eq!(first, format!("// {}", dir.join("a.dxbc").display()));
    assert_eq!(listing, theirs.trim_end_matches('\0'));

    let (ok, stdout, stderr) = dx(&["disasm", "--check", d]);
    assert!(ok, "{stdout}{stderr}");
    assert_eq!(counts(&stdout, "total"), ["total", "1", "0", "0"]);
    assert!(
        stdout.contains("5 files that are not programs were skipped"),
        "{stdout}"
    );
}

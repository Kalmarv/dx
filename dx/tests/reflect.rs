#![allow(clippy::unwrap_used)]
//! `dx reflect` and `dx info` against what Microsoft's tools say of the same programs: for DXIL, the signature and
//! resource binding tables of `dxc -dumpbin` (dxc 1.9.2609, dxil-reader's fixture listings); for DXBC, the features
//! `D3DDisassemble` says a program requires (d3dcompiler_47 10.0.26100.4654, dxbc-reader's fixture listings).
use std::path::{Path, PathBuf};
use std::process::Command;

use serde_json::Value;

const DXIL: &str = concat!(env!("CARGO_MANIFEST_DIR"), "/../dxil-reader/tests");
const DXBC: &str = concat!(env!("CARGO_MANIFEST_DIR"), "/../dxbc-reader/tests");

/// `dx COMMAND --json PATH`, which must succeed.
fn dx(command: &str, path: &Path) -> Value {
    let out = Command::new(env!("CARGO_BIN_EXE_dx"))
        .args([command, "--json"])
        .arg(path)
        .output()
        .unwrap();
    assert!(
        out.status.success(),
        "dx {command} {}: {}",
        path.display(),
        String::from_utf8_lossy(&out.stderr)
    );
    serde_json::from_slice(&out.stdout).unwrap()
}

/// The rows of the table after the line `; {title}` of a dxc listing, each cut into its columns where the table's
/// dashed line has its runs of dashes: the first column left-aligned in its run, each other right-aligned in the slot
/// from the end of the column before to the end of its own run, the last to the line's end. A right-aligned value wider
/// than its slot fills it from its first character and runs on past its end, pushing the columns after it as far;
/// none where its one row is `; no parameters`; `None` where the listing has no such table.
fn table(listing: &str, title: &str) -> Option<Vec<Vec<String>>> {
    let mut lines = listing.lines().skip_while(|l| *l != format!("; {title}"));
    lines.next()?;
    let dashes = lines.find(|l| l.starts_with("; ---"))?;
    let mut columns = Vec::new();
    let mut start = None;
    for (n, c) in dashes.char_indices().chain([(dashes.len(), ' ')]) {
        match (c == '-', start) {
            (true, None) => start = Some(n),
            (false, Some(s)) => {
                columns.push((s, n));
                start = None;
            }
            _ => {}
        }
    }
    let mut lines = lines.peekable();
    if lines.peek() == Some(&"; no parameters") {
        return Some(Vec::new());
    }
    Some(
        lines
            .take_while(|l| *l != ";")
            .map(|l| {
                let last = columns.len().saturating_sub(1);
                let at = |i: usize| l.as_bytes().get(i).copied();
                let mut shift = 0;
                columns
                    .iter()
                    .enumerate()
                    .map(|(n, &(s, e))| {
                        let s = if n == 0 {
                            s
                        } else {
                            columns.get(n - 1).map_or(s, |c| c.1)
                        } + shift;
                        let mut e = if n == last { l.len() } else { e + shift };
                        if n > 0
                            && n < last
                            && at(s).is_some_and(|c| c != b' ')
                            && at(e).is_some_and(|c| c != b' ')
                        {
                            let wider = l.get(e..).and_then(|t| t.find(' ')).unwrap_or(l.len() - e);
                            e += wider;
                            shift += wider;
                        }
                        l.get(s..e.min(l.len())).unwrap_or("").trim().to_owned()
                    })
                    .collect()
            })
            .collect(),
    )
}

/// A JSON value as the listing's text: a string as itself, a number in decimal, `null` as `none`.
fn text(value: &Value, none: &str) -> String {
    match value {
        Value::String(s) => s.clone(),
        Value::Null => none.to_owned(),
        other => other.to_string(),
    }
}

/// The DXIL fixtures with a dxc listing.
fn dxil_programs() -> Vec<(PathBuf, String)> {
    let mut out: Vec<(PathBuf, String)> = std::fs::read_dir(Path::new(DXIL).join("fixtures"))
        .unwrap()
        .map(|entry| entry.unwrap().path())
        .filter(|p| p.extension().is_some_and(|e| e == "dxil"))
        .filter_map(|p| {
            let stem = p.file_stem().unwrap().to_str().unwrap().to_owned();
            let listing = Path::new(DXIL)
                .join("disasm/listings")
                .join(format!("{stem}.txt"));
            std::fs::read_to_string(listing).ok().map(|l| (p, l))
        })
        .collect();
    out.sort();
    out
}

#[test]
fn dxil_reflection_is_dxcs() {
    let mut differing = Vec::new();
    let mut compared = 0;
    let programs = dxil_programs();
    for (path, listing) in &programs {
        let name = path.file_name().unwrap().to_str().unwrap();
        let reflected = dx("reflect", path);
        let info = dx("info", path);
        let mut check = |what: &str, ours: Vec<Vec<String>>, theirs: Vec<Vec<String>>| {
            compared += 1;
            if ours != theirs {
                differing.push(format!("{name} {what}:\n  dx:  {ours:?}\n  dxc: {theirs:?}"));
            }
        };
        check(
            "target",
            vec![vec![text(&reflected["target"], "-"), text(&info["target"], "-")]],
            vec![vec![shader_model(listing).to_owned(); 2]],
        );
        let domain = shader_model(listing).starts_with("ds_");
        for (key, title) in [
            ("input", "Input signature:"),
            ("output", "Output signature:"),
            ("patch_constant", "Patch Constant signature:"),
        ] {
            // the first table of each title is the signature part's; the second, the pipeline information's
            let theirs = table(listing, title).unwrap_or_default();
            // an element with no register has `N/A` for its mask, the name of the register it is read from in the
            // Register column (`primID`; the listing's alone, so taken from it) and `YES` or `NO` for its use. Where any
            // element is in a stream other than 0, every name has its stream before it (`m1:`). dxc takes a domain
            // program's patch constants for outputs, whose stored mask is of the components never written, so its Used
            // column has the components the program does not read, where dx has those it does.
            let elements = reflected["signatures"][key]
                .as_array()
                .cloned()
                .unwrap_or_default();
            let streams = elements.iter().any(|e| e["stream"] != 0);
            let unread = domain && key == "patch_constant";
            let ours = Some(&elements)
                .map(|elements| {
                    elements
                        .iter()
                        .enumerate()
                        .map(|(n, e)| {
                            let placed = !e["register"].is_null();
                            let mut used = text(&e["used"], "");
                            if unread {
                                used = "xyzw".chars().filter(|c| !used.contains(*c)).collect();
                            }
                            vec![
                                if streams {
                                    format!("m{}:{}", e["stream"], text(&e["name"], ""))
                                } else {
                                    text(&e["name"], "")
                                },
                                text(&e["index"], ""),
                                if placed {
                                    text(&e["mask"], "")
                                } else {
                                    "N/A".to_owned()
                                },
                                if placed {
                                    text(&e["register"], "")
                                } else {
                                    theirs.get(n).map(|row| row[3].clone()).unwrap_or_default()
                                },
                                text(&e["system_value_name"], ""),
                                text(&e["format"], ""),
                                match (placed, used.is_empty()) {
                                    (true, _) => used,
                                    (false, true) => "NO".to_owned(),
                                    (false, false) => "YES".to_owned(),
                                },
                            ]
                        })
                        .collect()
                })
                .unwrap_or_default();
            check(key, ours, theirs);
        }
        let theirs = table(listing, "Resource Bindings:").unwrap_or_default();
        let ours = reflected["resources"]
            .as_array()
            .unwrap()
            .iter()
            .map(|r| {
                vec![
                    text(&r["name"], ""),
                    text(&r["class_name"], ""),
                    text(&r["format"], ""),
                    text(&r["dimension"], ""),
                    text(&r["id_name"], ""),
                    text(&r["bind"], ""),
                    text(&r["count"], "unbounded"),
                ]
            })
            .collect();
        check("resources", ours, theirs);
    }
    assert!(
        differing.is_empty(),
        "{} of {compared} tables differ:\n{}",
        differing.len(),
        differing.join("\n")
    );
    assert_eq!(programs.len(), 152);
}

/// The target a dxc listing names in its `!dx.shaderModel` metadata: `!{!"ps", i32 6, i32 0}` is `ps_6_0`.
fn shader_model(listing: &str) -> String {
    let line = listing
        .lines()
        .find(|l| l.contains("= !{!\"") && l.contains("\", i32 6, i32 "))
        .unwrap();
    let kind = line.split('"').nth(1).unwrap();
    let numbers: Vec<&str> = line
        .split("i32 ")
        .skip(1)
        .map(|n| n.trim_end_matches(['}', ',', ' ']))
        .collect();
    format!("{kind}_{}_{}", numbers[0], numbers[1])
}

/// The features a DXBC listing of Microsoft's notes the program requires.
fn notes(listing: &str) -> Vec<String> {
    listing
        .lines()
        .skip_while(|l| *l != "// Note: shader requires additional functionality:")
        .skip(1)
        .map_while(|l| l.strip_prefix("//       "))
        .map(str::to_owned)
        .collect()
}

#[test]
fn dxbc_features_are_those_microsofts_listing_notes() {
    let mut containers: Vec<PathBuf> = ["disasm", "fixtures"]
        .iter()
        .flat_map(|folder| std::fs::read_dir(Path::new(DXBC).join(folder)).unwrap())
        .map(|entry| entry.unwrap().path())
        .filter(|p| p.extension().is_some_and(|e| e == "dxbc"))
        .collect();
    containers.sort();
    let mut differing = Vec::new();
    let mut with_features = 0;
    for path in &containers {
        let stem = path.file_stem().unwrap().to_str().unwrap();
        let listing =
            std::fs::read_to_string(Path::new(DXBC).join(format!("disasm/listings/{stem}.asm"))).unwrap();
        let info = dx("info", path);
        let reflected = dx("reflect", path);
        let features = &info["features"];
        if *features != reflected["features"] {
            differing.push(format!(
                "{stem}: info {features} but reflect {}",
                reflected["features"]
            ));
        }
        let has_part = info["parts"]
            .as_array()
            .unwrap()
            .iter()
            .any(|p| p["tag"] == "SFI0");
        if features.is_null() {
            if has_part {
                differing.push(format!("{stem}: an SFI0 part but no features"));
            }
            continue;
        }
        with_features += 1;
        let bits =
            u64::from_str_radix(features["bits"].as_str().unwrap().trim_start_matches("0x"), 16).unwrap();
        // the listing notes neither bit 1 (raw and structured buffers) nor any bit with no name, and notes forced early
        // depth-stencil, which is no SFI0 bit (and the features dcl_globalFlags states, which fxc states in SFI0 too)
        let ours: Vec<String> = features["names"]
            .as_array()
            .unwrap()
            .iter()
            .map(|n| n.as_str().unwrap().to_owned())
            .filter(|n| n != "Raw and Structured buffers")
            .collect();
        let theirs: Vec<String> = notes(&listing)
            .into_iter()
            .filter(|n| n != "Early depth-stencil")
            .collect();
        if ours != theirs || features["unnamed"] != "0x0" || bits >> 14 != 0 {
            differing.push(format!("{stem}: dx {features}, Microsoft notes {theirs:?}"));
        }
    }
    assert!(differing.is_empty(), "{}", differing.join("\n"));
    assert_eq!(containers.len(), 263);
    assert_eq!(with_features, 61);
}

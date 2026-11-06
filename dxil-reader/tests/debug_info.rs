#![allow(clippy::unwrap_used, clippy::indexing_slicing)]
//! The debug information of programs built with `-Zi -Qembed_debug` as the module reads it, against dxc 1.9.2609's
//! own listing of the same containers (`disasm/listings`): each instruction's source line and column are the ones the
//! listing's `; line:` comment prints for it, and each debug intrinsic passes the variable and expression its `; var:`
//! comment names, as metadata values of the body.
use dxil_reader::module::{DebugNode, Metadata, Module, Op, Value};

fn read(name: &str) -> (Module, String) {
    let tests = std::path::Path::new(env!("CARGO_MANIFEST_DIR")).join("tests");
    let bytes = std::fs::read(tests.join("fixtures").join(format!("{name}.dxil"))).unwrap();
    let chunks = dxil_reader::parts(&bytes).unwrap();
    // the debug module is the ILDB part's
    let m = dxil_reader::module(&chunks, b"ILDB").unwrap().unwrap();
    let listing = std::fs::read_to_string(tests.join("disasm/listings").join(format!("{name}.txt"))).unwrap();
    (m, listing)
}

/// The instruction lines of the listing's function bodies, in order.
fn instruction_lines(listing: &str) -> Vec<&str> {
    let mut out = Vec::new();
    let mut inside = false;
    for line in listing.lines() {
        if line.starts_with("define ") {
            inside = true;
        } else if line == "}" {
            inside = false;
        } else if inside && line.starts_with("  ") {
            out.push(line);
        }
    }
    out
}

/// The text between `key` and the next space (or the line's end).
fn field<'a>(line: &'a str, key: &str) -> Option<&'a str> {
    let rest = &line[line.find(key)? + key.len()..];
    Some(rest.split([' ', '"']).next().unwrap_or(rest))
}

fn string(m: &Module, id: Option<usize>) -> String {
    match id.and_then(|id| m.metadata.get(id)) {
        Some(Metadata::String(b)) => String::from_utf8_lossy(b).into_owned(),
        _ => String::new(),
    }
}

#[test]
fn locations_and_debug_intrinsics_are_the_listings() {
    let mut located = 0;
    let mut intrinsics = 0;
    for name in [
        "debug_info.vs",
        "debug_info.ps",
        "debug_info.ps.od",
        "debug_info.gs",
        "debug_info.hs",
        "debug_info.ds",
        "debug_info.cs",
        "debug_info.cs.od",
        "debug_info.lib",
    ] {
        let (m, listing) = read(name);
        let lines = instruction_lines(&listing);
        let instructions: Vec<_> = m
            .functions
            .iter()
            .flat_map(|f| f.instructions.iter().map(move |i| (f, i)))
            .collect();
        assert_eq!(instructions.len(), lines.len(), "{name}: instructions");
        for ((f, inst), line) in instructions.into_iter().zip(lines) {
            let callee = match &inst.op {
                Op::Call { function, .. } => m.name(*function),
                _ => None,
            };
            if let Some(var) = line.split(" ; var:\"").nth(1) {
                // llvm.dbg.value(value, offset, variable, expression); llvm.dbg.declare(address, variable, expression)
                let Op::Call { args, .. } = &inst.op else {
                    panic!("{name}: {line}")
                };
                let at = if callee == Some("llvm.dbg.value") { 2 } else { 1 };
                let node = |a: usize| match &f.locals[args[a] - f.first] {
                    Value::Metadata(md) => &m.metadata[*md],
                    other => panic!("{name}: argument {a} is {other:?}"),
                };
                let Metadata::Debug {
                    node: DebugNode::LocalVariable { name: variable, .. },
                    ..
                } = node(at)
                else {
                    panic!("{name}: {line}")
                };
                assert_eq!(
                    string(&m, *variable),
                    var.split('"').next().unwrap(),
                    "{name}: {line}"
                );
                assert!(
                    matches!(
                        node(at + 1),
                        Metadata::Debug {
                            node: DebugNode::Expression(_),
                            ..
                        }
                    ),
                    "{name}: {line}"
                );
                // the described value is a value as metadata: the body's own (a value of the body), or the module's (a
                // constant)
                let Value::Metadata(value) = &f.locals[args[0] - f.first] else {
                    panic!("{name}: {line}")
                };
                let described = match value.checked_sub(f.first_metadata) {
                    Some(own) => &f.metadata[own],
                    None => &m.metadata[*value],
                };
                assert!(matches!(described, Metadata::Value { .. }), "{name}: {line}");
                intrinsics += 1;
            } else if let Some(l) = field(line, "; line:") {
                let loc = inst
                    .debug_loc
                    .unwrap_or_else(|| panic!("{name}: no location for {line}"));
                assert_eq!(loc.line.to_string(), l, "{name}: {line}");
                assert_eq!(
                    loc.column.to_string(),
                    field(line, " col:").unwrap(),
                    "{name}: {line}"
                );
                located += 1;
            } else if !line.contains("!dbg") {
                assert!(
                    inst.debug_loc.is_none_or(|l| l.scope.is_none() || l.line == 0),
                    "{name}: {line}"
                );
            }
        }
    }
    // every comment of dxc's listings compared: they print 573 `; line:` and 261 `; var:` comments
    assert_eq!((located, intrinsics), (573, 261));
}

#![allow(clippy::unwrap_used)]
//! The `PSV0` part against the metadata of the same program: on every committed fixture that has one (dxc output) its
//! stage, thread group, resource ranges, signature elements and vector counts equal what the reflection reads from the
//! module, and a hand-built part is read field by field and refused where it is cut or of another layout.
use dxil_reader::psv::{self, Element, Psv, Resource};
use dxil_reader::reflection;

fn words(w: &[u32]) -> Vec<u8> {
    w.iter().flat_map(|w| w.to_le_bytes()).collect()
}

/// A part with a 52-byte runtime info: a compute program with an 8x4x1 group, a constant buffer record and a sampler
/// record (24 bytes each), the string table "main\0TEXCOORD\0" and two pad bytes, three semantic indices, one input
/// element and one output element, and two dependency words.
fn part() -> Vec<u8> {
    let mut info = [0u32; 13];
    info[0] = 7;
    info[5] = u32::MAX;
    // stage 5, no view id, the u16 0x0102, one input and one output element, no patch constants, 3 input vectors
    info[6] = 5 | 0x0102 << 16;
    info[7] = 1 | 1 << 8 | 3 << 24;
    // 2 output vectors in stream 0
    info[8] = 2;
    info[9] = 8;
    info[10] = 4;
    info[11] = 1;
    info[12] = 0;
    let mut out = words(&[52]);
    out.extend(words(&info));
    out.extend(words(&[2, 24]));
    out.extend(words(&[2, 0, 3, 3, 13, 0]));
    out.extend(words(&[1, 0, 0, 0, 14, 1]));
    out.extend(words(&[16]));
    out.extend(b"main\0TEXCOORD\0\0\0");
    out.extend(words(&[3, 2, 4, 5]));
    out.extend(words(&[16]));
    // input: name 5, indices 0, one row from row 0, 3 columns from column 1, allocated, kind 0, component 3, interpolation 2
    out.extend([5, 0, 0, 0, 0, 0, 0, 0, 1, 0, 3 | 1 << 4 | 1 << 6, 0, 3, 2, 0, 0]);
    // output: name 5, indices 1, one row from row 2, 4 columns, allocated, dynamic index mask 1 and stream 1
    out.extend([5, 0, 0, 0, 1, 0, 0, 0, 1, 2, 4 | 1 << 6, 0, 3, 2, 0x10 | 1, 0]);
    out.extend(words(&[0xaaaa_0001, 0xbbbb_0002]));
    out
}

#[test]
fn a_part_is_read_field_by_field() {
    let mut bytes = part();
    let p = psv::read(&bytes).unwrap();
    assert_eq!(p.runtime.stage, 5);
    assert_eq!(p.runtime.stage_data, 0x0102);
    assert_eq!(p.runtime.element_counts, [1, 1, 0]);
    assert_eq!(
        (p.runtime.input_vectors, p.runtime.output_vectors),
        (3, [2, 0, 0, 0])
    );
    assert_eq!(p.runtime.num_threads, Some([8, 4, 1]));
    assert_eq!(
        (p.runtime.min_wave_lanes, p.runtime.max_wave_lanes),
        (0, u32::MAX)
    );
    assert_eq!(p.runtime.stage_words[0], 7);
    assert_eq!(p.string(p.runtime.entry_name.unwrap()).unwrap(), "main");
    assert_eq!(
        p.resources,
        [
            Resource {
                resource_type: 2,
                space: 0,
                lower: 3,
                upper: 3,
                kind: Some(13),
                flags: Some(0)
            },
            Resource {
                resource_type: 1,
                space: 0,
                lower: 0,
                upper: 0,
                kind: Some(14),
                flags: Some(1)
            },
        ]
    );
    assert_eq!(p.semantic_indices, [2, 4, 5]);
    let input: &Element = p.inputs.first().unwrap();
    assert_eq!(
        (input.rows, input.start_row, input.columns, input.start_column),
        (1, 0, 3, 1)
    );
    assert!(
        input.allocated && input.semantic_kind == 0 && input.component_type == 3 && input.interpolation == 2
    );
    assert_eq!(p.string(input.name).unwrap(), "TEXCOORD");
    assert_eq!(p.element_indices(input).unwrap(), [2]);
    let output = p.outputs.first().unwrap();
    assert_eq!(
        (
            output.start_row,
            output.columns,
            output.dynamic_index_mask,
            output.stream
        ),
        (2, 4, 1, 1)
    );
    assert_eq!(p.element_indices(output).unwrap(), [4]);
    assert!(p.patch_constants.is_empty());
    assert_eq!(p.dependencies, [0xaaaa_0001, 0xbbbb_0002]);

    // a 36-byte runtime info and a 16-byte record: no thread group, entry name, kind or flags
    let mut short = words(&[36]);
    short.extend(words(&[0; 9]));
    short.extend(words(&[1, 16, 3, 0, 5, 5, 0, 0, 0]));
    let p: Psv = psv::read(&short).unwrap();
    assert_eq!(
        p.resources,
        [Resource {
            resource_type: 3,
            space: 0,
            lower: 5,
            upper: 5,
            kind: None,
            flags: None
        }]
    );
    assert_eq!((p.runtime.num_threads, p.runtime.entry_name), (None, None));

    // one byte more than a whole number of words
    bytes.push(0);
    assert!(
        psv::read(&bytes)
            .unwrap_err()
            .to_string()
            .contains("not a whole number of words")
    );
}

#[test]
fn a_part_of_another_layout_or_cut_short_is_refused() {
    let bytes = part();
    // a part cut inside the elements or before them is refused; the dependency tables are all that may be missing
    for n in 0..bytes.len() - 8 {
        assert!(psv::read(&bytes[..n]).is_err(), "prefix {n}");
    }
    let set = |at: usize, v: u32| {
        let mut b = part();
        b[at..at + 4].copy_from_slice(&v.to_le_bytes());
        b
    };
    assert!(
        psv::read(&set(0, 24))
            .unwrap_err()
            .to_string()
            .contains("only 36, 48 and 52")
    );
    // the resource record size is the word after the count that follows the 52 bytes of runtime info
    assert!(
        psv::read(&set(4 + 52 + 4, 20))
            .unwrap_err()
            .to_string()
            .contains("records of 20 bytes")
    );
    // a string table that claims more than the part holds
    assert!(psv::read(&set(4 + 52 + 4 + 4 + 48, 4000)).is_err());
    // an element size other than 16
    let element_size = 4 + 52 + 8 + 48 + 4 + 16 + 4 + 12;
    assert!(
        psv::read(&set(element_size, 24))
            .unwrap_err()
            .to_string()
            .contains("elements of 24 bytes")
    );
    let p = psv::read(&part()).unwrap();
    assert!(p.string(1000).is_err());
    // the last bytes of the table are padding: a name starting there is empty
    assert_eq!(p.string(15).unwrap(), "");
    // a table whose last string has no end
    let mut unterminated = words(&[36]);
    unterminated.extend(words(&[0; 9]));
    unterminated.extend(words(&[0, 4]));
    unterminated.extend(b"abcd");
    unterminated.extend(words(&[0]));
    let p = psv::read(&unterminated).unwrap();
    assert!(p.string(2).unwrap_err().to_string().contains("without its end"));
}

fn fixtures() -> Vec<(String, Vec<u8>)> {
    let dir = std::path::Path::new(env!("CARGO_MANIFEST_DIR")).join("tests/fixtures");
    let mut out: Vec<_> = std::fs::read_dir(dir)
        .unwrap()
        .map(|e| e.unwrap().path())
        .filter(|p| p.extension().is_some_and(|e| e == "dxil"))
        .map(|p| {
            (
                p.file_name().unwrap().to_string_lossy().into_owned(),
                std::fs::read(p).unwrap(),
            )
        })
        .collect();
    out.sort();
    out
}

/// PSV resource type -> DXIL resource class (0 SRV, 1 UAV, 2 constant buffer, 3 sampler).
fn class(resource_type: u32) -> u32 {
    match resource_type {
        1 => 3,
        2 => 2,
        3..=5 => 0,
        _ => 1,
    }
}

#[test]
fn the_part_agrees_with_the_metadata_on_every_fixture() {
    let mut checked = 0;
    let mut sizes = std::collections::BTreeMap::<(u32, u32), usize>::new();
    for (name, bytes) in fixtures() {
        let chunks = dxil_reader::parts(&bytes).unwrap();
        let Some(p) = psv::part(&chunks).unwrap_or_else(|e| panic!("{name}: {e}")) else {
            continue;
        };
        let program = dxil_reader::part(&bytes).unwrap();
        let info_size = if p.runtime.entry_name.is_some() {
            52
        } else if p.runtime.num_threads.is_some() {
            48
        } else {
            36
        };
        *sizes.entry((info_size, program.dxil_version)).or_default() += 1;
        assert_eq!(
            u32::from(p.runtime.stage),
            program.program_version >> 16,
            "{name}: stage"
        );
        let m = dxil_reader::module(&chunks, b"DXIL").unwrap().unwrap();
        // mesh and ray tracing entry points state their own kind of properties: the stage is all that is compared
        if name.contains("mesh") || name.contains("ray") {
            checked += 1;
            continue;
        }
        if let Some(threads) = reflection::num_threads(&m).unwrap() {
            assert_eq!(p.runtime.num_threads, Some(threads), "{name}: thread group");
        }
        let mut from_psv: Vec<_> = p
            .resources
            .iter()
            .map(|r| (class(r.resource_type), r.space, r.lower, r.upper))
            .collect();
        let mut from_metadata: Vec<_> = reflection::ranges(&m)
            .unwrap()
            .iter()
            .map(|(r, ..)| {
                let upper = if r.count == u32::MAX {
                    u32::MAX
                } else {
                    r.lower + r.count - 1
                };
                (u32::from(r.class), r.space, r.lower, upper)
            })
            .collect();
        from_psv.sort_unstable();
        from_metadata.sort_unstable();
        assert_eq!(from_psv, from_metadata, "{name}: resources");
        // the part lists constant buffers, samplers, SRVs, then UAVs
        let rank = |t: u32| [2, 3, 0, 1][class(t) as usize];
        assert!(
            p.resources
                .windows(2)
                .all(|w| rank(w[0].resource_type) <= rank(w[1].resource_type)),
            "{name}: resource order"
        );
        let (inputs, outputs) = reflection::elements(&m).unwrap();
        let patch = reflection::patch_elements(&m).unwrap();
        for (label, in_psv, in_metadata) in [
            ("input", &p.inputs, &inputs),
            ("output", &p.outputs, &outputs),
            ("patch", &p.patch_constants, &patch),
        ] {
            assert_eq!(in_psv.len(), in_metadata.len(), "{name}: {label} count");
            for (a, b) in in_psv.iter().zip(in_metadata) {
                let at = format!("{name}: {label} {}", b.name);
                assert_eq!(
                    (u32::from(a.rows), a.columns, a.semantic_kind, a.interpolation),
                    (b.rows, b.columns, b.system_value, b.interpolation),
                    "{at}"
                );
                assert_eq!(p.element_indices(a).unwrap().first(), Some(&b.index), "{at}");
                let named = if a.semantic_kind == 0 { b.name.as_str() } else { "" };
                assert_eq!(p.string(a.name).unwrap(), named, "{at}");
                assert_eq!(a.allocated, b.placed, "{at}");
                if b.placed {
                    assert_eq!(
                        (u32::from(a.start_row), a.start_column),
                        (b.row, b.column),
                        "{at}"
                    );
                }
                // the part's component types 1, 2, 3 are the metadata's 5, 4, 9
                let component = match a.component_type {
                    1 => 5,
                    2 => 4,
                    3 => 9,
                    other => other,
                };
                assert_eq!(component, b.component_type, "{at}");
            }
        }
        let vectors = |els: &[reflection::Element]| {
            els.iter()
                .filter(|e| e.placed)
                .map(|e| e.row + e.rows)
                .max()
                .unwrap_or(0)
        };
        assert_eq!(
            u32::from(p.runtime.input_vectors),
            vectors(&inputs),
            "{name}: input vectors"
        );
        assert_eq!(
            u32::from(p.runtime.output_vectors[0]),
            vectors(&outputs),
            "{name}: output vectors"
        );
        let counts = p.runtime.element_counts.map(usize::from);
        assert_eq!(
            counts,
            [inputs.len(), outputs.len(), patch.len()],
            "{name}: counts"
        );
        checked += 1;
    }
    println!("{checked} fixtures; (runtime info bytes, DXIL version) -> programs: {sizes:?}");
    assert!(checked >= 60, "{checked} fixtures with a PSV0 part");
}

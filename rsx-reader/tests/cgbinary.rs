use rsx_reader::cgbinary::{Stage, components, parse, parse_prefix};

fn word(b: &mut [u8], at: usize, value: u32) {
    b[at..at + 4].copy_from_slice(&value.to_be_bytes());
}

// Hand laid out, not a round trip through a writer: header 0..32,
// parameter 32..80, descriptor 80..104, strings 104..118,
// float2 defaults 120..128, patch table 128..140, microcode 144..176.
fn fixture(fragment: bool) -> Vec<u8> {
    let mut b = vec![0; 176];
    for (i, n) in [if fragment { 7004 } else { 7003 }, 6, 176, 1, 32, 80, 32, 144]
        .into_iter()
        .enumerate()
    {
        word(&mut b, i * 4, n);
    }
    for (i, n) in [1046, 2051, 4102, 3, 104, 120, 128, 111, 4097, u32::MAX, 1, 0]
        .into_iter()
        .enumerate()
    {
        word(&mut b, 32 + i * 4, n);
    }
    word(&mut b, 80, 2);
    if fragment {
        word(&mut b, 84, 0x12345678);
        word(&mut b, 88, 0x80000001);
        b[92..104].copy_from_slice(&[0, 3, 0, 2, 0, 1, 7, 1, 1, 1, 0xaa, 0xbb]);
    } else {
        for (i, n) in [9, 7, 0x12345678, 0x87654321, 15].into_iter().enumerate() {
            word(&mut b, 84 + i * 4, n);
        }
    }
    b[104..118].copy_from_slice(b"albedo\0COLOR0\0");
    word(&mut b, 120, (-0.0f32).to_bits());
    word(&mut b, 124, 0x7fc01234); // keep NaN payload, not a numeric conversion
    word(&mut b, 128, 2);
    word(&mut b, 132, 0);
    word(&mut b, 136, 16);
    for (i, byte) in b[144..].iter_mut().enumerate() {
        *byte = i as u8;
    }
    b
}

#[test]
fn fragment_fields_strings_defaults_and_patch_offsets_are_distinct() {
    let b = fixture(true);
    let p = parse(&b).unwrap();
    let Stage::Fragment(s) = p.stage else {
        panic!("fragment")
    };
    assert_eq!(
        (s.instruction_count, s.attribute_input_mask, s.partial_tex_type),
        (2, 0x12345678, 0x80000001)
    );
    assert_eq!(
        (s.tex_coords_input_mask, s.tex_coords_2d, s.tex_coords_centroid),
        (3, 2, 1)
    );
    assert_eq!(
        (
            s.register_count,
            s.output_from_h0,
            s.depth_replace,
            s.pixel_kill,
            s.padding
        ),
        (7, true, true, true, [0xaa, 0xbb])
    );
    let a = &p.parameters[0];
    assert_eq!(
        (
            a.ty,
            a.resource,
            a.variability,
            a.resource_index,
            a.direction,
            a.parameter_number
        ),
        (1046, 2051, 4102, 3, 4097, -1)
    );
    assert_eq!(
        (a.name, a.semantic),
        (Some(b"albedo".as_slice()), Some(b"COLOR0".as_slice()))
    );
    assert_eq!(a.default_value, Some(vec![0x80000000, 0x7fc01234]));
    assert_eq!(a.embedded_constants, [0, 16]);
    assert_eq!((a.referenced, a.shared, a.texture_unit()), (true, false, Some(3)));
    assert_eq!(p.microcode, (0..32).collect::<Vec<u8>>());
}

#[test]
fn vertex_fields_and_null_metadata_keep_their_meaning() {
    let mut b = fixture(false);
    for at in [48, 52, 56, 60] {
        word(&mut b, at, 0);
    }
    word(&mut b, 36, 2178); // constant register, not texture unit
    word(&mut b, 44, u32::MAX);
    let p = parse(&b).unwrap();
    let Stage::Vertex(s) = p.stage else {
        panic!("vertex")
    };
    assert_eq!(
        (s.instruction_count, s.instruction_slot, s.register_count),
        (2, 9, 7)
    );
    assert_eq!(
        (s.attribute_input_mask, s.attribute_output_mask, s.user_clip_mask),
        (0x12345678, 0x87654321, 15)
    );
    let a = &p.parameters[0];
    assert_eq!(
        (a.name, a.semantic, a.default_value.as_ref(), a.texture_unit()),
        (None, None, None, None)
    );
    assert!(a.embedded_constants.is_empty());
    assert_eq!(a.resource_index, -1);
}

#[test]
fn caller_owns_concatenation_and_padding() {
    let mut b = fixture(true);
    b.extend([0u8; 16]);
    b.extend(fixture(false));
    assert!(parse(&b).unwrap_err().detail.contains("trailing"));
    assert_eq!(parse_prefix(&b).unwrap().bytes.len(), 176);
    assert_eq!(parse(&b[192..]).unwrap().profile, 7003);
}

#[test]
fn invalid_headers_ranges_booleans_strings_and_constants_refuse() {
    for (at, value, why) in [
        (0, 1, "profile"),
        (4, 7, "revision"),
        (8, 31, "outside"),
        (8, 177, "outside"),
        (12, u32::MAX, "outside"),
        (16, 0, "overlapping"),
        (20, 32, "overlapping"),
        (20, 81, "unaligned"),
        (28, 80, "overlapping"),
        (28, 140, "16-byte"),
        (80, 3, "instruction"),
        (72, 2, "boolean"),
        (48, 32, "metadata"),
        (48, 176, "unterminated"),
        (52, 32, "metadata"),
        (52, 121, "unaligned"),
        (56, 32, "outside"),
        (128, u32::MAX, "outside"),
        (132, 1, "embedded"),
        (136, 32, "embedded"),
        (32, 9999, "not a numeric type"),
    ] {
        let mut b = fixture(true);
        word(&mut b, at, value);
        let e = parse(&b).expect_err("malformed fixture");
        assert!(
            e.detail.contains(why),
            "at={at} value={value}: {e}, expected {why}"
        );
    }
    let b = fixture(true);
    for len in 0..b.len() {
        assert!(parse(&b[..len]).is_err(), "truncation {len}");
    }
    let mut b = b;
    b[101] = 2;
    assert_eq!(parse(&b).unwrap_err().offset, 101);
}

#[test]
fn shared_strings_and_unknown_enum_codes_are_preserved() {
    let mut b = fixture(true);
    word(&mut b, 48, 112); // suffix of the semantic; valid shared string storage
    word(&mut b, 40, 9999);
    word(&mut b, 64, 8888);
    let p = parse(&b).unwrap();
    assert_eq!(p.parameters[0].name, Some(b"OLOR0".as_slice()));
    assert_eq!(
        (p.parameters[0].variability, p.parameters[0].direction),
        (9999, 8888)
    );
}

#[test]
fn matrix_defaults_and_metadata_at_the_exact_end_are_bounded() {
    let mut b = fixture(false);
    b.resize(240, 0);
    word(&mut b, 8, 240);
    word(&mut b, 28, 208);
    word(&mut b, 32, 1064); // CG_FLOAT4x4, sixteen IEEE float words
    word(&mut b, 48, 0);
    word(&mut b, 52, 112);
    word(&mut b, 56, 0);
    word(&mut b, 60, 207); // empty NUL-terminated string immediately before ucode
    for i in 0..16 {
        word(&mut b, 112 + i * 4, i as u32);
    }
    let p = parse(&b).unwrap();
    assert_eq!(p.parameters[0].default_value, Some((0..16).collect()));
    assert_eq!(p.parameters[0].semantic, Some(b"".as_slice()));
    word(&mut b, 52, 176); // matrix would cross into microcode
    assert!(parse(&b).unwrap_err().detail.contains("metadata"));
}

/// The `CGtype`s in the order of Cg's `cg_datatypes.h` (the enum counts from `CG_TYPE_START_ENUM` = 1024, so the first is
/// 1025), each with its component count read from its name: a scalar 1, `<base>N` N, `<base>RxC` R times C, and `None`
/// for the types that hold no numbers.
fn cg_datatypes() -> Vec<(u32, String, Option<usize>)> {
    let mut names = Vec::new();
    let shapes = |base: &str, names: &mut Vec<String>| {
        names.extend([
            base.to_owned(),
            format!("{base}2"),
            format!("{base}3"),
            format!("{base}4"),
        ]);
        for r in 1..=4 {
            for c in 1..=4 {
                names.push(format!("{base}{r}x{c}"));
            }
        }
    };
    shapes("half", &mut names);
    shapes("float", &mut names);
    names.extend(
        [
            "sampler1D",
            "sampler2D",
            "sampler3D",
            "samplerRECT",
            "samplerCUBE",
        ]
        .map(String::from),
    );
    shapes("fixed", &mut names);
    names.extend(["half1", "float1", "fixed1", "int", "int1"].map(String::from));
    let mut int = Vec::new();
    shapes("int", &mut int);
    names.extend(int.into_iter().skip(1));
    names.extend(["bool", "bool1"].map(String::from));
    let mut boolean = Vec::new();
    shapes("bool", &mut boolean);
    names.extend(boolean.into_iter().skip(1));
    names.extend(["string", "program", "texture"].map(String::from));
    names
        .into_iter()
        .zip(1025..)
        .map(|(name, ty)| {
            let digits = name.trim_start_matches(|c: char| c.is_ascii_alphabetic());
            let numeric = ["half", "float", "fixed", "int", "bool"]
                .iter()
                .any(|b| name.strip_prefix(b).is_some_and(|rest| rest == digits));
            let n = match digits.split_once('x') {
                _ if !numeric => None,
                Some((r, c)) => {
                    Some(r.parse::<usize>().expect("rows") * c.parse::<usize>().expect("columns"))
                }
                None if digits.is_empty() => Some(1),
                None => Some(digits.parse().expect("components")),
            };
            (ty, name, n)
        })
        .collect()
}

#[test]
fn every_numeric_type_takes_a_default_of_its_component_count() {
    let types = cg_datatypes();
    // the numbers Cg's headers give some of them: CG_FLOAT 1045, CG_FLOAT4x4 1064, CG_FIXED 1070, CG_FLOAT1 1091,
    // CG_FIXED1 1092, CG_INT 1093, CG_BOOL 1114, CG_TEXTURE 1137
    let number = |name: &str| types.iter().find(|(_, n, _)| n == name).expect(name).0;
    assert_eq!(
        [
            "float", "float4x4", "fixed", "float1", "fixed1", "int", "bool", "texture"
        ]
        .map(number),
        [1045, 1064, 1070, 1091, 1092, 1093, 1114, 1137]
    );
    let mut numeric = 0;
    for (ty, name, n) in &types {
        assert_eq!(components(*ty), *n, "{name} ({ty})");
        // a parameter of the type with a default at 112, as many words as the type has components (sixteen at most)
        let mut b = fixture(false);
        b.resize(240, 0);
        word(&mut b, 8, 240);
        word(&mut b, 28, 208);
        word(&mut b, 32, *ty);
        word(&mut b, 48, 0);
        word(&mut b, 52, 112);
        word(&mut b, 56, 0);
        word(&mut b, 60, 207);
        for i in 0..16 {
            word(&mut b, 112 + i * 4, 0x3f80_0000 + i as u32);
        }
        match n {
            Some(n) => {
                let p = parse(&b).unwrap_or_else(|e| panic!("{name} ({ty}): {e}"));
                let want: Vec<u32> = (0..*n as u32).map(|i| 0x3f80_0000 + i).collect();
                assert_eq!(p.parameters[0].default_value, Some(want), "{name}");
                numeric += 1;
            }
            None => {
                let e = parse(&b).expect_err(name);
                assert!(e.detail.contains("not a numeric type"), "{name}: {e}");
            }
        }
    }
    // 4 + 16 each of half, float, fixed, int and bool, and half1, float1, fixed1, int1, bool1
    assert_eq!((types.len(), numeric), (113, 105));
    assert_eq!(components(1024), None);
    assert_eq!(components(1138), None);
}

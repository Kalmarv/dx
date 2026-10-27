#![allow(clippy::unwrap_used)]
//! Bytes and metadata a compiler never writes: each must be an error that names where the bad record is, not a panic, an
//! over-allocation or a silently repaired value.
use dxil_reader::module::{Constant, Metadata, Module, Value};
use dxil_reader::{bitstream, reflection};

/// Bits, least significant first, as LLVM's bitstream writer emits them.
#[derive(Default)]
struct Bits {
    bytes: Vec<u8>,
    len: usize,
}
impl Bits {
    fn put(&mut self, mut value: u64, width: usize) {
        for _ in 0..width {
            if self.len.is_multiple_of(8) {
                self.bytes.push(0);
            }
            *self.bytes.last_mut().unwrap() |= ((value & 1) as u8) << (self.len % 8);
            value >>= 1;
            self.len += 1;
        }
    }
    fn vbr(&mut self, mut value: u64, width: usize) {
        let high = 1u64 << (width - 1);
        while value >= high {
            self.put((value & (high - 1)) | high, width);
            value >>= width - 1;
        }
        self.put(value, width);
    }
    fn align32(&mut self) {
        while !self.len.is_multiple_of(32) {
            self.put(0, 1);
        }
    }
}

/// A bitstream of one block (id 8, abbreviation width 3) that defines the abbreviation `[literal 1, array of element]`
/// and holds one record of it with `count` array elements, none of them stored.
fn array_record(element: impl Fn(&mut Bits), count: u64) -> Vec<u8> {
    let mut body = Bits::default();
    // DEFINE_ABBREV: three operands (the code literal, the array, its element)
    body.put(2, 3);
    body.vbr(3, 5);
    body.put(1, 1);
    body.vbr(1, 8);
    body.put(0, 1);
    body.put(3, 3);
    element(&mut body);
    // the record: abbreviation id 4, the array length
    body.put(4, 3);
    body.vbr(count, 6);
    // END_BLOCK
    body.put(0, 3);
    body.align32();
    let mut out = Bits::default();
    out.put(u64::from(u32::from_le_bytes(*b"BC\xc0\xde")), 32);
    out.put(1, 2);
    out.vbr(8, 8);
    out.vbr(3, 4);
    out.align32();
    out.put((body.len / 32) as u64, 32);
    let mut bytes = out.bytes;
    bytes.extend(body.bytes);
    bytes
}

fn literal_element(bits: &mut Bits) {
    bits.put(1, 1);
    bits.vbr(7, 8);
}

#[test]
fn an_array_of_literals_longer_than_the_stream_is_refused_before_it_is_allocated() {
    // 16 million elements from a stream of a few dozen bytes: the elements take no bits, so only the length bounds them
    let bytes = array_record(literal_element, 1 << 24);
    match bitstream::read(&bytes, *b"BC\xc0\xde") {
        Err(e) => assert!(e.detail.contains("array"), "{e}"),
        Ok(blocks) => panic!("read {} blocks", blocks.len()),
    }
    // a short one still reads
    let blocks = bitstream::read(&array_record(literal_element, 3), *b"BC\xc0\xde").unwrap();
    let record = blocks[0].records().next().unwrap();
    assert_eq!(record.operands, [7, 7, 7]);
}

/// A module whose `dx.typeAnnotations` holds one struct annotation for type 5 with these operands.
fn annotated(annotation: Vec<Option<usize>>) -> Module {
    Module {
        values: vec![Value::Constant(Constant::Integer(0))],
        metadata: vec![
            Metadata::Value { ty: 0, value: 0 },
            Metadata::Node(vec![Some(0), Some(2), Some(3)]),
            Metadata::Value { ty: 5, value: 0 },
            Metadata::Node(annotation),
        ],
        metadata_at: vec![100, 200, 300, 400],
        named_metadata: vec![("dx.typeAnnotations".to_owned(), vec![1])],
        named_metadata_at: vec![50],
        at: 10,
        ..Module::default()
    }
}

#[test]
fn a_struct_annotation_without_operands_is_an_error_at_its_record() {
    let e = reflection::fields(&annotated(Vec::new()), 5).unwrap_err();
    assert_eq!(e.bit, 400, "{e}");
    assert!(e.detail.contains("struct annotation"), "{e}");
    // with its first operand and no fields it is empty
    assert!(reflection::fields(&annotated(vec![None]), 5).unwrap().is_empty());
}

#[test]
fn reflection_errors_name_the_record_they_are_about() {
    // an entry point (metadata record 1) whose operand 0 is a function value and which has no properties
    let mut m = Module {
        values: vec![Value::Constant(Constant::Integer(0))],
        metadata: vec![
            Metadata::Value { ty: 0, value: 0 },
            Metadata::Node(vec![Some(0), None, None, None, None]),
        ],
        metadata_at: vec![100, 200],
        named_metadata: vec![("dx.entryPoints".to_owned(), vec![1])],
        named_metadata_at: vec![50],
        at: 10,
        ..Module::default()
    };
    assert_eq!(reflection::library_kind(&m).unwrap_err().bit, 200);
    // no entry points metadata at all: the error is at the module
    m.named_metadata.clear();
    assert_eq!(reflection::entry(&m).unwrap_err().bit, 10);
    // two entry points with functions: at the named record
    m.named_metadata = vec![("dx.entryPoints".to_owned(), vec![1, 1])];
    assert_eq!(reflection::entry(&m).unwrap_err().bit, 50);
}

#[test]
fn a_metadata_string_that_is_not_utf8_is_an_error_not_a_replacement() {
    // a signature element whose name (operand 1) is the bytes 0xff 0xfe
    let int = |i| Metadata::Value { ty: 0, value: i };
    let mut m = Module {
        values: vec![
            Value::Constant(Constant::Integer(0)),
            Value::Constant(Constant::Integer(1)),
        ],
        metadata: vec![
            int(0),
            int(1),
            Metadata::String(vec![0xff, 0xfe]),
            // the element: id, name, type, system value, indices, interpolation, rows, columns, row, column
            Metadata::Node(vec![
                Some(0),
                Some(2),
                Some(0),
                Some(0),
                None,
                Some(0),
                Some(1),
                Some(1),
                Some(0),
                Some(0),
            ]),
            // the input list, the signatures, the entry point
            Metadata::Node(vec![Some(3)]),
            Metadata::Node(vec![Some(4), None, None]),
            Metadata::Node(vec![Some(0), None, Some(5), None, None]),
        ],
        metadata_at: vec![0, 1, 2, 300, 400, 500, 600],
        named_metadata: vec![("dx.entryPoints".to_owned(), vec![6])],
        named_metadata_at: vec![50],
        at: 10,
        ..Module::default()
    };
    let e = reflection::elements(&m).unwrap_err();
    assert_eq!(e.bit, 300, "{e}");
    assert!(e.detail.contains("UTF-8"), "{e}");
    m.metadata[2] = Metadata::String(b"POSITION".to_vec());
    assert_eq!(reflection::elements(&m).unwrap().0[0].name, "POSITION");
}

#[test]
fn a_signature_name_that_is_not_utf8_is_an_error_at_its_byte() {
    // one record at byte 8 (stream, name offset, ...) naming the string at byte 40
    let mut part = Vec::new();
    for w in [1u32, 8, 0, 40] {
        part.extend(w.to_le_bytes());
    }
    part.extend([0u8; 24]);
    part.extend([0xff, 0xfe, 0]);
    let e = reflection::signature(&part).unwrap_err();
    assert_eq!(e.bit, 40 * 8, "{e}");
    assert!(e.detail.contains("UTF-8"), "{e}");
}

#[test]
fn operations_counts_each_dx_op_call_of_a_fixture_once() {
    let path = std::path::Path::new(env!("CARGO_MANIFEST_DIR")).join("tests/fixtures/draw_colour.dxil");
    let container = std::fs::read(path).unwrap();
    let (kind, operations) = dxil_reader::operations(&container).unwrap();
    assert_eq!(kind, 0, "a pixel program");
    let total: usize = operations.values().sum();
    let module = dxil_reader::module(&dxil_reader::parts(&container).unwrap(), b"DXIL")
        .unwrap()
        .unwrap();
    let calls = module
        .functions
        .iter()
        .flat_map(|f| &f.instructions)
        .filter(|i| {
            matches!(&i.op, dxil_reader::module::Op::Call { function, .. }
                if module.name(*function).is_some_and(|n| n.starts_with("dx.op.")))
        })
        .count();
    assert!(total > 0);
    assert_eq!(total, calls);
    assert!(
        operations.keys().all(|k| k.starts_with("dx.op.")),
        "{operations:?}"
    );
}

#[test]
fn every_committed_fixture_reads_to_a_module_with_its_reflection() {
    let dir = std::path::Path::new(env!("CARGO_MANIFEST_DIR")).join("tests/fixtures");
    let mut read = 0;
    for entry in std::fs::read_dir(dir).unwrap() {
        let path = entry.unwrap().path();
        if path.extension().is_none_or(|e| e != "dxil") {
            continue;
        }
        let name = path.display();
        let container = std::fs::read(&path).unwrap();
        let chunks = dxil_reader::parts(&container).unwrap_or_else(|e| panic!("{name}: {e}"));
        let module = dxil_reader::module(&chunks, b"DXIL")
            .unwrap_or_else(|e| panic!("{name}: {e}"))
            .unwrap();
        // the reflection that every program of a fixture states (a library has no single entry point)
        if reflection::entry(&module).is_ok() {
            reflection::elements(&module).unwrap_or_else(|e| panic!("{name}: {e}"));
            reflection::ranges(&module).unwrap_or_else(|e| panic!("{name}: {e}"));
        }
        read += 1;
    }
    assert!(read >= 100, "{read} fixtures");
}

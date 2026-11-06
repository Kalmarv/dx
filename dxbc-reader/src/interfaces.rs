//! The `IFCE` part of a Shader Model 5 program with class linkage (dynamic shader linkage): the classes that
//! implement its interfaces, the class instances its constant buffers hold, and which function tables each interface
//! slot can be bound to.
//!
//! The layout below was read from containers fxc 10.0.26100.4654 built with one to thirty classes per interface,
//! interface arrays, several interfaces, classes with data, textures and samplers, instance arrays, and pixel and hull
//! programs, each checked against `D3DDisassemble`'s printing of the same tables. Words, from the start of the part:
//!
//! - 0 to 3: the counts of class instances, class types and slot records, and the number of interface slots;
//! - 4 to 6: the byte offsets of the instance table (16 bytes a record), the type table (12) and the slot records
//!   (16);
//! - 7 and 8: 0 in every container seen.
//!
//! Offsets are from the start of the part; names are zero-terminated strings after the tables.
use crate::reflection::View;
use crate::{Result, error, parts};

/// A class that implements an interface, by its place in the type table (its id).
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct ClassType {
    /// The class's name.
    pub name: String,
    /// The constant buffer registers one instance's data takes.
    pub stride: u16,
    /// The textures one instance holds.
    pub textures: u16,
    /// The samplers one instance holds.
    pub samplers: u16,
    /// The low half of the record's second word, 0 in every container seen.
    pub reserved: u16,
}

/// A class instance in a constant buffer, or an array of them (`suns[3]`).
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct ClassInstance {
    /// The instance's name.
    pub name: String,
    /// The class type's id.
    pub ty: u16,
    /// The number of instances, more than 1 for an array.
    pub count: u16,
    /// The constant buffer its data is in; `None` for a class without data.
    pub buffer: Option<u16>,
    /// The register of that buffer its data starts at; `None` for a class without data.
    pub offset: Option<u16>,
    /// The first texture register it holds; `None` where it holds none.
    pub texture: Option<u16>,
    /// The first sampler register it holds; `None` where it holds none.
    pub sampler: Option<u16>,
}

/// A run of interface slots (one interface pointer, or an array of them) and the classes that can be bound to it.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct InterfaceSlots {
    /// The number of slots it takes.
    pub span: u32,
    /// The class type ids that can be bound to it.
    pub types: Vec<u16>,
    /// The function table of each, at the same place as its type id.
    pub tables: Vec<u32>,
}

/// The `IFCE` part.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct Interfaces {
    /// The number of interface slots (word 3).
    pub slot_count: u32,
    /// The class types, by id.
    pub types: Vec<ClassType>,
    /// The class instances.
    pub instances: Vec<ClassInstance>,
    /// The slot records, in slot order.
    pub slots: Vec<InterfaceSlots>,
    /// Words 7 and 8.
    pub reserved: [u32; 2],
}

/// A 16-bit register field, where `0xffff` is none.
fn register(value: u16) -> Option<u16> {
    (value != 0xffff).then_some(value)
}

/// The container's `IFCE` part; `None` without one. Refuses a container [`parts`] refuses and a part whose tables or
/// names lie outside it, naming the word.
pub fn interfaces(bytes: &[u8]) -> Result<Option<Interfaces>> {
    let directory = parts(bytes)?;
    let Some(chunk) = directory.iter().find(|c| &c.kind == b"IFCE") else {
        return Ok(None);
    };
    let v = View(chunk.data);
    let word = |n: usize| v.u32(n.saturating_mul(4));
    let count = |n: usize| -> Result<usize> {
        usize::try_from(word(n)?)
            .map_err(|_| error(n, format!("IFCE word {n}: the count exceeds the address space")))
    };
    let offset = |n: usize| -> Result<usize> {
        usize::try_from(word(n)?)
            .map_err(|_| error(n, format!("IFCE word {n}: the offset exceeds the address space")))
    };
    let (instance_count, type_count, record_count) = (count(0)?, count(1)?, count(2)?);
    let (instance_at, type_at, record_at) = (offset(4)?, offset(5)?, offset(6)?);
    let mut types = Vec::new();
    for i in v.table(type_at, type_count, 12)? {
        let p = v.record(type_at, i, 12)?;
        types.push(ClassType {
            name: v.string(v.u32(p)? as usize)?,
            reserved: v.field16(p, 4)?,
            stride: v.field16(p, 6)?,
            textures: v.field16(p, 8)?,
            samplers: v.field16(p, 10)?,
        });
    }
    let mut instances = Vec::new();
    for i in v.table(instance_at, instance_count, 16)? {
        let p = v.record(instance_at, i, 16)?;
        instances.push(ClassInstance {
            name: v.string(v.u32(p)? as usize)?,
            ty: v.field16(p, 4)?,
            count: v.field16(p, 6)?,
            buffer: register(v.field16(p, 8)?),
            offset: register(v.field16(p, 10)?),
            texture: register(v.field16(p, 12)?),
            sampler: register(v.field16(p, 14)?),
        });
    }
    let mut slots = Vec::new();
    for i in v.table(record_at, record_count, 16)? {
        let p = v.record(record_at, i, 16)?;
        let entries = v.field(p, 4)? as usize;
        let (type_ids, table_ids) = (v.field(p, 8)? as usize, v.field(p, 12)? as usize);
        let mut record = InterfaceSlots {
            span: v.u32(p)?,
            types: Vec::new(),
            tables: Vec::new(),
        };
        for j in v.table(type_ids, entries, 2)? {
            record.types.push(v.u16(v.record(type_ids, j, 2)?)?);
        }
        for j in v.table(table_ids, entries, 4)? {
            record.tables.push(v.u32(v.record(table_ids, j, 4)?)?);
        }
        slots.push(record);
    }
    Ok(Some(Interfaces {
        slot_count: word(3)?,
        types,
        instances,
        slots,
        reserved: [word(7)?, word(8)?],
    }))
}

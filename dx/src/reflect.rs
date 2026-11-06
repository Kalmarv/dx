//! `dx reflect` and `dx info`: what a program's container states about it, as JSON. Every record keeps D3D's own
//! numbers beside the names Microsoft's disassembler gives them, so a caller can use either.
use serde_json::{Value, json};

use dxbc_reader::reflection::{Rdef, RdefType, SignatureElement};
use dxbc_reader::{ProgramType, chunk, parts, signature};

use crate::files::{Kind, kind};

fn hex(bytes: &[u8]) -> String {
    bytes.iter().map(|b| format!("{b:02x}")).collect()
}

/// A component mask as letters: `xyzw`, `xy`, empty for none.
fn mask(mask: u8) -> String {
    ['x', 'y', 'z', 'w']
        .iter()
        .enumerate()
        .filter(|&(bit, _)| mask & (1 << bit) != 0)
        .map(|(_, &c)| c)
        .collect()
}

/// A stored default value as its 32-bit words, in hex.
fn words(bytes: &[u8]) -> Vec<String> {
    bytes
        .as_chunks::<4>()
        .0
        .iter()
        .map(|w| format!("0x{:08x}", u32::from_le_bytes(*w)))
        .collect()
}

/// A Shader Model 4 or 5 program's target (`ps_5_0`) from its code part's version token.
fn dxbc_target(bytes: &[u8]) -> Result<(ProgramType, String), String> {
    let directory = parts(bytes).map_err(|e| e.to_string())?;
    let kind = dxbc_reader::program_type(&directory).map_err(|e| e.to_string())?;
    let token = dxbc_reader::code(bytes).map_err(|e| e.to_string())?;
    let version = token.first().copied().unwrap_or(0);
    Ok((
        kind,
        format!("{}_{}_{}", kind.name(), (version >> 4) & 0xf, version & 0xf),
    ))
}

fn rdef_type(ty: &RdefType) -> Value {
    json!({
        "name": ty.type_name(),
        "stored_name": ty.name,
        "class": ty.class,
        "type": ty.scalar,
        "type_name": ty.scalar_name(),
        "rows": ty.rows,
        "columns": ty.columns,
        "elements": ty.elements,
        "members": ty.members.iter().map(|m| json!({
            "name": m.name,
            "offset": m.offset,
            "type": rdef_type(&m.ty),
        })).collect::<Vec<_>>(),
    })
}

/// A first register and a count, `null` where there are none.
fn registers([start, count]: [u32; 2]) -> Value {
    if count == 0 {
        Value::Null
    } else {
        json!({ "start": start, "count": count })
    }
}

/// The class linkage tables of an `IFCE` part.
fn interfaces(i: &dxbc_reader::Interfaces) -> Value {
    json!({
        "slot_count": i.slot_count,
        "types": i.types.iter().enumerate().map(|(id, t)| json!({
            "id": id,
            "name": t.name,
            "stride": t.stride,
            "textures": t.textures,
            "samplers": t.samplers,
            "reserved": t.reserved,
        })).collect::<Vec<_>>(),
        "instances": i.instances.iter().map(|c| json!({
            "name": c.name,
            "type": c.ty,
            "count": c.count,
            "buffer": c.buffer,
            "offset": c.offset,
            "texture": c.texture,
            "sampler": c.sampler,
        })).collect::<Vec<_>>(),
        "slots": i.slots.iter().map(|r| json!({
            "span": r.span,
            "types": r.types,
            "tables": r.tables,
        })).collect::<Vec<_>>(),
        "reserved": i.reserved,
    })
}

fn rdef(r: &Rdef) -> Value {
    json!({
        "target": format!("0x{:08x}", r.target),
        "flags": format!("0x{:08x}", r.flags),
        "creator": r.creator,
        "bindings": r.bindings.iter().map(|b| json!({
            "name": b.name,
            "type": b.type_name(),
            "input_type": b.kind,
            "format": b.format_name(),
            "return_type": b.returns,
            "dimension": b.dimension_name(),
            "srv_dimension": b.dimension,
            "samples": b.samples,
            "bind": if b.space != 0 {
                format!("{}{},space{}", b.register_prefix(), b.register, b.space)
            } else {
                format!("{}{}", b.register_prefix(), b.register)
            },
            "register": b.register,
            "space": b.space,
            "count": b.count,
            "flags": b.flags,
            "id": b.id,
        })).collect::<Vec<_>>(),
        "buffers": r.buffers.iter().map(|b| json!({
            "name": b.name,
            "kind": b.kind,
            "size": b.size,
            "variables": b.variables.iter().map(|v| json!({
                "name": v.name,
                "offset": v.offset,
                "size": v.size,
                "flags": v.flags,
                // D3D_SVF_USED
                "used": v.flags & 2 != 0,
                "type": rdef_type(&v.ty),
                "default": v.default.as_deref().map(words),
                // the registers a class instance holds
                "textures": registers(v.textures),
                "samplers": registers(v.samplers),
            })).collect::<Vec<_>>(),
        })).collect::<Vec<_>>(),
    })
}

fn elements(elements: &[SignatureElement], output: bool, kind: ProgramType) -> Value {
    elements
        .iter()
        .map(|e| {
            // an output's stored mask is of the components the program never writes
            let used = if output {
                e.mask & !e.read_write_mask
            } else {
                e.read_write_mask
            };
            json!({
                "name": e.name,
                "index": e.index,
                "system_value": e.system_value_for(output, kind),
                "system_value_name": e.system_value_name(output, kind),
                "component_type": e.component_type,
                "format": e.format_name(),
                "register": (e.register != u32::MAX).then_some(e.register),
                "mask": mask(e.mask),
                "used": mask(used),
                "stream": e.stream,
                "min_precision": e.min_precision,
            })
        })
        .collect()
}

fn dxbc(bytes: &[u8]) -> Result<Value, String> {
    let fail = |e: dxbc_reader::Error| e.to_string();
    let directory = parts(bytes).map_err(fail)?;
    let (kind, target) = dxbc_target(bytes)?;
    let mut signatures = serde_json::Map::new();
    for (name, tags, output) in [
        ("input", &[b"ISGN", b"ISG1"][..], false),
        ("output", &[b"OSGN", b"OSG1", b"OSG5"][..], true),
        // a hull program writes its patch constants, a domain program reads them
        (
            "patch_constant",
            &[b"PCSG", b"PSG1"][..],
            kind == ProgramType::Hull,
        ),
    ] {
        if let Some(tag) = tags.iter().find(|t| directory.iter().any(|c| &&c.kind == *t)) {
            let read = signature(chunk(&directory, tag).map_err(fail)?, tag).map_err(fail)?;
            signatures.insert(name.to_owned(), elements(&read, output, kind));
        }
    }
    let statistics = dxbc_reader::statistics(bytes).map_err(fail)?.map(|s| {
        json!({
            "instructions": s.instructions(),
            "temp_registers": s.temp_registers(),
            "declarations": s.declarations(),
            "float_instructions": s.float_instructions(),
            "int_instructions": s.int_instructions(),
            "uint_instructions": s.uint_instructions(),
            "static_flow_control": s.static_flow_control(),
            "dynamic_flow_control": s.dynamic_flow_control(),
            "texture_normal": s.texture_normal(),
            "texture_load": s.texture_load(),
            "texture_comparison": s.texture_comparison(),
            "texture_gradient": s.texture_gradient(),
            "movc_instructions": s.movc_instructions(),
            "sample_frequency": s.sample_frequency(),
            "control_points": s.control_points(),
            "tessellator_output_primitive": s.tessellator_output_primitive(),
            "tessellator_partitioning": s.tessellator_partitioning(),
            "tessellator_domain": s.tessellator_domain(),
            "words": s.words,
        })
    });
    let features = dxcontainer::feature_flags(bytes)
        .map_err(|e| e.to_string())?
        .map(|f| {
            json!({
                "bits": format!("0x{:016x}", f.bits),
                "names": f.names(),
                "unnamed": format!("0x{:x}", f.unnamed()),
            })
        });
    let level9 = dxbc_reader::level9(bytes).map_err(fail)?.map(|l| {
        let scalars = |rows: &[dxbc_reader::ScalarMapping]| {
            rows.iter()
                .map(|m| {
                    json!({
                        "buffer": m.buffer,
                        "source": m.source,
                        "component": m.component,
                        "target": m.target,
                    })
                })
                .collect::<Vec<_>>()
        };
        json!({
            "version": format!("0x{:08x}", l.version),
            "program_offset": l.program_offset,
            "program_size": l.program.len(),
            "constants": l.constants.iter().map(|m| json!({
                "buffer": m.buffer,
                "start": m.start,
                "count": m.count,
                "target": m.target,
                "conversion": m.conversion,
            })).collect::<Vec<_>>(),
            "integers": scalars(&l.integers),
            "booleans": scalars(&l.booleans),
            "samplers": l.samplers.iter().map(|m| json!({
                "resource": m.resource,
                "sampler": m.sampler,
                "target": m.target,
            })).collect::<Vec<_>>(),
            "runtime": l.runtime.iter().map(|m| json!({
                "kind": m.kind,
                "target": m.target,
            })).collect::<Vec<_>>(),
        })
    });
    Ok(json!({
        "format": "dxbc",
        "target": target,
        "rdef": dxbc_reader::reflection::rdef(bytes).map_err(fail)?.as_ref().map(rdef),
        "signatures": signatures,
        "statistics": statistics,
        "features": features,
        "level9": level9,
        "interfaces": dxbc_reader::interfaces(bytes).map_err(fail)?.as_ref().map(interfaces),
    }))
}

fn d3d9_type(ty: &d3d9_reader::Type) -> Value {
    json!({
        "class": ty.class,
        "type": ty.kind,
        "rows": ty.rows,
        "columns": ty.columns,
        "elements": ty.elements,
        "members": ty.members.iter().map(|m| json!({
            "name": m.name,
            "type": d3d9_type(&m.ty),
        })).collect::<Vec<_>>(),
    })
}

fn d3d9(bytes: &[u8]) -> Result<Value, String> {
    let program = d3d9_reader::read(bytes).map_err(|e| e.to_string())?;
    let constants = program.constants.as_ref().map(|t| {
        json!({
            "creator": t.creator,
            "target": t.target,
            "version": format!("0x{:08x}", t.version),
            "flags": format!("0x{:08x}", t.flags),
            "constants": t.constants.iter().map(|c| {
                let prefix = match c.register_set {
                    0 => "b",
                    1 => "i",
                    3 => "s",
                    _ => "c",
                };
                json!({
                    "name": c.name,
                    "register_set": c.register_set,
                    "register": format!("{prefix}{}", c.register),
                    "count": c.count,
                    "type": d3d9_type(&c.ty),
                    "default": c.default.as_deref().map(words),
                })
            }).collect::<Vec<_>>(),
        })
    });
    Ok(json!({
        "format": "d3d9",
        "target": program.version.to_string(),
        "constants": constants,
    }))
}

/// A DXIL signature part's elements; `output` says the stored read-write mask is of the components never written.
fn dxil_elements(part: &[u8], output: bool) -> Result<Value, String> {
    let elements = dxil_reader::reflection::signature(part).map_err(|e| e.to_string())?;
    Ok(elements
        .iter()
        .map(|e| {
            let used = if output {
                e.mask & !e.read_write_mask
            } else {
                e.read_write_mask
            };
            json!({
                "name": e.name,
                "index": e.index,
                "system_value": e.system_value,
                "system_value_name": e.system_value_name(),
                "component_type": e.component_type,
                "format": e.format_name(),
                "register": (e.register != u32::MAX).then_some(e.register),
                "mask": mask(e.mask),
                "used": mask(used),
                "stream": e.stream,
            })
        })
        .collect())
}

/// A Shader Model 6 program's container: its signature parts, and from its reflection module (the `STAT` part's, or
/// else the program's own) its entry point, resources and constant-buffer layouts.
fn dxil(bytes: &[u8]) -> Result<Value, String> {
    use dxil_reader::reflection;
    let fail = |e: dxil_reader::Error| e.to_string();
    let directory = dxil_reader::parts(bytes).map_err(fail)?;
    let part = dxil_reader::part(bytes).map_err(fail)?;
    let hull = part.program_version >> 16 == 3;
    let module = dxil_reader::module(&directory, b"DXIL")
        .map_err(fail)?
        .ok_or("no DXIL part")?;
    let stat = dxil_reader::module(&directory, b"STAT").map_err(fail)?;
    let m = stat.as_ref().unwrap_or(&module);
    let mut signatures = serde_json::Map::new();
    for (name, tag, output) in [
        ("input", b"ISG1", false),
        ("output", b"OSG1", true),
        // a hull program writes its patch constants, a domain program reads them
        ("patch_constant", b"PSG1", hull),
    ] {
        if let Some(c) = directory.iter().find(|c| &c.kind == tag) {
            signatures.insert(name.to_owned(), dxil_elements(c.data, output)?);
        }
    }
    let library = reflection::shader_model(&module)
        .map_err(fail)?
        .is_some_and(|(kind, _, _)| kind == "lib");
    let (entry, num_threads) = if library {
        (None, None)
    } else {
        let entry = reflection::entry(&module).map_err(fail)?;
        (
            module.name(entry).map(str::to_owned),
            reflection::num_threads(&module).map_err(fail)?,
        )
    };
    let extras = reflection::resource_extras(m).map_err(fail)?;
    let mut buffers = Vec::new();
    let mut resources = Vec::new();
    for (range, name, ty) in reflection::ranges(m).map_err(fail)? {
        let view = matches!(range.class, 0 | 1);
        let extra = extras.iter().find(|e| e.class == range.class && e.id == range.id);
        let class_name = match range.class {
            0 => "texture",
            1 => "UAV",
            2 => "cbuffer",
            _ => "sampler",
        };
        resources.push(json!({
            "name": name,
            "class": range.class,
            "class_name": class_name,
            "id": range.id,
            "space": range.space,
            "register": range.lower,
            "count": (range.count != u32::MAX).then_some(range.count),
            "kind": view.then_some(range.extra),
            "dimension": view.then(|| reflection::dimension_name(range.extra)),
            "element_type": range.element,
            "format": range.element.map(reflection::component_name),
            "stride": range.stride,
            "counter": range.counter,
            "sample_count": extra.and_then(|e| e.sample_count),
            "size": (range.class == 2).then_some(range.extra),
        }));
        // a constant buffer's layout, from the annotation of the struct its variable points to (through an array)
        if range.class == 2 {
            let mut t = ty;
            while let Some(dxil_reader::module::Type::Array(_, e)) = t.and_then(|t| m.types.get(t)) {
                t = Some(*e);
            }
            let annotation = match t {
                Some(t) => reflection::struct_annotation(m, t).map_err(fail)?,
                None => None,
            };
            buffers.push(json!({
                "name": name,
                "size": range.extra,
                "fields": annotation.map(|a| a.fields.iter().map(|f| json!({
                    "name": f.name,
                    "offset": f.offset,
                    "component_type": f.component,
                    "matrix": f.matrix.map(|(rows, columns, orientation)| json!({
                        "rows": rows,
                        "columns": columns,
                        "orientation": orientation,
                    })),
                })).collect::<Vec<_>>()),
            }));
        }
    }
    let features = dxcontainer::feature_flags(bytes)
        .map_err(|e| e.to_string())?
        .map(|f| {
            json!({
                "bits": format!("0x{:016x}", f.bits),
                "names": f.names(),
                "unnamed": format!("0x{:x}", f.unnamed()),
            })
        });
    Ok(json!({
        "format": "dxil",
        "target": part.target(),
        "dxil_version": format!("{}.{}", part.dxil_version >> 8, part.dxil_version & 0xff),
        "entry": entry,
        "num_threads": num_threads,
        "shader_flags": reflection::module_shader_flags(&module).map_err(fail)?.map(|f| format!("0x{f:016x}")),
        "signatures": signatures,
        "resources": resources,
        "buffers": buffers,
        "features": features,
    }))
}

/// The reflection of a program file.
pub fn reflect(bytes: &[u8]) -> Result<Value, String> {
    match kind(bytes)? {
        Kind::Dxbc => dxbc(bytes),
        Kind::Dxil => dxil(bytes),
        Kind::D3d9 => d3d9(bytes),
    }
}

/// A program file's container: its parts and their sizes and the digest, or a Direct3D 9 program's records.
pub fn info(bytes: &[u8]) -> Result<Value, String> {
    match kind(bytes)? {
        Kind::Dxbc | Kind::Dxil => {
            let directory = dxcontainer::chunks(bytes).map_err(|e| e.to_string())?;
            let base = bytes.as_ptr().addr();
            let stored = bytes.get(4..20).map(hex);
            let computed = dxcontainer::checksum(bytes).map(|d| hex(&d));
            // a DXIL container's target is in its DXIL part's header; a Shader Model 4 or 5 one's in its code part
            let dxil = directory
                .iter()
                .any(|c| &c.kind == b"DXIL")
                .then(|| dxil_reader::part(bytes).map_err(|e| e.to_string()))
                .transpose()?;
            let target = match &dxil {
                Some(part) => part.target(),
                None => dxbc_target(bytes).map(|(_, t)| t).ok(),
            };
            let features = dxcontainer::feature_flags(bytes)
                .map_err(|e| e.to_string())?
                .map(|f| f.names());
            Ok(json!({
                "format": if dxil.is_some() { "dxil" } else { "dxbc" },
                "size": bytes.len(),
                "target": target,
                "program_version": dxil.map(|p| format!("0x{:08x}", p.program_version)),
                "features": features,
                "digest": stored,
                "digest_matches": stored.is_some() && stored == computed,
                "parts": directory.iter().map(|c| json!({
                    "tag": String::from_utf8_lossy(&c.kind),
                    "offset": c.data.as_ptr().addr().wrapping_sub(base),
                    "size": c.data.len(),
                })).collect::<Vec<_>>(),
            }))
        }
        Kind::D3d9 => {
            let (program, framed) = d3d9_reader::frame(bytes).map_err(|e| e.to_string())?;
            let count = |f: fn(&d3d9_reader::Item) -> bool| program.items.iter().filter(|i| f(i)).count();
            Ok(json!({
                "format": "d3d9",
                "size": bytes.len(),
                "program_size": framed.len(),
                "target": program.version.to_string(),
                "creator": program.constants.as_ref().map(|t| &t.creator),
                "instructions": count(|i| matches!(i, d3d9_reader::Item::Instruction(_))),
                "declarations": count(|i| matches!(i, d3d9_reader::Item::Declaration(_))),
                "definitions": count(|i| matches!(i, d3d9_reader::Item::Definition(_))),
                "comments": count(|i| matches!(i, d3d9_reader::Item::Comment(_))),
            }))
        }
    }
}

/// `value` as indented `key: value` lines, for reading in a terminal.
pub fn text(value: &Value) -> String {
    let mut out = String::new();
    write_text(&mut out, value, 0);
    out
}

fn scalar(value: &Value) -> Option<String> {
    match value {
        Value::Null => Some("-".to_owned()),
        Value::String(s) => Some(s.clone()),
        Value::Bool(_) | Value::Number(_) => Some(value.to_string()),
        Value::Array(items) if items.iter().all(|v| !v.is_array() && !v.is_object()) => {
            Some(items.iter().filter_map(scalar).collect::<Vec<_>>().join(" "))
        }
        _ => None,
    }
}

fn write_text(out: &mut String, value: &Value, indent: usize) {
    let pad = " ".repeat(indent);
    match value {
        Value::Object(map) => {
            for (key, v) in map {
                match scalar(v) {
                    Some(s) => out.push_str(&format!("{pad}{key}: {s}\n")),
                    None => {
                        out.push_str(&format!("{pad}{key}:\n"));
                        write_text(out, v, indent + 2);
                    }
                }
            }
        }
        Value::Array(items) => {
            for item in items {
                match scalar(item) {
                    Some(s) => out.push_str(&format!("{pad}- {s}\n")),
                    None => {
                        out.push_str(&format!("{pad}-\n"));
                        write_text(out, item, indent + 2);
                    }
                }
            }
        }
        other => out.push_str(&format!("{pad}{}\n", scalar(other).unwrap_or_default())),
    }
}

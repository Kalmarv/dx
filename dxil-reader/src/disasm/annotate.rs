//! dxc's comment after a call of a DXIL operation: `  ; Name(operands)`, and for `annotateHandle` the resource its
//! properties describe (dxc's `DxcAssemblyAnnotationWriter::printInfoComment`).
use super::ops;

/// The comment dxc writes after a call of a `dx.op.` function whose first argument is the constant `opcode` (its value
/// zero-extended), and whose third argument, for `annotateHandle`, is the constant `properties` (the two dwords of a
/// `%dx.types.ResourceProperties`).
pub(super) fn comment(opcode: u64, properties: Option<[u32; 2]>) -> String {
    let Some((name, operands)) = u32::try_from(opcode)
        .ok()
        .filter(|&o| o != u32::MAX)
        .and_then(ops::operation)
    else {
        return format!("  ; invalid DXIL opcode #{opcode}");
    };
    let mut out = format!("  ; {name}{operands}");
    // AnnotateHandle is operation 216 of the core table
    if opcode == 216
        && let Some(props) = properties
    {
        out.push_str("  resource: ");
        out.push_str(&resource(props));
    }
    out
}

/// dxc's `PrintResourceProperties`.
fn resource([dword0, dword1]: [u32; 2]) -> String {
    let kind = dword0 & 0xFF;
    let uav = dword0 >> 12 & 1 != 0;
    let rov = dword0 >> 13 & 1 != 0;
    let coherent = dword0 >> 14 & 1 != 0;
    let cmp_or_counter = dword0 >> 15 & 1 != 0;
    let reorder = dword0 >> 16 & 1 != 0;
    match kind {
        13 => return "CBuffer".to_owned(),
        // a TBuffer is an SRV (not a UAV)
        15 if !uav => return "TBuffer".to_owned(),
        14 => {
            return if cmp_or_counter {
                "SamplerComparisonState"
            } else {
                "SamplerState"
            }
            .to_owned();
        }
        _ => {}
    }
    let rw = if uav { if rov { "ROV" } else { "RW" } } else { "" };
    let gc = if uav && coherent { "globallycoherent " } else { "" };
    let rc = if uav && reorder { "reordercoherent " } else { "" };
    let counter = if uav && cmp_or_counter { ", counter" } else { "" };
    match kind {
        1..=10 => {
            let count = dword1 >> 8 & 0xFF;
            let n = if count > 1 {
                format!("{count}x")
            } else {
                String::new()
            };
            format!("{gc}{rc}{rw}{}<{n}{}>", kind_name(kind), component(dword1 & 0xFF))
        }
        11 => format!("{gc}{rc}{rw}{}", kind_name(kind)),
        12 => format!("{gc}{rc}{rw}{}<stride={dword1}{counter}>", kind_name(kind)),
        16 => kind_name(kind).to_owned(),
        17 | 18 => {
            let feedback = match dword1 & 0xFF {
                0 => "MinMip",
                1 => "MipRegionUsed",
                _ => "<invalid sampler feedback type>",
            };
            format!("{}<{feedback}>", kind_name(kind))
        }
        _ => "<invalid resource properties>".to_owned(),
    }
}

/// dxc's `ResourceKindToString`.
fn kind_name(kind: u32) -> &'static str {
    match kind {
        1 => "Texture1D",
        2 => "Texture2D",
        3 => "Texture2DMS",
        4 => "Texture3D",
        5 => "TextureCube",
        6 => "Texture1DArray",
        7 => "Texture2DArray",
        8 => "Texture2DMSArray",
        9 => "TextureCubeArray",
        10 => "TypedBuffer",
        11 => "ByteAddressBuffer",
        12 => "StructuredBuffer",
        13 => "CBuffer",
        14 => "Sampler",
        15 => "TBuffer",
        16 => "RTAccelerationStructure",
        17 => "FeedbackTexture2D",
        18 => "FeedbackTexture2DArray",
        _ => "<invalid ResourceKind>",
    }
}

/// dxc's `CompTypeToString`.
fn component(ty: u32) -> &'static str {
    match ty {
        1 => "I1",
        2 => "I16",
        3 => "U16",
        4 => "I32",
        5 => "U32",
        6 => "I64",
        7 => "U64",
        8 => "F16",
        9 => "F32",
        10 => "F64",
        11 => "SNormF16",
        12 => "UNormF16",
        13 => "SNormF32",
        14 => "UNormF32",
        15 => "SNormF64",
        16 => "UNormF64",
        _ => "<invalid CompType>",
    }
}

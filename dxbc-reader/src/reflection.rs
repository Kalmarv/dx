//! The reflection (`RDEF`) and signature (`ISGN`, `OSGN`, `ISG1`, `OSG1`, `OSG5`, `PCSG`, `PSG1`) parts of a Shader
//! Model 4 or 5 container, as the records they store: resource bindings, constant buffers with their variables and type
//! trees, and signature elements, each with D3D's own numbers (`D3D_SHADER_INPUT_TYPE`, `D3D_NAME`, ...) and the word
//! it starts at. What the numbers mean for a graphics API is the caller's to decide.
//!
//! Every table is bounded before it is read, every string is checked to end inside its part and be UTF-8, and a type
//! tree is refused where it nests deeper than 32 or refers to itself.
use crate::decode::ProgramType;
use crate::{Result, chunk, error, parts};

/// The most records one table may state.
const MAX_RECORDS: usize = 65536;
/// The longest name, in bytes.
const MAX_NAME: usize = 4096;
/// The largest constant buffer, in bytes.
const MAX_BUFFER_SIZE: usize = 65536;

struct View<'a>(&'a [u8]);
impl View<'_> {
    fn bytes(&self, at: usize, len: usize) -> Result<&[u8]> {
        let end = at.checked_add(len).ok_or_else(|| {
            error(
                at / 4,
                format!("{len} bytes at byte {at} overflow the address space"),
            )
        })?;
        self.0.get(at..end).ok_or_else(|| {
            error(
                at / 4,
                format!(
                    "{len} bytes at byte {at} exceed the part's {} bytes",
                    self.0.len()
                ),
            )
        })
    }
    fn array<const N: usize>(&self, at: usize) -> Result<[u8; N]> {
        self.bytes(at, N)?
            .try_into()
            .map_err(|_| error(at / 4, format!("{N} bytes at byte {at}")))
    }
    fn u32(&self, at: usize) -> Result<u32> {
        Ok(u32::from_le_bytes(self.array(at)?))
    }
    fn u16(&self, at: usize) -> Result<u16> {
        Ok(u16::from_le_bytes(self.array(at)?))
    }
    /// The byte `delta` bytes after `at`.
    fn plus(&self, at: usize, delta: usize) -> Result<usize> {
        at.checked_add(delta).ok_or_else(|| {
            error(
                at / 4,
                format!("byte {at} plus {delta} overflows the address space"),
            )
        })
    }
    /// The 32-bit field `delta` bytes after `at`.
    fn field(&self, at: usize, delta: usize) -> Result<u32> {
        self.u32(self.plus(at, delta)?)
    }
    /// The 16-bit field `delta` bytes after `at`.
    fn field16(&self, at: usize, delta: usize) -> Result<u16> {
        self.u16(self.plus(at, delta)?)
    }
    /// The start of record `i` of a table at `at` with records of `stride` bytes.
    fn record(&self, at: usize, i: usize, stride: usize) -> Result<usize> {
        i.checked_mul(stride)
            .and_then(|n| at.checked_add(n))
            .ok_or_else(|| {
                error(
                    at / 4,
                    format!("record {i} of {stride} bytes at byte {at} overflows"),
                )
            })
    }
    /// The string at byte `at`, which ends inside the part.
    fn string(&self, at: usize) -> Result<String> {
        let tail = self.0.get(at..).ok_or_else(|| {
            error(
                at / 4,
                format!("a string at byte {at}, past the part's {} bytes", self.0.len()),
            )
        })?;
        let end = tail.iter().position(|&b| b == 0).ok_or_else(|| {
            error(
                at / 4,
                format!("the string at byte {at} has no terminating zero in the part"),
            )
        })?;
        if end > MAX_NAME {
            return Err(error(
                at / 4,
                format!("the string at byte {at} is {end} bytes, more than the {MAX_NAME} allowed"),
            ));
        }
        let text = tail
            .get(..end)
            .ok_or_else(|| error(at / 4, format!("the string at byte {at}")))?;
        std::str::from_utf8(text)
            .map(str::to_owned)
            .map_err(|_| error(at / 4, format!("the string at byte {at} is not UTF-8")))
    }
    /// The indices of the `count` records of `stride` bytes at `at`, once the table is known to lie in the part.
    fn table(&self, at: usize, count: usize, stride: usize) -> Result<std::ops::Range<usize>> {
        if count > MAX_RECORDS {
            return Err(error(
                at / 4,
                format!("a table of {count} records at byte {at}, more than the {MAX_RECORDS} allowed"),
            ));
        }
        self.bytes(
            at,
            count.checked_mul(stride).ok_or_else(|| {
                error(
                    at / 4,
                    format!("a table of {count} records of {stride} bytes overflows"),
                )
            })?,
        )?;
        Ok(0..count)
    }
    /// The type record at byte `at` (of `layout`'s size) and its members' types, depth first.
    fn ty(&self, at: usize, layout: Layout, stack: &mut Vec<usize>, budget: &mut usize) -> Result<RdefType> {
        if stack.len() >= 32 || stack.contains(&at) || *budget == 0 {
            return Err(error(
                at / 4,
                "the type at this word is part of a cycle, nests deeper than 32 or is one of more than 65536 types",
            ));
        }
        *budget = budget.saturating_sub(1);
        self.bytes(at, layout.ty)?;
        stack.push(at);
        let count = usize::from(self.field16(at, 10)?);
        let offset = self.field(at, 12)? as usize;
        let mut members = Vec::new();
        for i in self.table(offset, count, 12)? {
            let p = self.record(offset, i, 12)?;
            members.push(RdefMember {
                name: self.string(self.u32(p)? as usize)?,
                offset: self.field(p, 8)?,
                ty: self.ty(self.field(p, 4)? as usize, layout, stack, budget)?,
            });
        }
        stack.pop();
        // Shader Model 5 type records name the type in their last field
        let name = if layout.ty >= 36 {
            match self.field(at, 32)? as usize {
                0 => None,
                offset => Some(self.string(offset)?),
            }
        } else {
            None
        };
        Ok(RdefType {
            word: at / 4,
            name,
            class: self.u16(at)?,
            scalar: self.field16(at, 2)?,
            rows: self.field16(at, 4)?,
            columns: self.field16(at, 6)?,
            elements: self.field16(at, 8)?,
            members,
        })
    }
}

/// The record sizes of an `RDEF` part's layout that differ. The constant buffer (24 bytes) and struct member (12) records
/// are the same in all three; Shader Model 5's variable and type records end in fields Shader Model 4's do not have, and
/// Shader Model 5.1's binding records end in the register space and the resource's id.
#[derive(Clone, Copy)]
struct Layout {
    /// The size of a resource binding record.
    binding: usize,
    /// The size of a variable record.
    variable: usize,
    /// The size of a type record.
    ty: usize,
}

/// Shader Model 4: the 28-byte header, then the tables.
const SM4: Layout = Layout {
    binding: 32,
    variable: 24,
    ty: 16,
};
/// Shader Model 5.0: the header, the `RD11` tag and the six record sizes it states.
const SM50: Layout = Layout {
    binding: 32,
    variable: 40,
    ty: 36,
};
/// Shader Model 5.1: the header, the tag `13 13 44 25` and the six record sizes it states.
const SM51: Layout = Layout {
    binding: 40,
    variable: 40,
    ty: 36,
};

/// The tag of the Shader Model 5.1 layout, the word `0x25441313`.
const SM51_TAG: &[u8; 4] = &[0x13, 0x13, 0x44, 0x25];

/// One element of a signature as stored.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct SignatureElement {
    /// The semantic name (`POSITION`, `TEXCOORD`, ...).
    pub name: String,
    /// The semantic index (the `1` of `TEXCOORD1`).
    pub index: u32,
    /// `D3D_NAME`.
    pub system_value: u32,
    /// `D3D_REGISTER_COMPONENT_TYPE`.
    pub component_type: u32,
    /// The register the element is packed into.
    pub register: u32,
    /// The components the element occupies, one bit each (x is bit 0).
    pub mask: u8,
    /// The components a program reads (inputs) or never writes (outputs), as stored.
    pub read_write_mask: u8,
    /// Where the record starts, in words of the chunk.
    pub at: usize,
    /// The output stream of a geometry program's element (`OSG5`, `OSG1`); 0 in the other layouts.
    pub stream: u32,
    /// `D3D_MIN_PRECISION` (`ISG1`, `OSG1`, `PSG1`); 0 (default) in the other layouts.
    pub min_precision: u32,
}

impl SignatureElement {
    /// The element's `D3D_NAME`: as stored, but for a pixel program's outputs, which store none; theirs is the one
    /// their semantic names (`SV_Target` is 64, `SV_Depth` 65, ...). `output` says which signature the element is in.
    pub fn system_value_for(&self, output: bool, kind: ProgramType) -> u32 {
        if self.system_value != 0 || !output || kind != ProgramType::Pixel {
            return self.system_value;
        }
        match self.name.to_ascii_lowercase().as_str() {
            "sv_target" => 64,
            "sv_depth" => 65,
            "sv_coverage" => 66,
            "sv_depthgreaterequal" => 67,
            "sv_depthlessequal" => 68,
            "sv_stencilref" => 69,
            "sv_innercoverage" => 70,
            _ => 0,
        }
    }

    /// [`Self::system_value_for`] as Microsoft's disassembler names it in the SysValue column (`POS`, `TARGET`; `SV`
    /// and the number for one it has no name for).
    pub fn system_value_name(&self, output: bool, kind: ProgramType) -> String {
        match self.system_value_for(output, kind) {
            0 => "NONE",
            1 => "POS",
            2 => "CLIPDST",
            3 => "CULLDST",
            4 => "RTINDEX",
            5 => "VPINDEX",
            6 => "VERTID",
            7 => "PRIMID",
            8 => "INSTID",
            9 => "FFACE",
            10 => "SAMPLE",
            11 => "QUADEDGE",
            12 => "QUADINT",
            13 => "TRIEDGE",
            14 => "TRIINT",
            15 => "LINEDET",
            16 => "LINEDEN",
            64 => "TARGET",
            65 => "DEPTH",
            66 => "COVERAGE",
            67 => "DEPTHGE",
            68 => "DEPTHLE",
            69 => "STENCILREF",
            70 => "INNERCOV",
            other => return format!("SV{other}"),
        }
        .to_owned()
    }

    /// The component type as Microsoft's disassembler names it in the Format column, or the minimum precision where
    /// the element has one (`float`, `min16f`).
    pub fn format_name(&self) -> &'static str {
        match (self.min_precision, self.component_type) {
            (1, _) => "min16f",
            (2, _) => "min2_8f",
            (4, _) => "min16i",
            (5, _) => "min16u",
            (_, 1) => "uint",
            (_, 2) => "int",
            (_, 3) => "float",
            _ => "unknown",
        }
    }
}

/// A signature part's records. Layouts: `ISGN`/`OSGN`/`PCSG` (name, index, system value, component type, register,
/// masks), `ISG1`/`OSG1`/`PSG1` (a stream and a minimum precision besides) and `OSG5` (a stream besides). `kind` is the
/// part's tag, which says which layout `bytes` has.
pub fn signature(bytes: &[u8], kind: &[u8; 4]) -> Result<Vec<SignatureElement>> {
    let v = View(bytes);
    let count = v.u32(0)? as usize;
    let directory = v.u32(4)?;
    if directory != 8 {
        return Err(error(
            1,
            format!("expected the record directory at byte 8, found byte {directory}"),
        ));
    }
    // bytes before the name offset, and the record size
    let (skip, record) = match kind {
        b"ISG1" | b"OSG1" | b"PSG1" => (4, 32),
        b"OSG5" => (4, 28),
        _ => (0, 24),
    };
    let mut result = Vec::new();
    for i in v.table(8, count, record)? {
        let p = v.record(8, i, record)?;
        let q = v.plus(p, skip)?;
        let [mask, read_write_mask, _, _] = v.array::<4>(v.plus(q, 20)?)?;
        result.push(SignatureElement {
            name: v.string(v.u32(q)? as usize)?,
            index: v.field(q, 4)?,
            system_value: v.field(q, 8)?,
            component_type: v.field(q, 12)?,
            register: v.field(q, 16)?,
            mask,
            read_write_mask,
            at: p / 4,
            stream: if skip == 4 { v.u32(p)? } else { 0 },
            min_precision: if record == 32 { v.field(q, 24)? } else { 0 },
        });
    }
    Ok(result)
}

/// A hull or domain program's patch-constant signature elements as stored (the `PCSG` part, or the `PSG1` part where
/// the program uses minimum precision).
pub fn patch_signature_elements(bytes: &[u8]) -> Result<Vec<SignatureElement>> {
    let directory = parts(bytes)?;
    let (data, tag) = signature_part(&directory, &[b"PCSG", b"PSG1"])?;
    signature(data, &tag)
}

/// The part among `tags` the container has (the first tag where it has none, so that is the one reported missing).
fn signature_part<'a>(
    directory: &[dxcontainer::Chunk<'a>],
    tags: &[&[u8; 4]],
) -> Result<(&'a [u8], [u8; 4])> {
    let tag = tags
        .iter()
        .find(|t| directory.iter().any(|c| &&c.kind == *t))
        .or(tags.first())
        .ok_or_else(|| error(0, "no signature part kinds to look for"))?;
    Ok((chunk(directory, tag)?, **tag))
}

/// A container's program type and its input and output signature elements as stored.
pub fn signature_elements(
    bytes: &[u8],
) -> Result<(ProgramType, Vec<SignatureElement>, Vec<SignatureElement>)> {
    let directory = parts(bytes)?;
    let kind = program_type(&directory)?;
    let read = |tags: &[&[u8; 4]]| -> Result<Vec<SignatureElement>> {
        let (data, tag) = signature_part(&directory, tags)?;
        signature(data, &tag)
    };
    Ok((
        kind,
        read(&[b"ISGN", b"ISG1"])?,
        read(&[b"OSGN", b"OSG1", b"OSG5"])?,
    ))
}

/// The type of a container's program: its code part's version token names it in the high 16 bits.
pub fn program_type(directory: &[dxcontainer::Chunk<'_>]) -> Result<ProgramType> {
    let code = directory
        .iter()
        .find(|c| matches!(&c.kind, b"SHDR" | b"SHEX"))
        .ok_or_else(|| error(0, "the container has no SHDR or SHEX part"))?;
    let token = View(code.data).u32(0)?;
    match token >> 16 {
        0 => Ok(ProgramType::Pixel),
        1 => Ok(ProgramType::Vertex),
        2 => Ok(ProgramType::Geometry),
        3 => Ok(ProgramType::Hull),
        4 => Ok(ProgramType::Domain),
        5 => Ok(ProgramType::Compute),
        kind => Err(error(
            0,
            format!("expected a program type from 0 (pixel) to 5 (compute), found {kind}"),
        )),
    }
}

/// A container's `RDEF` part as stored: what it says the program binds and the layouts of its buffers.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct Rdef {
    /// The part's own version token (`0xffff0500`: an SM5.0 pixel program, `0xfffe0500`: vertex, ...).
    pub target: u32,
    /// `D3DCOMPILE_*` flags the program was compiled with, as stored.
    pub flags: u32,
    /// The compiler that wrote the part (`Microsoft (R) HLSL Shader Compiler 10.1`).
    pub creator: String,
    /// The resource bindings, in the order the part lists them.
    pub bindings: Vec<RdefBinding>,
    /// The constant buffers, in the order the part lists them.
    pub buffers: Vec<RdefBuffer>,
}

/// One resource binding record as stored.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct RdefBinding {
    /// Where the record starts, in words of the part.
    pub word: usize,
    /// The resource's name.
    pub name: String,
    /// `D3D_SHADER_INPUT_TYPE`.
    pub kind: u32,
    /// `D3D_RESOURCE_RETURN_TYPE`.
    pub returns: u32,
    /// `D3D_SRV_DIMENSION`.
    pub dimension: u32,
    /// A multisampled texture's sample count; a structured buffer's stride.
    pub samples: u32,
    /// The first register the resource is bound to.
    pub register: u32,
    /// How many consecutive registers it is bound to.
    pub count: u32,
    /// `D3D_SHADER_INPUT_FLAGS`.
    pub flags: u32,
    /// The register space; 0 in the layouts before Shader Model 5.1, which have no spaces.
    pub space: u32,
    /// The resource's id, where the layout stores one (Shader Model 5.1): the number the program's declarations and
    /// instructions name the resource by in place of its register.
    pub id: Option<u32>,
}

impl RdefBinding {
    /// `D3D_SHADER_INPUT_TYPE` as Microsoft's disassembler names it in the Type column (`cbuffer`, `texture`,
    /// `sampler_c` for a comparison sampler, `UAV`).
    pub fn type_name(&self) -> &'static str {
        match self.kind {
            0 => "cbuffer",
            1 => "tbuffer",
            // D3D_SIF_COMPARISON_SAMPLER
            3 if self.flags & 2 != 0 => "sampler_c",
            3 => "sampler",
            4 | 6 | 8..=11 | 13 => "UAV",
            _ => "texture",
        }
    }

    /// What the binding returns, as Microsoft's disassembler names it in the Format column (`float4`, `struct`,
    /// `byte`; `NA` for a buffer or sampler, which return none).
    pub fn format_name(&self) -> String {
        match self.kind {
            0 | 1 | 3 => "NA".to_owned(),
            5 | 6 | 9..=11 => "struct".to_owned(),
            7 | 8 => "byte".to_owned(),
            _ => {
                let name = match self.returns {
                    1 => "unorm",
                    2 => "snorm",
                    3 => "sint",
                    4 => "uint",
                    5 => "float",
                    6 => "mixed",
                    7 => "double",
                    8 => "continued",
                    _ => "NA",
                };
                // D3D_SIF_TEXTURE_COMPONENTS: the number of components less one
                let components = ((self.flags >> 2) & 3).saturating_add(1);
                if components > 1 {
                    format!("{name}{components}")
                } else {
                    name.to_owned()
                }
            }
        }
    }

    /// The resource's shape, as Microsoft's disassembler names it in the Dim column (`2d`, `2dMS4`, `r/w`, `NA`).
    pub fn dimension_name(&self) -> String {
        match self.kind {
            0 | 1 | 3 => return "NA".to_owned(),
            5 | 7 => return "r/o".to_owned(),
            6 | 8 => return "r/w".to_owned(),
            9 => return "append".to_owned(),
            10 => return "consume".to_owned(),
            11 => return "r/w+cnt".to_owned(),
            _ => {}
        }
        let name = match self.dimension {
            1 | 11 => "buf",
            2 => "1d",
            3 => "1darray",
            4 => "2d",
            5 => "2darray",
            6 => "2dMS",
            7 => "2darrayMS",
            8 => "3d",
            9 => "cube",
            10 => "cubearray",
            _ => "NA",
        };
        if matches!(self.dimension, 6 | 7) && self.samples != 0 && self.samples != u32::MAX {
            format!("{name}{}", self.samples)
        } else {
            name.to_owned()
        }
    }

    /// The register file the binding is in: `cb`, `s`, `u` or `t`.
    pub fn register_prefix(&self) -> &'static str {
        match self.type_name() {
            "cbuffer" => "cb",
            "sampler" | "sampler_c" => "s",
            "UAV" => "u",
            _ => "t",
        }
    }
}

/// One buffer (`D3D11_SHADER_BUFFER_DESC`) as stored, with its variables.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct RdefBuffer {
    /// Where the record starts, in words of the part.
    pub word: usize,
    /// The buffer's name.
    pub name: String,
    /// `D3D_CBUFFER_TYPE`: 0 a cbuffer, 1 a tbuffer, 2 interface pointers, 3 a structured buffer's element.
    pub kind: u32,
    /// The buffer's size in bytes, as the part stores it.
    pub size: u32,
    /// The variables the buffer holds.
    pub variables: Vec<RdefVariable>,
}

/// One variable of a buffer as stored: its byte range in the buffer, its type and its default value.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct RdefVariable {
    /// Where the record starts, in words of the part.
    pub word: usize,
    /// The variable's name.
    pub name: String,
    /// Its first byte in the buffer.
    pub offset: u32,
    /// Its size in bytes.
    pub size: u32,
    /// `D3D_SHADER_VARIABLE_FLAGS`: bit 2 (`D3D_SVF_USED`) is set where the program reads the variable.
    pub flags: u32,
    /// Its type.
    pub ty: RdefType,
    /// The stored default value's `size` bytes, where the variable has one.
    pub default: Option<Vec<u8>>,
}

/// A variable's type record (`D3D11_SHADER_TYPE_DESC`) as stored, and its members' types.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct RdefType {
    /// Where the record starts, in words of the part.
    pub word: usize,
    /// `D3D_SHADER_VARIABLE_CLASS`: 0 scalar, 1 vector, 2 row-major matrix, 3 column-major matrix, 4 object, 5 struct.
    pub class: u16,
    /// `D3D_SHADER_VARIABLE_TYPE`.
    pub scalar: u16,
    /// The matrix's rows (1 for a scalar or vector).
    pub rows: u16,
    /// The vector's or matrix's columns.
    pub columns: u16,
    /// The array length; 0 where it isn't an array.
    pub elements: u16,
    /// The struct's members, in order.
    pub members: Vec<RdefMember>,
    /// The type's name (`float4`, `float3x4`, a struct's own name), where the layout stores one (Shader Model 5).
    pub name: Option<String>,
}

impl RdefType {
    /// `D3D_SHADER_VARIABLE_TYPE` as HLSL names it (`float`, `uint`, `Texture2D`; `type` and the number for one it
    /// has no name for).
    pub fn scalar_name(&self) -> String {
        match self.scalar {
            0 => "void",
            1 => "bool",
            2 => "int",
            3 => "float",
            4 => "string",
            5 => "texture",
            6 => "Texture1D",
            7 => "Texture2D",
            8 => "Texture3D",
            9 => "TextureCube",
            10 => "SamplerState",
            19 => "uint",
            20 => "uint8",
            25 => "Buffer",
            26 => "cbuffer",
            27 => "tbuffer",
            28 => "Texture1DArray",
            29 => "Texture2DArray",
            32 => "Texture2DMS",
            33 => "Texture2DMSArray",
            34 => "TextureCubeArray",
            39 => "double",
            40 => "RWTexture1D",
            41 => "RWTexture1DArray",
            42 => "RWTexture2D",
            43 => "RWTexture2DArray",
            44 => "RWTexture3D",
            45 => "RWBuffer",
            46 => "ByteAddressBuffer",
            47 => "RWByteAddressBuffer",
            48 => "StructuredBuffer",
            49 => "RWStructuredBuffer",
            50 => "AppendStructuredBuffer",
            51 => "ConsumeStructuredBuffer",
            52 => "min8float",
            53 => "min10float",
            54 => "min16float",
            55 => "min12int",
            56 => "min16int",
            57 => "min16uint",
            other => return format!("type{other}"),
        }
        .to_owned()
    }

    /// The type's name as Microsoft's disassembler writes it before a variable's name: `float4`, `row_major float3x4`,
    /// `interface ILight`. Built from the class and scalar type, as the disassembler does (the stored name of a `uint`
    /// is `dword`); an interface's from its stored name. A struct is `struct` (the disassembler opens a block of its
    /// members instead).
    pub fn type_name(&self) -> String {
        let scalar = self.scalar_name();
        match self.class {
            1 => format!("{scalar}{}", self.columns),
            2 => format!("row_major {scalar}{}x{}", self.rows, self.columns),
            3 => format!("{scalar}{}x{}", self.rows, self.columns),
            5 => "struct".to_owned(),
            // an interface class (6) or pointer (7)
            6 | 7 => format!("interface {}", self.name.as_deref().unwrap_or("")),
            _ => scalar,
        }
    }
}

/// A struct member: its name, its byte offset in the struct and its type.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct RdefMember {
    /// The member's name.
    pub name: String,
    /// Its first byte in the struct.
    pub offset: u32,
    /// Its type.
    pub ty: RdefType,
}

/// The version token of a container's first `RDEF` part (`None` where it has none), read without the rest of the part:
/// a caller can tell which program model's layout it holds before it asks [`rdef`] for the records.
pub fn rdef_target(bytes: &[u8]) -> Result<Option<u32>> {
    let directory = parts(bytes)?;
    directory
        .iter()
        .find(|c| &c.kind == b"RDEF")
        .map(|rdef| View(rdef.data).u32(16))
        .transpose()
}

/// The tag and record-size directory a Shader Model 5 `RDEF` part has after its 28-byte header, and the layout they
/// state: `RD11` for 5.0, `13 13 44 25` for 5.1.
fn read_directory(v: &View<'_>) -> Result<Layout> {
    let tag = v.bytes(28, 4)?;
    let (layout, name) = if tag == b"RD11" {
        (SM50, "RD11")
    } else if tag == SM51_TAG {
        (SM51, "5.1")
    } else {
        return Err(error(
            7,
            format!(
                "expected the `RD11` tag of the Shader Model 5.0 RDEF layout or the bytes 13 13 44 25 of the 5.1 one,                  found {:02x?} ({:?})",
                tag,
                String::from_utf8_lossy(tag)
            ),
        ));
    };
    for (i, size) in [60, 24, layout.binding, layout.variable, layout.ty, 12]
        .into_iter()
        .enumerate()
    {
        let at = v.record(32, i, 4)?;
        let found = v.u32(at)? as usize;
        if found != size {
            return Err(error(
                at / 4,
                format!(
                    "expected record size {size} (entry {i} of the {name} size directory), found {found}"
                ),
            ));
        }
    }
    Ok(layout)
}

/// A container's `RDEF` part (`None` where it has none): the Shader Model 4 layout where its target is a 4.x one (a
/// 28-byte header, then the tables), the Shader Model 5.0 or 5.1 layout (the record-size directory its tag names) where
/// it is a 5.x one.
pub fn rdef(bytes: &[u8]) -> Result<Option<Rdef>> {
    let directory = parts(bytes)?;
    if !directory.iter().any(|c| &c.kind == b"RDEF") {
        return Ok(None);
    }
    let v = View(chunk(&directory, b"RDEF")?);
    let target = v.u32(16)?;
    let layout = match (target >> 8) & 0xff {
        4 => SM4,
        _ => read_directory(&v)?,
    };
    let mut bindings = Vec::new();
    let offset = v.field(0, 12)? as usize;
    for i in v.table(offset, v.field(0, 8)? as usize, layout.binding)? {
        let p = v.record(offset, i, layout.binding)?;
        let spaced = layout.binding == SM51.binding;
        bindings.push(RdefBinding {
            word: p / 4,
            name: v.string(v.u32(p)? as usize)?,
            kind: v.field(p, 4)?,
            returns: v.field(p, 8)?,
            dimension: v.field(p, 12)?,
            samples: v.field(p, 16)?,
            register: v.field(p, 20)?,
            count: v.field(p, 24)?,
            flags: v.field(p, 28)?,
            space: if spaced { v.field(p, 32)? } else { 0 },
            id: if spaced { Some(v.field(p, 36)?) } else { None },
        });
    }
    let mut buffers = Vec::new();
    let offset = v.field(0, 4)? as usize;
    let mut budget = MAX_RECORDS;
    for i in v.table(offset, v.u32(0)? as usize, 24)? {
        let p = v.record(offset, i, 24)?;
        let name = v.string(v.u32(p)? as usize)?;
        let kind = v.field(p, 20)?;
        let size = v.field(p, 12)?;
        if size as usize > MAX_BUFFER_SIZE {
            return Err(error(
                v.plus(p, 12)? / 4,
                format!("constant buffer of {size} bytes, more than the {MAX_BUFFER_SIZE} allowed"),
            ));
        }
        let mut variables = Vec::new();
        let entries = v.field(p, 8)? as usize;
        for j in v.table(entries, v.field(p, 4)? as usize, layout.variable)? {
            let q = v.record(entries, j, layout.variable)?;
            let start = v.field(q, 4)?;
            let len = v.field(q, 8)?;
            if start.checked_add(len).is_none_or(|end| end > size) {
                return Err(error(
                    v.plus(q, 4)? / 4,
                    format!(
                        "variable at byte {start} of {len} bytes lies outside its {size} byte constant buffer"
                    ),
                ));
            }
            let default = v.field(q, 20)? as usize;
            let ty = v.ty(v.field(q, 16)? as usize, layout, &mut Vec::new(), &mut budget)?;
            variables.push(RdefVariable {
                word: q / 4,
                name: v.string(v.u32(q)? as usize)?,
                offset: start,
                size: len,
                flags: v.field(q, 12)?,
                ty,
                default: if default == 0 {
                    None
                } else {
                    Some(v.bytes(default, len as usize)?.to_vec())
                },
            });
        }
        buffers.push(RdefBuffer {
            word: p / 4,
            name,
            kind,
            size,
            variables,
        });
    }
    Ok(Some(Rdef {
        target,
        flags: v.u32(20)?,
        creator: v.string(v.u32(24)? as usize)?,
        bindings,
        buffers,
    }))
}

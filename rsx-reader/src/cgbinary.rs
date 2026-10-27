//! Big-endian revision-6 CgBinaryProgram containers, with offsets relative to
//! their own header. See the crate README for the layout sources and scope.
use primase_foundations::bytes::{Endian::Big, View};
use std::ops::Range;

/// What is wrong with a container, and where.
#[derive(Clone, Debug, PartialEq, Eq, thiserror::Error)]
#[error("CgBinaryProgram at byte {offset}: {detail}")]
pub struct Error {
    /// The byte offset in the container where the problem is.
    pub offset: usize,
    /// What was expected there, or what was found instead.
    pub detail: String,
}

fn error(offset: usize, detail: impl Into<String>) -> Error {
    Error {
        offset,
        detail: detail.into(),
    }
}

/// The offset `delta` bytes after `at`, which the caller has checked to lie in the container.
fn plus(at: usize, delta: usize) -> Result<usize, Error> {
    at.checked_add(delta)
        .ok_or_else(|| error(at, "offset overflows the address space"))
}

/// The stage-specific header of a vertex program.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct Vertex {
    /// The number of 16-byte microcode slots.
    pub instruction_count: u32,
    /// The slot the program starts at.
    pub instruction_slot: u32,
    /// The number of registers it uses.
    pub register_count: u32,
    /// The vertex attributes it reads, a mask.
    pub attribute_input_mask: u32,
    /// The attributes it writes, a mask.
    pub attribute_output_mask: u32,
    /// The user clip planes it writes, a mask.
    pub user_clip_mask: u32,
}

/// The stage-specific header of a fragment program.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct Fragment {
    /// Number of 16-byte microcode slots, including embedded constants.
    pub instruction_count: u32,
    /// The interpolated attributes it reads, a mask.
    pub attribute_input_mask: u32,
    /// Two bits per texture unit, kept as encoded.
    pub partial_tex_type: u32,
    /// The texture coordinate sets it reads, a mask.
    pub tex_coords_input_mask: u16,
    /// The sets that are two-component, a mask.
    pub tex_coords_2d: u16,
    /// The sets interpolated at the centroid, a mask.
    pub tex_coords_centroid: u16,
    /// The number of registers it uses.
    pub register_count: u8,
    /// Whether the colour output is written from the half-precision register 0.
    pub output_from_h0: bool,
    /// Whether the program writes depth.
    pub depth_replace: bool,
    /// Whether the program can kill the pixel.
    pub pixel_kill: bool,
    /// The two padding bytes after the flags, as stored.
    pub padding: [u8; 2],
}

/// A program's stage and its stage-specific header.
#[derive(Clone, Debug, PartialEq, Eq)]
pub enum Stage {
    /// A vertex program.
    Vertex(Vertex),
    /// A fragment program.
    Fragment(Fragment),
}

/// One parameter record of the container.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct Parameter<'a> {
    /// Original CGtype, CGresource and CGenum values, including unknown values.
    pub ty: u32,
    /// The CGresource (a texture unit, an attribute, ...).
    pub resource: u32,
    /// The CGenum variability (varying, uniform, ...).
    pub variability: u32,
    /// The index within the resource, as a signed value.
    pub resource_index: i32,
    /// NUL-terminated source strings, excluding their terminator; no encoding conversion.
    pub name: Option<&'a [u8]>,
    /// The semantic string, where the parameter has one.
    pub semantic: Option<&'a [u8]>,
    /// The CGenum direction (in, out, ...).
    pub direction: u32,
    /// -1 denotes a global parameter.
    pub parameter_number: i32,
    /// Whether the program references the parameter.
    pub referenced: bool,
    /// Whether the parameter is shared between programs.
    pub shared: bool,
    /// Big-endian float bits, preserving NaNs and signed zeros. Float scalar,
    /// vector and matrix types are supported; other types with defaults refuse.
    pub default_value: Option<Vec<u32>>,
    /// Byte offsets of 16-byte constants in this program's microcode.
    pub embedded_constants: Vec<u32>,
}

impl Parameter<'_> {
    /// CG_TEXUNIT0 through CG_TEXUNIT15. A resource index alone is not a texunit.
    pub fn texture_unit(&self) -> Option<u32> {
        self.resource.checked_sub(2048).filter(|&n| n < 16)
    }
}

/// A container as read.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct Program<'a> {
    /// The profile: 7003 vertex, 7004 fragment.
    pub profile: u32,
    /// The binary revision (6).
    pub revision: u32,
    /// The stage-specific header.
    pub stage: Stage,
    /// The parameter records, in order.
    pub parameters: Vec<Parameter<'a>>,
    /// Original byte order and inline constants retained verbatim.
    pub microcode: &'a [u8],
    /// Exactly the advertised container size, excluding any caller's padding.
    pub bytes: &'a [u8],
}

struct Reader<'a> {
    bytes: &'a [u8],
    fixed: Vec<Range<usize>>,
}

impl<'a> Reader<'a> {
    fn bytes(&self, at: usize, n: usize) -> Result<&'a [u8], Error> {
        View::new(self.bytes)
            .slice(at, n)
            .map_err(|e| error(at, e.to_string()))
    }
    fn word(&self, at: usize) -> Result<u32, Error> {
        View::new(self.bytes)
            .u32(at, Big)
            .map_err(|e| error(at, e.to_string()))
    }
    fn offset(&self, at: usize) -> Result<usize, Error> {
        usize::try_from(self.word(at)?).map_err(|_| error(at, "offset outside address space"))
    }
    fn boolean(&self, at: usize, byte: bool) -> Result<bool, Error> {
        let n = if byte {
            u32::from(
                *self
                    .bytes(at, 1)?
                    .first()
                    .ok_or_else(|| error(at, "a boolean byte"))?,
            )
        } else {
            self.word(at)?
        };
        match n {
            0 => Ok(false),
            1 => Ok(true),
            _ => Err(error(at, "boolean is neither zero nor one")),
        }
    }
    fn range(&self, at: usize, count: usize, stride: usize) -> Result<Range<usize>, Error> {
        let n = count
            .checked_mul(stride)
            .ok_or_else(|| error(at, "array size overflow"))?;
        self.bytes(at, n)?;
        Ok(at..plus(at, n)?)
    }
    fn reserve(&mut self, r: Range<usize>) -> Result<(), Error> {
        if !r.start.is_multiple_of(4) {
            return Err(error(r.start, "unaligned structure"));
        }
        self.metadata(r.clone())?;
        if !r.is_empty() {
            self.fixed.push(r);
        }
        Ok(())
    }
    fn metadata(&self, r: Range<usize>) -> Result<(), Error> {
        if !r.is_empty() && self.fixed.iter().any(|f| r.start < f.end && f.start < r.end) {
            return Err(error(
                r.start,
                "overlapping structures or metadata inside a fixed structure",
            ));
        }
        Ok(())
    }
    fn string(&self, field: usize) -> Result<Option<&'a [u8]>, Error> {
        let at = self.offset(field)?;
        if at == 0 {
            return Ok(None);
        }
        let tail = self
            .bytes
            .get(at..)
            .ok_or_else(|| error(field, "string offset outside container"))?;
        let len = tail
            .iter()
            .position(|&b| b == 0)
            .ok_or_else(|| error(at, "unterminated string"))?;
        let r = self.range(at, plus(len, 1)?, 1)?;
        self.metadata(r)?;
        Ok(Some(self.bytes(at, len)?))
    }
    fn floats(&self, field: usize, ty: u32) -> Result<Option<Vec<u32>>, Error> {
        let at = self.offset(field)?;
        if at == 0 {
            return Ok(None);
        }
        let count = match ty {
            1045 | 1091 => 1,
            1046..=1048 => (ty.saturating_sub(1044)) as usize,
            1049..=1064 => {
                let m = ty.saturating_sub(1049);
                ((m / 4)
                    .saturating_add(1)
                    .saturating_mul((m % 4).saturating_add(1))) as usize
            }
            _ => {
                return Err(error(
                    field,
                    format!("default values for CGtype {ty} are unsupported"),
                ));
            }
        };
        if !at.is_multiple_of(4) {
            return Err(error(field, "unaligned default value"));
        }
        let r = self.range(at, count, 4)?;
        self.metadata(r.clone())?;
        r.step_by(4)
            .map(|p| self.word(p))
            .collect::<Result<Vec<_>, _>>()
            .map(Some)
    }
    fn embedded(&self, field: usize, ucode_size: usize) -> Result<Vec<u32>, Error> {
        let at = self.offset(field)?;
        if at == 0 {
            return Ok(Vec::new());
        }
        if !at.is_multiple_of(4) {
            return Err(error(field, "unaligned embedded constant table"));
        }
        let count = self.offset(at)?;
        let r = self.range(
            at,
            count
                .checked_add(1)
                .ok_or_else(|| error(at, "constant count overflow"))?,
            4,
        )?;
        self.metadata(r.clone())?;
        let mut offsets = Vec::new();
        for field in r.step_by(4).skip(1) {
            let offset = self.word(field)?;
            let n = usize::try_from(offset).map_err(|_| error(field, "constant outside address space"))?;
            if !n.is_multiple_of(16) || n.checked_add(16).is_none_or(|end| end > ucode_size) {
                return Err(error(
                    field,
                    "embedded constant is unaligned or outside microcode",
                ));
            }
            offsets.push(offset);
        }
        Ok(offsets)
    }
}

/// Read one container with no trailing bytes. Padding and concatenation belong
/// to the calling file format; use [`parse_prefix`] for those.
pub fn parse(bytes: &[u8]) -> Result<Program<'_>, Error> {
    let p = parse_prefix(bytes)?;
    if p.bytes.len() != bytes.len() {
        return Err(error(p.bytes.len(), "trailing bytes after container"));
    }
    Ok(p)
}

/// Read the advertised first container, keeping every offset relative to it.
/// Refuses unsupported profiles/revisions, out-of-bounds or overlapping fixed
/// structures, invalid booleans, unterminated strings, and invalid constants.
pub fn parse_prefix(bytes: &[u8]) -> Result<Program<'_>, Error> {
    let header = Reader {
        bytes,
        fixed: Vec::new(),
    };
    header.bytes(0, 32)?;
    let profile = header.word(0)?;
    if !matches!(profile, 7003 | 7004) {
        return Err(error(
            0,
            "unsupported profile (expected vertex 7003 or fragment 7004)",
        ));
    }
    let revision = header.word(4)?;
    if revision != 6 {
        return Err(error(4, "unsupported binary revision (expected 6)"));
    }
    let total = header.offset(8)?;
    let mut r = Reader {
        bytes: header.bytes(0, total)?,
        fixed: Vec::new(),
    };
    r.bytes(0, 32)?;
    r.fixed.push(0..32);
    let count = r.offset(12)?;
    let params = r.offset(16)?;
    let stage_at = r.offset(20)?;
    let ucode_size = r.offset(24)?;
    let ucode_at = r.offset(28)?;
    let param_range = r.range(params, count, 48)?;
    let params_at = param_range.clone().step_by(48);
    r.reserve(param_range)?;
    let stage_range = r.range(stage_at, 1, 24)?;
    r.reserve(stage_range)?;
    let ucode_range = r.range(ucode_at, ucode_size, 1)?;
    r.reserve(ucode_range)?;
    if !ucode_at.is_multiple_of(16) || !ucode_size.is_multiple_of(16) {
        return Err(error(28, "microcode offset or size is not 16-byte aligned"));
    }
    let stage_bytes = r.bytes(stage_at, 24)?;
    let s = Reader {
        bytes: stage_bytes,
        fixed: Vec::new(),
    };
    let instruction_count = s.word(0)?;
    if usize::try_from(instruction_count)
        .ok()
        .and_then(|slots| slots.checked_mul(16))
        != Some(ucode_size)
    {
        return Err(error(
            stage_at,
            "instruction slot count disagrees with microcode size",
        ));
    }
    let stage = if profile == 7003 {
        Stage::Vertex(Vertex {
            instruction_count,
            instruction_slot: s.word(4)?,
            register_count: s.word(8)?,
            attribute_input_mask: s.word(12)?,
            attribute_output_mask: s.word(16)?,
            user_clip_mask: s.word(20)?,
        })
    } else {
        let stage_view = View::new(stage_bytes);
        let half = |at| {
            stage_view
                .u16(at, Big)
                .map_err(|e| error(stage_at.saturating_add(at), e.to_string()))
        };
        let flag = |at| -> Result<bool, Error> { r.boolean(plus(stage_at, at)?, true) };
        let byte = |at| {
            stage_view
                .u8(at)
                .map_err(|e| error(stage_at.saturating_add(at), e.to_string()))
        };
        Stage::Fragment(Fragment {
            instruction_count,
            attribute_input_mask: s.word(4)?,
            partial_tex_type: s.word(8)?,
            tex_coords_input_mask: half(12)?,
            tex_coords_2d: half(14)?,
            tex_coords_centroid: half(16)?,
            register_count: byte(18)?,
            output_from_h0: flag(19)?,
            depth_replace: flag(20)?,
            pixel_kill: flag(21)?,
            padding: [byte(22)?, byte(23)?],
        })
    };
    let mut parameters = Vec::new();
    for at in params_at {
        let field = |delta| plus(at, delta);
        let ty = r.word(at)?;
        // The source signed fields are two's-complement 32-bit values.
        parameters.push(Parameter {
            ty,
            resource: r.word(field(4)?)?,
            variability: r.word(field(8)?)?,
            resource_index: r.word(field(12)?)? as i32,
            name: r.string(field(16)?)?,
            default_value: r.floats(field(20)?, ty)?,
            embedded_constants: r.embedded(field(24)?, ucode_size)?,
            semantic: r.string(field(28)?)?,
            direction: r.word(field(32)?)?,
            parameter_number: r.word(field(36)?)? as i32,
            referenced: r.boolean(field(40)?, false)?,
            shared: r.boolean(field(44)?, false)?,
        });
    }
    Ok(Program {
        profile,
        revision,
        stage,
        parameters,
        microcode: r.bytes(ucode_at, ucode_size)?,
        bytes: r.bytes,
    })
}

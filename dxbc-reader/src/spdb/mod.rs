//! The `SPDB` part `fxc /Zi` writes: a program database (PDB) in a multi-stream file, which says the source line of
//! each instruction and where each variable lives. The listing writes it as `#line` lines, a block of the variables'
//! initial locations before the first instruction with a line, and after an instruction the variables whose location
//! starts at the next one: a function's own variables after any instruction, an inlined call's only after one in the
//! code the call spans.
//!
//! Read from the PDB, as fxc 10.0.26100.4654 writes it:
//! - stream 1 (PDB info) names the string table stream, `/names`;
//! - stream 3 (DBI) lists the modules, each with its own stream of symbols and C13 line information;
//! - the C13 subsections give the source files (`0xf4`, checksums naming paths in `/names`), the line of each
//!   instruction's byte offset (`0xf2`) and the first line of each inlined function (`0xf6`);
//! - the symbols give the functions (`S_GPROC32`), the inlined calls with the lines of their instructions
//!   (`S_INLINESITE`, binary annotations), the variables (`S_LOCAL`) and their register ranges (`S_DEFRANGE_HLSL`);
//! - stream 2 (TPI) gives the variables' types, for the member a register holds ([`types`]).
use std::collections::BTreeMap;

mod msf;
mod types;

use msf::Stream;
use types::Types;

use crate::{Result, error};

const LANES: [char; 4] = ['x', 'y', 'z', 'w'];

/// `S_END`, which closes a function.
const END: u16 = 0x0006;
/// `S_GPROC32`: a function; its code offset at 28.
const FUNCTION: u16 = 0x1110;
/// `S_LOCAL`: a variable; its type at 0, flags at 4, name at 6.
const LOCAL: u16 = 0x113e;
/// `S_INLINESITE`: an inlined call; the inlinee at 8, binary annotations from 12.
const INLINE_SITE: u16 = 0x114d;
/// `S_INLINESITE_END`.
const INLINE_SITE_END: u16 = 0x114e;
/// `S_DEFRANGE_HLSL`: a range of the variable before it in a register.
const RANGE: u16 = 0x1150;

/// What the listing writes from an `SPDB` part.
#[derive(Debug, Default)]
pub(crate) struct Annotations {
    /// The byte offset of the first record with a source line: the initial locations are written before it, and no
    /// location after a record before it.
    pub(crate) first: Option<u32>,
    /// The lines of the initial locations: the variables in registers before `first`, one line to a register.
    pub(crate) initial: Vec<String>,
    /// The source file's path and line of each record's byte offset that has one.
    pub(crate) sources: BTreeMap<u32, (String, u32)>,
    /// The locations that start at each byte offset, and the inlined call whose scope holds the variable (`None` for a
    /// function's own).
    starting: BTreeMap<u32, Vec<(Location, Option<usize>)>>,
    /// The code each inlined call spans: from its first row's byte offset to its last row's end, any of the caller's
    /// code between its rows among it.
    sites: Vec<(u32, u32)>,
}

impl Annotations {
    /// The locations written after the record at byte offset `at`: those that start at `next`, the following record,
    /// where the variable's scope covers `at`. A function's variables are written after any record; an inlined call's
    /// only after a record in the code the call spans, so not after the caller's code that leads into it.
    pub(crate) fn after(&self, at: u32, next: u32) -> Vec<&Location> {
        let covers = |site: usize| {
            self.sites
                .get(site)
                .is_some_and(|&(start, end)| start <= at && at < end)
        };
        self.starting
            .get(&next)
            .into_iter()
            .flatten()
            .filter(|(_, site)| site.is_none_or(covers))
            .map(|(location, _)| location)
            .collect()
    }
}

/// A variable's location in a register: `r0.x <- name.member`, and where Microsoft's disassembler could not name the
/// byte the register holds, its internal error, after which it writes no further location of the instruction.
#[derive(Clone, Debug)]
pub(crate) struct Location {
    pub(crate) text: String,
    pub(crate) error: Option<&'static str>,
}

/// A variable's range in a register (`S_DEFRANGE_HLSL`).
struct Range {
    /// The operand type (`D3D10_SB_OPERAND_TYPE`) of the register.
    register: u16,
    /// The number of register indices (bits 0 and 1 of the flags word).
    dimension: u16,
    /// The byte offset in the variable the register's component holds.
    parent: u16,
    /// The byte offset of the first instruction of the range.
    start: u32,
    /// The gaps in the range: byte offsets from `start` and lengths.
    gaps: Vec<(u16, u16)>,
    /// The register indices: the first is the register times 16 plus the component times 4 (the register alone for an
    /// indexable temp and `m#`).
    indices: Vec<u32>,
}

/// What the initial locations group by: the operand type, the register and the further indices.
type Base = (u16, Option<u32>, Vec<u32>);

/// A variable (`S_LOCAL`) and its ranges.
struct Local {
    name: String,
    ty: u32,
    ranges: Vec<Range>,
}

/// A scope's variables and its nested scopes.
#[derive(Default)]
struct Scope {
    /// The inlined call the scope is (its index in the calls in symbol order), `None` for a function.
    site: Option<usize>,
    nested: Vec<Scope>,
    locals: Vec<Local>,
}

impl Scope {
    /// The variables in symbol order, a scope's own before its nested scopes', each with the inlined call whose scope
    /// holds it; and into `initial` their indices in the order of the initial locations, which put a scope's nested
    /// scopes' variables before its own.
    fn flatten(self, out: &mut Vec<(Local, Option<usize>)>, initial: &mut Vec<usize>) {
        let own = out.len()..out.len().saturating_add(self.locals.len());
        out.extend(self.locals.into_iter().map(|local| (local, self.site)));
        for scope in self.nested {
            scope.flatten(out, initial);
        }
        initial.extend(own);
    }
}

/// A row of an inlined call's binary annotations: the code it covers and its source.
struct SiteRow {
    start: u32,
    end: u32,
    file: u32,
    line: u32,
}

/// A module's parts: its symbols and its C13 subsections.
struct Module<'a> {
    stream: &'a Stream,
    symbols: (usize, usize),
    c13: (usize, usize),
}

/// The annotations of the `SPDB` part `part`. Refuses an MSF or PDB structure that does not read as described in
/// the module documentation, naming the part's word.
pub(crate) fn annotations(part: &[u8]) -> Result<Annotations> {
    let streams = msf::streams(part)?;
    let stream = |n: usize| -> Result<&Stream> {
        streams.get(n).ok_or_else(|| {
            error(
                0,
                format!(
                    "the SPDB has {} streams, where stream {n} is needed",
                    streams.len()
                ),
            )
        })
    };
    let names = string_table(&streams, stream(1)?)?;
    let modules = modules(&streams, stream(3)?)?;
    let types = Types::read(stream(2)?)?;

    let mut files: BTreeMap<u32, String> = BTreeMap::new();
    let mut lines: Vec<(u32, u32, u32, bool)> = Vec::new();
    let mut inlinees: BTreeMap<u32, (u32, u32)> = BTreeMap::new();
    for m in &modules {
        subsections(m, names, &mut files, &mut lines, &mut inlinees)?;
    }
    // each offset's line: a statement's first, else any
    let mut located: BTreeMap<u32, (u32, u32)> = BTreeMap::new();
    for &(offset, file, line, statement) in &lines {
        if statement {
            located.entry(offset).or_insert((file, line));
        }
    }
    for &(offset, file, line, _) in &lines {
        located.entry(offset).or_insert((file, line));
    }

    let mut sites: Vec<Vec<SiteRow>> = Vec::new();
    let mut root = vec![Scope::default()];
    let mut code = 0u32;
    for m in &modules {
        let s = m.stream;
        let (mut at, end) = m.symbols;
        while at < end {
            let len = usize::from(s.u16(at)?);
            let kind = s.u16(s.plus(at, 2)?)?;
            let data = s.plus(at, 4)?;
            let next = s.plus(at, len.saturating_add(2))?;
            if len < 2 || next > end {
                return Err(s.fail(at, format!("a symbol of {len} bytes past the symbols' end")));
            }
            match kind {
                FUNCTION => {
                    code = s.u32(s.plus(data, 28)?)?;
                    root.push(Scope::default());
                }
                INLINE_SITE => {
                    root.push(Scope {
                        site: Some(sites.len()),
                        ..Scope::default()
                    });
                    sites.push(site(s, data, next, code, &inlinees)?);
                }
                END | INLINE_SITE_END => {
                    let inner = root.pop().unwrap_or_default();
                    root.last_mut()
                        .ok_or_else(|| s.fail(at, "a scope's end with no scope open"))?
                        .nested
                        .push(inner);
                }
                LOCAL => {
                    let (name, _) = s.string(s.plus(data, 6)?)?;
                    if let Some(scope) = root.last_mut() {
                        scope.locals.push(Local {
                            name,
                            ty: s.u32(data)?,
                            ranges: Vec::new(),
                        });
                    }
                }
                RANGE => {
                    let range = range(s, data, next)?;
                    root.last_mut()
                        .and_then(|scope| scope.locals.last_mut())
                        .ok_or_else(|| {
                            s.fail(at, "a register range with no variable before it in its scope")
                        })?
                        .ranges
                        .push(range);
                }
                _ => {}
            }
            at = next;
        }
    }
    let mut locals = Vec::new();
    let mut initial = Vec::new();
    match <[Scope; 1]>::try_from(root) {
        Ok([scope]) => scope.flatten(&mut locals, &mut initial),
        Err(open) => {
            return Err(error(
                0,
                format!(
                    "the SPDB symbols leave {} scopes open",
                    open.len().saturating_sub(1)
                ),
            ));
        }
    }

    let path = |file: u32| -> Result<String> {
        files.get(&file).cloned().ok_or_else(|| {
            error(
                0,
                format!("SPDB line information names file {file}, which no checksum record is"),
            )
        })
    };
    let mut out = Annotations {
        first: located.keys().next().copied(),
        ..Annotations::default()
    };
    for (&offset, &(file, line)) in &located {
        // the innermost inlined call that covers the offset gives its line instead
        let inlined = sites
            .iter()
            .filter_map(|rows| rows.iter().find(|r| r.start <= offset && offset < r.end))
            .next_back();
        let (file, line) = inlined.map_or((file, line), |r| (r.file, r.line));
        out.sources.insert(offset, (path(file)?, line));
    }
    let location = |local: &Local, r: &Range| -> Result<Location> {
        // an indexable temp or `m#` holding the variable from its start is named by the variable alone
        let path = match (r.register, r.parent) {
            (3 | 16, 0) => types::Path::default(),
            _ => types.path(local.ty, u32::from(r.parent))?,
        };
        Ok(Location {
            text: format!("{} <- {}{}", register(r), local.name, path.text),
            error: path.error,
        })
    };
    let before_first = |r: &Range| out.first.is_some_and(|first| r.start <= first);
    // the initial locations group by register: one line to each run of the same register
    let mut groups: Vec<(Base, Vec<String>)> = Vec::new();
    for (local, _) in initial.iter().filter_map(|&i| locals.get(i)) {
        for r in local.ranges.iter().filter(|r| before_first(r)) {
            let name = location(local, r)?;
            let base = (
                r.register,
                r.indices.first().map(|i| i / 16),
                r.indices.get(1..).unwrap_or_default().to_vec(),
            );
            match groups.last_mut() {
                Some((b, entries)) if *b == base => entries.push(name.text),
                _ => groups.push((base, vec![name.text])),
            }
        }
    }
    for (local, site) in &locals {
        for r in &local.ranges {
            let name = location(local, r)?;
            if !before_first(r) {
                out.starting
                    .entry(r.start)
                    .or_default()
                    .push((name.clone(), *site));
            }
            // after a gap the location starts again
            for &(gap, len) in &r.gaps {
                let again = r
                    .start
                    .saturating_add(u32::from(gap))
                    .saturating_add(u32::from(len));
                out.starting.entry(again).or_default().push((name.clone(), *site));
            }
        }
    }
    out.initial = groups
        .into_iter()
        .map(|(_, entries)| entries.join("; "))
        .collect();
    out.sites = sites
        .iter()
        .map(|rows| {
            let start = rows.iter().map(|r| r.start).min().unwrap_or(0);
            let end = rows.iter().map(|r| r.end).max().unwrap_or(0);
            (start, end)
        })
        .collect();
    Ok(out)
}

/// The string table `/names`, found through the named stream map of the PDB info stream (stream 1).
fn string_table<'a>(streams: &'a [Stream], info: &Stream) -> Result<&'a Stream> {
    // the version, signature, age and GUID, then the map: the names' bytes, the entry count and capacity, the
    // present and deleted bit sets, and a name offset and stream number for each present entry
    let names_size = info.size(28)?;
    let names_at = 32usize;
    let mut at = info.plus(names_at, names_size)?;
    let count = info.size(at)?;
    at = info.plus(at, 8)?;
    for _ in 0..2 {
        let words = info.size(at)?;
        at = info.plus(at, words.saturating_mul(4).saturating_add(4))?;
    }
    for _ in 0..count {
        let (name, _) = info.string(info.plus(names_at, info.size(at)?)?)?;
        let n = info.size(info.plus(at, 4)?)?;
        if name == "/names" {
            let table = streams
                .get(n)
                .ok_or_else(|| info.fail(at, format!("/names is stream {n}, which the MSF does not have")))?;
            if table.u32(0)? != 0xeffe_effe {
                return Err(table.fail(0, "the string table's signature is not 0xeffeeffe"));
            }
            return Ok(table);
        }
        at = info.plus(at, 8)?;
    }
    Err(info.fail(0, "the PDB names no /names stream"))
}

/// The modules the DBI stream (stream 3) lists: the module information records from byte 64, as many bytes as the
/// header's word at 24 says. A record has the module's stream at 34 (`u16`), the sizes of its symbols, C11 and C13
/// lines at 36, 40 and 44, then two names, and is padded to 4 bytes.
fn modules<'a>(streams: &'a [Stream], dbi: &Stream) -> Result<Vec<Module<'a>>> {
    let end = dbi.plus(64, dbi.size(24)?)?;
    let mut at = 64usize;
    let mut out = Vec::new();
    while at < end {
        let n = usize::from(dbi.u16(dbi.plus(at, 34)?)?);
        let symbols = dbi.size(dbi.plus(at, 36)?)?;
        let c11 = dbi.size(dbi.plus(at, 40)?)?;
        let c13 = dbi.size(dbi.plus(at, 44)?)?;
        let (_, next) = dbi.string(dbi.plus(at, 64)?)?;
        let (_, next) = dbi.string(next)?;
        at = next.next_multiple_of(4);
        let stream = streams
            .get(n)
            .ok_or_else(|| dbi.fail(at, format!("a module in stream {n}, which the MSF does not have")))?;
        let c13_at = stream.plus(symbols, c11)?;
        stream.bytes(c13_at, c13)?;
        out.push(Module {
            stream,
            // the symbols start after a 4-byte signature
            symbols: (4, symbols),
            c13: (c13_at, c13_at.saturating_add(c13)),
        });
    }
    Ok(out)
}

/// A module's C13 subsections: each a kind, a size and its bytes, padded to 4.
fn subsections(
    m: &Module<'_>,
    names: &Stream,
    files: &mut BTreeMap<u32, String>,
    lines: &mut Vec<(u32, u32, u32, bool)>,
    inlinees: &mut BTreeMap<u32, (u32, u32)>,
) -> Result<()> {
    let s = m.stream;
    let (mut at, end) = m.c13;
    while at < end {
        let kind = s.u32(at)?;
        let size = s.size(s.plus(at, 4)?)?;
        let data = s.plus(at, 8)?;
        let stop = s.plus(data, size)?;
        if stop > end {
            return Err(s.fail(
                at,
                format!("a C13 subsection of {size} bytes past the module's end"),
            ));
        }
        match kind {
            // file checksums: a name offset in /names, the checksum's size and kind, the checksum, padded to 4
            0xf4 => {
                let mut r = data;
                while r < stop {
                    let key = u32::try_from(r.saturating_sub(data)).unwrap_or(u32::MAX);
                    let (path, _) = names.string(names.plus(12, s.size(r)?)?)?;
                    files.insert(key, path);
                    let checksum = usize::from(s.u8(s.plus(r, 4)?)?);
                    r = s.plus(r, checksum.saturating_add(6))?.next_multiple_of(4);
                }
            }
            // lines: the code offset at 0 and flags at 6 (bit 0: columns follow), then blocks of a file, a count, the
            // block's size and the count's (offset, line word) pairs
            0xf2 => {
                let base = s.u32(data)?;
                let mut r = s.plus(data, 12)?;
                while r < stop {
                    let file = s.u32(r)?;
                    let count = s.size(s.plus(r, 4)?)?;
                    let block = s.size(s.plus(r, 8)?)?;
                    for n in 0..count {
                        let pair = s.plus(r, n.saturating_mul(8).saturating_add(12))?;
                        let word = s.u32(s.plus(pair, 4)?)?;
                        lines.push((
                            base.saturating_add(s.u32(pair)?),
                            file,
                            word & 0x00ff_ffff,
                            word & 0x8000_0000 != 0,
                        ));
                    }
                    if block == 0 {
                        return Err(s.fail(r, "a line block of 0 bytes"));
                    }
                    r = s.plus(r, block)?;
                }
            }
            // inlinee lines: a signature, then records of the inlinee, its file and its first line; under signature 1
            // (`CV_INLINEE_SOURCE_LINE_SIGNATURE_EX`, written where an inlined function's code comes from more than
            // one file, an `#include` among them) each record goes on with a count and that many further files, which
            // the binary annotations name again where they switch to one
            0xf6 => {
                let signature = s.u32(data)?;
                if signature > 1 {
                    return Err(s.fail(
                        data,
                        format!("inlinee lines of signature {signature}, where 0 and 1 are known"),
                    ));
                }
                let mut r = s.plus(data, 4)?;
                while r < stop {
                    inlinees.insert(s.u32(r)?, (s.u32(s.plus(r, 4)?)?, s.u32(s.plus(r, 8)?)?));
                    r = s.plus(r, 12)?;
                    if signature == 1 {
                        let extra = s.size(r)?;
                        r = s.plus(r, extra.saturating_add(1).saturating_mul(4))?;
                    }
                }
            }
            _ => {}
        }
        at = s.plus(data, size.next_multiple_of(4))?;
    }
    Ok(())
}

/// A compressed unsigned number of the binary annotations at `at`: one byte under `0x80`, two from `0x80` (14 bits),
/// four from `0xc0` (29 bits); and the byte after it.
fn compressed(s: &Stream, at: usize) -> Result<(u32, usize)> {
    let b = |n: usize| -> Result<u32> { Ok(u32::from(s.u8(s.plus(at, n)?)?)) };
    let first = b(0)?;
    if first & 0x80 == 0 {
        Ok((first, s.plus(at, 1)?))
    } else if first & 0xc0 == 0x80 {
        Ok((((first & 0x3f) << 8) | b(1)?, s.plus(at, 2)?))
    } else if first & 0xe0 == 0xc0 {
        Ok((
            ((first & 0x1f) << 24) | (b(1)? << 16) | (b(2)? << 8) | b(3)?,
            s.plus(at, 4)?,
        ))
    } else {
        Err(s.fail(at, format!("a compressed number starting {first:#04x}")))
    }
}

/// A signed delta of the binary annotations: bit 0 the sign, the rest the magnitude.
fn signed(value: u32) -> i64 {
    let magnitude = i64::from(value >> 1);
    if value & 1 != 0 {
        magnitude.saturating_neg()
    } else {
        magnitude
    }
}

/// The rows of an inlined call (`S_INLINESITE` data from `data` to `end`), from its function's code offset `code` and
/// its inlinee's first line.
fn site(
    s: &Stream,
    data: usize,
    end: usize,
    code: u32,
    inlinees: &BTreeMap<u32, (u32, u32)>,
) -> Result<Vec<SiteRow>> {
    let inlinee = s.u32(s.plus(data, 8)?)?;
    let &(mut file, line) = inlinees.get(&inlinee).ok_or_else(|| {
        s.fail(
            data,
            format!("an inlined call of inlinee {inlinee:#x}, which no inlinee line names"),
        )
    })?;
    let mut line = i64::from(line);
    let mut code = i64::from(code);
    // each row: its code offset, its length where stated, its file and line
    let mut rows: Vec<(i64, Option<u32>, u32, i64)> = Vec::new();
    let mut at = s.plus(data, 12)?;
    while at < end {
        let (op, next) = compressed(s, at)?;
        at = next;
        let mut operand = || -> Result<u32> {
            let (value, next) = compressed(s, at)?;
            at = next;
            Ok(value)
        };
        match op {
            0 => break,
            // the code offset
            1 => code = i64::from(operand()?),
            // a code offset delta, which starts a row
            3 => {
                code = code.saturating_add(i64::from(operand()?));
                rows.push((code, None, file, line));
            }
            // the length of the last row, which moves the code offset past it (where a length and a code delta in
            // one, 12, does not): the next row's delta counts from the row's end
            4 => {
                let len = operand()?;
                rows.last_mut()
                    .ok_or_else(|| s.fail(at, "a code length before any row"))?
                    .1 = Some(len);
                code = code.saturating_add(i64::from(len));
            }
            5 => file = operand()?,
            6 => line = line.saturating_add(signed(operand()?)),
            // code and line deltas in one: the code's in the low 4 bits
            11 => {
                let both = operand()?;
                code = code.saturating_add(i64::from(both & 0xf));
                line = line.saturating_add(signed(both >> 4));
                rows.push((code, None, file, line));
            }
            // a length and a code delta
            12 => {
                let len = operand()?;
                code = code.saturating_add(i64::from(operand()?));
                rows.push((code, Some(len), file, line));
            }
            2 | 7 | 8 | 9 | 10 | 13 => {
                operand()?;
            }
            _ => return Err(s.fail(at, format!("binary annotation {op}, where 0 to 13 are known"))),
        }
    }
    let narrow = |v: i64| {
        u32::try_from(v).map_err(|_| s.fail(data, format!("an inlined call's code offset or line {v}")))
    };
    let mut out = Vec::new();
    for (n, &(start, len, file, line)) in rows.iter().enumerate() {
        let end = match len {
            Some(len) => start.saturating_add(i64::from(len)),
            None => rows.get(n.saturating_add(1)).map_or(start, |r| r.0),
        };
        out.push(SiteRow {
            start: narrow(start)?,
            end: narrow(end)?,
            file,
            line: narrow(line)?,
        });
    }
    Ok(out)
}

/// A register range (`S_DEFRANGE_HLSL` data from `data` to `end`): the operand type, flags (bits 0 and 1 the
/// number of indices), the byte offset in the variable and its size, the range (start, section, length), then gaps of
/// a start and a length, then the indices.
fn range(s: &Stream, data: usize, end: usize) -> Result<Range> {
    let dimension = s.u16(s.plus(data, 2)?)? & 3;
    let rest = s.plus(data, 16)?;
    let indices_at = end
        .checked_sub(usize::from(dimension).saturating_mul(4))
        .filter(|&at| at >= rest)
        .ok_or_else(|| {
            s.fail(
                data,
                format!("a register range too short for {dimension} indices"),
            )
        })?;
    let mut gaps = Vec::new();
    let mut at = rest;
    while at.saturating_add(4) <= indices_at {
        gaps.push((s.u16(at)?, s.u16(s.plus(at, 2)?)?));
        at = s.plus(at, 4)?;
    }
    let register = s.u16(data)?;
    if register_name(register).is_none() {
        return Err(s.fail(
            data,
            format!("a register range in operand type {register}, which the listing does not name"),
        ));
    }
    let mut indices = Vec::new();
    for n in 0..usize::from(dimension) {
        indices.push(s.u32(s.plus(indices_at, n.saturating_mul(4))?)?);
    }
    Ok(Range {
        register,
        dimension,
        parent: s.u16(s.plus(data, 4)?)?,
        start: s.u32(s.plus(data, 8)?)?,
        gaps,
        indices,
    })
}

/// The name of operand type `register` (`D3D10_SB_OPERAND_TYPE`) in a location, and whether its number follows it;
/// `None` for a type no location was seen to name.
fn register_name(register: u16) -> Option<(&'static str, bool)> {
    Some(match register {
        0 => ("r", true),
        1 => ("v", true),
        2 => ("o", true),
        3 => ("x", true),
        6 => ("s", true),
        7 => ("t", true),
        8 => ("cb", true),
        11 => ("vPrim", false),
        12 => ("oDepth", false),
        15 => ("oMask", false),
        16 => ("m", true),
        22 => ("vOutputControlPointID", false),
        23 => ("vForkInstanceID", false),
        24 => ("vJoinInstanceID", false),
        25 => ("vicp", false),
        26 => ("vocp", false),
        27 => ("vpc", true),
        28 => ("vDomain", false),
        29 => ("this", false),
        30 => ("u", true),
        31 => ("g", true),
        32 => ("vThreadID", false),
        33 => ("vThreadGroupID", false),
        34 => ("vThreadIDInGroup", false),
        35 => ("vCoverage", false),
        36 => ("vThreadIDInGroupFlattened", false),
        37 => ("vGSInstanceID", false),
        38 => ("oDepthGE", false),
        39 => ("oDepthLE", false),
        40 => ("vCycleCounter", false),
        41 => ("oStencilRef", false),
        42 => ("vInnerCoverage", false),
        _ => return None,
    })
}

/// A register as a location names it: `r0.x`, `o1.w`, `x2`, `vOutputControlPointID`, `vicp[3].y`, `x[1][2]`.
fn register(r: &Range) -> String {
    let (name, numbered) = register_name(r.register).unwrap_or(("", true));
    let Some(&first) = r.indices.first().filter(|_| r.dimension > 0) else {
        return name.to_owned();
    };
    // an indexable temp and `m#` are named by their number alone, without a component
    let whole = matches!(r.register, 3 | 16);
    let number = if whole { first } else { first / 16 };
    let component = if whole {
        String::new()
    } else {
        format!(
            ".{}",
            LANES
                .get(usize::try_from((first % 16) / 4).unwrap_or(0))
                .copied()
                .unwrap_or('x')
        )
    };
    if r.dimension == 2 {
        let outer = r.indices.get(1).copied().unwrap_or(0);
        return format!("{name}[{outer}][{number}]{component}");
    }
    if numbered {
        format!("{name}{number}{component}")
    } else if matches!(r.register, 25 | 26 | 29) {
        format!("{name}[{number}]{component}")
    } else {
        format!("{name}{component}")
    }
}

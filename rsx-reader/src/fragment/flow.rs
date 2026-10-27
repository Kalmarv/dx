//! Conservative texture-unit dependencies, not shader evaluation or role names.
//! Component writes and half/full register overlap are tracked; arithmetic
//! conservatively unions all referenced source components. Branch and predicate
//! dependencies persist after a join, so results are possible influences.
use super::{Control, Error, Instruction, Opcode, Program, Register, SourceKind, error};
use std::collections::BTreeSet;

/// The texture units and interpolators a value may depend on, one bit per unit.
#[derive(Clone, Copy, Debug, Default, PartialEq, Eq)]
pub struct Dependencies {
    /// Bit `n` is texture image unit `n`.
    pub textures: u16,
    /// Encoded interpolator indices, not texture image units.
    pub inputs: u16,
}
impl Dependencies {
    fn join(self, other: Self) -> Self {
        Self {
            textures: self.textures | other.textures,
            inputs: self.inputs | other.inputs,
        }
    }
}

/// One texture sample.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct Sample {
    /// The byte offset of the sampling instruction.
    pub offset: usize,
    /// The texture unit sampled.
    pub unit: u8,
    /// What its first source (the coordinates) depends on.
    pub coordinates: Dependencies,
    /// All sampling arguments, including separate LOD, bias or gradients.
    pub arguments: Dependencies,
}

/// What one requested output register depends on.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct Output {
    /// The register.
    pub register: Register,
    /// The dependencies of each component (x to w).
    pub components: [Dependencies; 4],
}

/// The result of [`analyze`].
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct Analysis {
    /// The texture samples, in program order.
    pub samples: Vec<Sample>,
    /// The requested outputs, in the order they were requested.
    pub outputs: Vec<Output>,
    /// What may kill the pixel.
    pub kill: Dependencies,
    /// Operations which may consume each texture unit, directly or transitively.
    pub consumers: [Vec<Opcode>; 16],
}

#[derive(Clone)]
struct State {
    // A full register contains eight 16-bit lanes; H(2n) and H(2n+1)
    // overlap R(n). Each full component depends on both of its half lanes.
    lanes: [Dependencies; 512],
    cc: [[Dependencies; 4]; 2],
    control: Dependencies,
}
impl Default for State {
    fn default() -> Self {
        Self {
            lanes: [Dependencies::default(); 512],
            cc: [[Dependencies::default(); 4]; 2],
            control: Dependencies::default(),
        }
    }
}
/// The bit of texture unit or interpolator `n` (0 to 15) in a [`Dependencies`] mask.
fn unit_bit(n: usize) -> u16 {
    u32::try_from(n)
        .ok()
        .and_then(|n| 1u16.checked_shl(n))
        .unwrap_or(0)
}
/// The 16-bit lanes component `c` of `r` occupies: one for a half register, two for a full one.
fn positions(r: Register, c: usize) -> std::ops::Range<usize> {
    if r.half {
        let at = usize::from(r.index).saturating_mul(4).saturating_add(c);
        at..at.saturating_add(1)
    } else {
        let at = usize::from(r.index)
            .saturating_mul(8)
            .saturating_add(c.saturating_mul(2));
        at..at.saturating_add(2)
    }
}
impl State {
    fn read(&self, r: Register, c: usize) -> Dependencies {
        positions(r, c)
            .map(|n| self.lanes.get(n).copied().unwrap_or_default())
            .fold(Dependencies::default(), Dependencies::join)
    }
    fn merge(&mut self, other: &Self) {
        for (a, b) in self.lanes.iter_mut().zip(other.lanes) {
            *a = a.join(b);
        }
        for (a, b) in self.cc.iter_mut().flatten().zip(other.cc.into_iter().flatten()) {
            *a = a.join(b);
        }
        self.control = self.control.join(other.control);
    }
    fn predicate(&self, i: &Instruction) -> Dependencies {
        if matches!(i.predicate.test, 0 | 7) {
            Dependencies::default()
        } else {
            i.predicate
                .swizzle
                .iter()
                .map(|&c| {
                    self.cc
                        .get(usize::from(i.predicate.register))
                        .and_then(|row| row.get(usize::from(c)))
                        .copied()
                        .unwrap_or_default()
                })
                .fold(Dependencies::default(), Dependencies::join)
        }
    }
}

/// Follow possible influences into precisely the registers requested by the
/// caller (which owns render-target/depth configuration). Inputs and outputs
/// are not assigned colour/normal/specular meanings. Structured forward IF,
/// conditional writes, KIL and RET are supported. Calls, loops and BRK refuse
/// analysis explicitly; the instruction reader can still inspect them.
pub fn analyze(program: &Program, outputs: &[Register]) -> Result<Analysis, Error> {
    if outputs.iter().any(|r| r.index > 63) {
        return Err(error(0, "output register index exceeds encoding"));
    }
    let code = &program.instructions;
    let mut incoming: Vec<Option<State>> = vec![None; code.len().saturating_add(1)];
    if let Some(first) = incoming.first_mut() {
        *first = Some(State::default());
    }
    let mut exits: Option<State> = None;
    let mut samples = Vec::new();
    let mut consumers: [BTreeSet<u8>; 16] = std::array::from_fn(|_| BTreeSet::new());
    let mut kill = Dependencies::default();
    let mut branches = Vec::new();
    let index = |offset| -> usize { code.iter().position(|i| i.offset == offset).unwrap_or(code.len()) };
    for (n, i) in code.iter().enumerate() {
        if i.indexed_input && i.sources.iter().any(|s| matches!(s.kind, SourceKind::Input(_))) {
            return Err(error(
                i.offset,
                "texture flow analysis does not support indexed interpolators",
            ));
        }
        match i.control {
            Some(Control::If {
                else_offset,
                end_offset,
            }) => branches.push((n, index(else_offset), index(end_offset))),
            Some(Control::Loop { .. } | Control::Call { .. } | Control::Break) => {
                return Err(error(
                    i.offset,
                    "texture flow analysis does not support calls, loops or BRK",
                ));
            }
            _ => {}
        }
    }
    for &(start, _, end) in &branches {
        if branches.iter().any(|&(s, _, e)| start < s && s < end && e > end) {
            return Err(error(
                code.get(start).map_or(0, |i| i.offset),
                "crossing IF regions in flow analysis",
            ));
        }
    }
    let merge_exit = |exits: &mut Option<State>, state: &State| {
        if let Some(old) = exits {
            old.merge(state);
        } else {
            *exits = Some(state.clone());
        }
    };
    for (n, i) in code.iter().enumerate() {
        let Some(mut state) = incoming.get_mut(n).and_then(Option::take) else {
            continue;
        };
        let predicate = state.predicate(i);
        let mut source = Dependencies::default();
        let mut coordinates = Dependencies::default();
        for (operand, s) in i.sources.iter().enumerate() {
            let dependency = match s.kind {
                SourceKind::Register(r) => s
                    .swizzle
                    .iter()
                    .map(|&c| state.read(r, usize::from(c)))
                    .fold(Dependencies::default(), Dependencies::join),
                SourceKind::Input(k) => Dependencies {
                    textures: 0,
                    inputs: unit_bit(usize::from(k)),
                },
                SourceKind::Constant => Dependencies::default(),
            };
            if operand == 0 {
                coordinates = dependency;
            }
            source = source.join(dependency);
        }
        let influenced = source.join(predicate).join(state.control);
        if i.predicate.test != 0 {
            for (unit, set) in consumers.iter_mut().enumerate() {
                if influenced.textures & unit_bit(unit) != 0 {
                    set.insert(i.opcode as u8);
                }
            }
            let mut result = influenced;
            if let Some(unit) = i.texture_unit {
                samples.push(Sample {
                    offset: i.offset,
                    unit,
                    coordinates,
                    arguments: source,
                });
                result.textures |= unit_bit(usize::from(unit));
            }
            if i.opcode.writes_destination() {
                for c in 0..4 {
                    if i.write_mask & unit_bit(c).to_le_bytes()[0] == 0 {
                        continue;
                    }
                    if !i.no_destination && i.destination.index != 63 {
                        for at in positions(i.destination, c) {
                            if let Some(lane) = state.lanes.get_mut(at) {
                                *lane = if i.predicate.test == 7 {
                                    result
                                } else {
                                    lane.join(result)
                                };
                            }
                        }
                    }
                    if i.update_condition
                        && let Some(cc) = state
                            .cc
                            .get_mut(usize::from(i.condition_destination))
                            .and_then(|row| row.get_mut(c))
                    {
                        *cc = if i.predicate.test == 7 {
                            result
                        } else {
                            cc.join(result)
                        };
                    }
                }
            }
            if i.opcode == Opcode::KIL {
                kill = kill.join(predicate).join(state.control);
            }
        }
        let mut next = Vec::new();
        let returns = matches!(i.control, Some(Control::Return));
        let kills = i.opcode == Opcode::KIL;
        if returns && i.predicate.test != 0 {
            state.control = state.control.join(predicate);
        }
        if (i.end || returns && i.predicate.test != 0) && !(kills && i.predicate.test == 7) {
            merge_exit(&mut exits, &state);
        }
        if !i.end && (!(returns || kills) || i.predicate.test != 7) {
            if let Some(Control::If {
                else_offset,
                end_offset,
            }) = i.control
            {
                state.control = state.control.join(predicate);
                if i.predicate.test != 0 {
                    next.push(if n.saturating_add(1) == index(else_offset) {
                        index(end_offset)
                    } else {
                        n.saturating_add(1)
                    });
                }
                if i.predicate.test != 7 {
                    next.push(index(else_offset));
                }
            } else {
                next.push(n.saturating_add(1));
            }
        }
        for mut successor in next {
            // The true block falls over its ELSE body to the matching ENDIF.
            // Process inner boundaries first; several scopes may close together.
            for &(start, else_at, end_at) in branches.iter().rev() {
                if start < n && n < else_at && successor == else_at && else_at != end_at {
                    successor = end_at;
                }
            }
            if let Some(slot) = incoming.get_mut(successor) {
                match slot {
                    Some(old) => old.merge(&state),
                    None => *slot = Some(state.clone()),
                }
            }
        }
    }
    if let Some(state) = incoming.last().and_then(Option::as_ref) {
        merge_exit(&mut exits, state);
    }
    let state = exits.unwrap_or_default();
    Ok(Analysis {
        samples,
        outputs: outputs
            .iter()
            .map(|&r| Output {
                register: r,
                components: std::array::from_fn(|c| state.read(r, c)),
            })
            .collect(),
        kill,
        consumers: consumers.map(|set| set.into_iter().filter_map(Opcode::read).collect()),
    })
}

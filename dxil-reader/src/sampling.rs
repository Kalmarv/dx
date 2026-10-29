//! Which sampler each texture read of a module uses: every `dx.op` call that samples, gathers, queries the level of
//! detail of or loads a resource, with the register, space and class of the texture's handle and of the sampler's
//! handle, and whether the operation compares.
use std::collections::HashMap;

use crate::Result;
use crate::module::{Constant, Function, Module, Op, Value, ValueId};
use crate::reflection::ranges;

const CREATE_HANDLE: i64 = 57;
const ANNOTATE_HANDLE: i64 = 216;
const CREATE_HANDLE_FROM_BINDING: i64 = 217;

/// A resource handle as the program made it: the register of the resource in its class and space.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub struct Handle {
    /// 0 shader resource view, 1 unordered-access view, 2 constant buffer, 3 sampler.
    pub class: u8,
    /// The register space.
    pub space: u32,
    /// The register (`t5`, `s2`): the handle's index, which the operations number absolutely within the class and
    /// space. None where the index is computed (an array of resources indexed by a variable).
    pub register: Option<u32>,
    /// The range id of a `createHandle` handle (the id of the `dx.resources` record); none for a handle made from a
    /// binding, which names no record.
    pub range: Option<u32>,
}

/// One call of a texture-reading operation.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct TextureRead {
    /// The function the call is in.
    pub function: ValueId,
    /// The call's position among the function's instructions.
    pub instruction: usize,
    /// The operation's `dx.op` opcode (60 `sample`, 61 `sampleBias`, 62 `sampleLevel`, 63 `sampleGrad`, 64 `sampleCmp`,
    /// 65 `sampleCmpLevelZero`, 66 `textureLoad`, 68 `bufferLoad`, 73 `textureGather`, 74 `textureGatherCmp`,
    /// 81 `calculateLOD`, 139 `rawBufferLoad`).
    pub opcode: u16,
    /// The resource read; none where its handle is not the result of a `createHandle` or `createHandleFromBinding`
    /// call (through `annotateHandle`) of the same function, for instance a handle chosen by a `select` or `phi`, or
    /// one made from the descriptor heap.
    pub texture: Option<Handle>,
    /// The operation takes a sampler (every one but the loads).
    pub sampled: bool,
    /// The sampler, where the operation takes one and its handle is resolved as for [`TextureRead::texture`].
    pub sampler: Option<Handle>,
    /// The operation compares the sampled value with a reference (`sampleCmp`, `sampleCmpLevelZero`,
    /// `textureGatherCmp`).
    pub comparison: bool,
}

/// How an opcode reads a texture: whether it takes a sampler and whether it compares.
fn kind(opcode: i64) -> Option<(bool, bool)> {
    Some(match opcode {
        60..=63 | 73 | 81 => (true, false),
        64 | 65 | 74 => (true, true),
        66 | 68 | 139 => (false, false),
        _ => return None,
    })
}

/// A value of the module or of the function's body.
fn value<'a>(m: &'a Module, f: &'a Function, id: ValueId) -> Option<&'a Value> {
    match id.checked_sub(f.first) {
        None => m.values.get(id),
        Some(local) => f.locals.get(local),
    }
}

/// The integer a constant is. Zero is stored as the null constant of its type.
fn integer(m: &Module, f: &Function, id: ValueId) -> Option<i64> {
    match value(m, f, id)? {
        Value::Constant(Constant::Integer(i)) => Some(*i),
        Value::Constant(Constant::Null) => Some(0),
        _ => None,
    }
}

fn number(m: &Module, f: &Function, id: ValueId) -> Option<u32> {
    integer(m, f, id).and_then(|i| u32::try_from(i).ok())
}

/// The handle the value `id` is: a `createHandle` or `createHandleFromBinding` call, looked through any
/// `annotateHandle`. `spaces` maps a range's class and id to its register space.
fn handle(
    m: &Module,
    f: &Function,
    calls: &HashMap<ValueId, usize>,
    spaces: &HashMap<(u8, u32), u32>,
    id: ValueId,
) -> Option<Handle> {
    let mut id = id;
    // an annotated handle is the handle it annotates; a chain is at most a few calls long
    for _ in 0..8 {
        let Op::Call { args, .. } = &f.instructions.get(*calls.get(&id)?)?.op else {
            return None;
        };
        match integer(m, f, *args.first()?)? {
            ANNOTATE_HANDLE => id = *args.get(1)?,
            CREATE_HANDLE => {
                let class = u8::try_from(integer(m, f, *args.get(1)?)?).ok()?;
                let range = number(m, f, *args.get(2)?)?;
                return Some(Handle {
                    class,
                    space: *spaces.get(&(class, range))?,
                    register: number(m, f, *args.get(3)?),
                    range: Some(range),
                });
            }
            CREATE_HANDLE_FROM_BINDING => {
                // the binding is a constant { lower bound, upper bound, space, class }
                let Value::Constant(Constant::Aggregate(fields)) = value(m, f, *args.get(1)?)? else {
                    return None;
                };
                return Some(Handle {
                    class: u8::try_from(integer(m, f, *fields.get(3)?)?).ok()?,
                    space: number(m, f, *fields.get(2)?)?,
                    register: number(m, f, *args.get(2)?),
                    range: None,
                });
            }
            _ => return None,
        }
    }
    None
}

/// Every texture-reading call of the module's function bodies, in order. A call whose handles can't be resolved is
/// listed with `None` for them.
pub fn texture_reads(m: &Module) -> Result<Vec<TextureRead>> {
    let spaces: HashMap<(u8, u32), u32> = ranges(m)?
        .into_iter()
        .map(|(range, _, _)| ((range.class, range.id), range.space))
        .collect();
    // whether a callee is a `dx.op` function, by value id
    let mut operations: HashMap<ValueId, bool> = HashMap::new();
    let mut reads = Vec::new();
    for f in &m.functions {
        // the call that defines each instruction result
        let calls: HashMap<ValueId, usize> = f
            .instructions
            .iter()
            .enumerate()
            .filter_map(|(at, i)| i.result.map(|(id, _)| (id, at)))
            .collect();
        for (at, instruction) in f.instructions.iter().enumerate() {
            let Op::Call { function, args } = &instruction.op else {
                continue;
            };
            let is_operation = *operations
                .entry(*function)
                .or_insert_with(|| m.name(*function).is_some_and(|n| n.starts_with("dx.op.")));
            if !is_operation {
                continue;
            }
            let Some(opcode) = args.first().and_then(|a| integer(m, f, *a)) else {
                continue;
            };
            let Some((sampled, comparison)) = kind(opcode) else {
                continue;
            };
            let Ok(opcode) = u16::try_from(opcode) else {
                continue;
            };
            let resolve =
                |position: usize| args.get(position).and_then(|a| handle(m, f, &calls, &spaces, *a));
            reads.push(TextureRead {
                function: f.value,
                instruction: at,
                opcode,
                texture: resolve(1),
                sampled,
                sampler: if sampled { resolve(2) } else { None },
                comparison,
            });
        }
    }
    Ok(reads)
}

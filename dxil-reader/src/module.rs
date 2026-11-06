//! LLVM 3.7 IR as DXIL stores it, read from the bitstream tree: the type table, module values (globals, functions,
//! constants), metadata, value names and function bodies. Only what DXIL programs use is decoded; any other record in a
//! function body is refused by name. A program built with debug information (`-Zi`) keeps it as debug metadata nodes
//! ([`Metadata::Debug`], [`crate::debug_info`]), each instruction's source location ([`Instruction::debug_loc`]), a
//! body's own metadata ([`Function::metadata`]) and the metadata its debug intrinsics are passed ([`Value::Metadata`]).
//! The use-list orders of a body's values are skipped. The metadata attached to an instruction or a function is kept as
//! the pairs the file stores ([`Instruction::attachments`], [`Function::attachments`], with the kind names in
//! [`Module::kinds`]), `dx.precise` also as [`Instruction::precise`]; the attribute groups and lists are kept as stored
//! ([`Module::attribute_groups`], [`Module::attribute_lists`]) and each function value names its list.
use crate::bitstream::{Block, Record};
pub use crate::debug_info::{DebugLoc, DebugNode};
use crate::{Result, error};

const MODULE: u64 = 8;
const PARAMATTR: u64 = 9;
const PARAMATTR_GROUP: u64 = 10;
const CONSTANTS: u64 = 11;
const FUNCTION: u64 = 12;
const VALUE_SYMTAB: u64 = 14;
const METADATA: u64 = 15;
const METADATA_ATTACHMENT: u64 = 16;
const TYPES: u64 = 17;
const USELIST: u64 = 18;
const BLOCKINFO: u64 = 0;

/// Values a module may hold (globals, constants and function-body values together).
const MAX_VALUES: usize = 1 << 22;
const MAX_TYPES: usize = 1 << 16;

/// An index into [`Module::types`].
pub type TypeId = usize;
/// An index into the values: the module's [`Module::values`], then a function body's own [`Function::locals`].
pub type ValueId = usize;
/// An index into [`Module::metadata`].
pub type MetadataId = usize;

/// A type of the module's type table.
#[derive(Clone, Debug, PartialEq, Eq)]
pub enum Type {
    /// `void`.
    Void,
    /// `label`, the type of a basic block.
    Label,
    /// `metadata`.
    Metadata,
    /// `half`.
    Half,
    /// `float`.
    Float,
    /// `double`.
    Double,
    /// An integer of this many bits (1 to 64).
    Integer(u32),
    /// A pointer to the type, in this LLVM address space (the `TYPE_CODE_POINTER` record's second operand). Pointers to
    /// one type in two spaces are two types.
    Pointer(TypeId, u32),
    /// An array of this many elements of the type.
    Array(u64, TypeId),
    /// A vector of this many lanes of the type.
    Vector(u64, TypeId),
    /// A structure.
    Struct {
        /// Its name, where it has one.
        name: Option<String>,
        /// The types of its fields, in order.
        elements: Vec<TypeId>,
        /// Its fields are laid out without padding (`<{ ... }>`).
        packed: bool,
        /// A literal structure (`TYPE_CODE_STRUCT_ANON`), which is its body: two literal structures of the same fields
        /// are one type. An identified one (`TYPE_CODE_STRUCT_NAMED`) is a type of its own, named or numbered.
        literal: bool,
    },
    /// A named structure without a body.
    Opaque(Option<String>),
    /// A function type.
    Function {
        /// Whether it takes a variable argument list.
        vararg: bool,
        /// The return type.
        ret: TypeId,
        /// The parameter types.
        params: Vec<TypeId>,
    },
}

/// A module-level constant.
#[derive(Clone, Debug, PartialEq)]
pub enum Constant {
    /// The null value of the constant's type (zero).
    Null,
    /// An undefined value.
    Undef,
    /// An integer's bits, sign-extended from its width.
    Integer(i64),
    /// A float's bits (half, float or double by its type).
    Float(u64),
    /// An array, structure or vector of other constants (value ids).
    Aggregate(Vec<ValueId>),
    /// A constant array or vector of numbers, as stored (the bits of each element).
    Data(Vec<u64>),
    /// An array of `i8` given as text: its bytes, with the terminating zero a `CST_CODE_CSTRING` record implies.
    String(Vec<u8>),
    /// A constant `getelementptr`: the base (a global) and its indices (module constants).
    Gep {
        /// The base global.
        base: ValueId,
        /// The index constants.
        indices: Vec<ValueId>,
        /// The type the first index steps over: the base's pointee.
        source: TypeId,
        /// `inbounds` (`CST_CODE_CE_INBOUNDS_GEP`).
        inbounds: bool,
    },
    /// A constant cast of a module value (to the type of the constant).
    Cast {
        /// The cast.
        op: CastOp,
        /// The value cast.
        value: ValueId,
    },
    /// A constant binary operation on module values.
    Binary {
        /// The operation.
        op: BinaryOp,
        /// The left operand.
        lhs: ValueId,
        /// The right operand.
        rhs: ValueId,
        /// The record's flags, as [`Instruction::flags`].
        flags: u64,
    },
    /// A constant comparison of module values, by its LLVM predicate (as [`Op::Compare`]).
    Compare {
        /// The predicate.
        predicate: u64,
        /// The left operand.
        lhs: ValueId,
        /// The right operand.
        rhs: ValueId,
    },
}

/// How a global value links (LLVM's `LinkageTypes`, decoded from the bitcode's linkage codes).
#[derive(Clone, Copy, Debug, Default, PartialEq, Eq)]
pub enum Linkage {
    /// Visible to other modules (codes 0, 5, 6 and 15).
    #[default]
    External,
    /// Appended to the same-named array of other modules (2).
    Appending,
    /// Local to the module (3).
    Internal,
    /// Weak, kept even where unreferenced (16).
    WeakAny,
    /// Weak, every definition equivalent (17).
    WeakOdr,
    /// Merged with other definitions, dropped where unreferenced (18).
    LinkOnceAny,
    /// As `LinkOnceAny`, every definition equivalent (19).
    LinkOnceOdr,
    /// A weak reference to an external symbol (7).
    ExternWeak,
    /// A tentative definition (8).
    Common,
    /// Local to the module and left out of its symbol table (9, 13 and 14).
    Private,
    /// Defined elsewhere, given here for optimisation (12).
    AvailableExternally,
}

/// What the module states of a function or a global variable beyond its type: how it links, and the other properties
/// of its `MODULE_CODE_FUNCTION` or `MODULE_CODE_GLOBALVAR` record.
#[derive(Clone, Debug, Default, PartialEq, Eq)]
pub struct GlobalProperties {
    /// How it links.
    pub linkage: Linkage,
    /// Its visibility: 0 default, 1 hidden, 2 protected.
    pub visibility: u8,
    /// Its DLL storage class: 0 default, 1 `dllimport`, 2 `dllexport`.
    pub dll_storage: u8,
    /// Its address is not significant (`unnamed_addr`).
    pub unnamed_addr: bool,
    /// The section it is placed in, where the record names one.
    pub section: Option<String>,
    /// Its alignment in bytes; 0 where it states none.
    pub alignment: u64,
}

/// A value the module numbers.
#[derive(Clone, Debug, PartialEq)]
pub enum Value {
    /// A function, defined or declared.
    Function {
        /// Its function type.
        ty: TypeId,
        /// Whether it is only declared (it has no body).
        declaration: bool,
        /// The attribute list it names (an index into [`Module::attribute_lists`]), where it names one.
        attributes: Option<usize>,
        /// Its linkage and the other properties of its record.
        properties: GlobalProperties,
        /// Its calling convention (LLVM's `CallingConv::ID`; 0 is C's).
        calling_conv: u64,
        /// The garbage collector it names, where it names one.
        gc: Option<String>,
    },
    /// A global variable.
    Global {
        /// The global's type: a pointer to `value_ty`.
        ty: TypeId,
        /// The type of the value it holds.
        value_ty: TypeId,
        /// Its initial value (a module constant), if it has one.
        init: Option<ValueId>,
        /// Whether it is a constant (read only).
        constant: bool,
        /// LLVM's address space: 0 the default, 3 group shared. No other space occurs in the programs of the games read.
        address_space: u32,
        /// Its linkage and the other properties of its record.
        properties: GlobalProperties,
        /// Its thread-local model: 0 none, 1 general dynamic, 2 local dynamic, 3 initial exec, 4 local exec.
        thread_local: u8,
        /// Its initial value may be set outside the module (`externally_initialized`).
        externally_initialized: bool,
    },
    /// A constant.
    Constant(Constant),
    /// A function argument or an instruction's result.
    Local,
    /// Metadata a call passes to a parameter of type `metadata` (LLVM's `MetadataAsValue`: the debug intrinsics'
    /// variables, expressions and the values they describe). These are a function body's own, after its other values:
    /// they have no place in the bitcode's value numbering.
    Metadata(MetadataId),
}

/// A metadata record.
#[derive(Clone, Debug, PartialEq)]
pub enum Metadata {
    /// A metadata string, as stored (not checked to be UTF-8 here).
    String(Vec<u8>),
    /// A value as metadata.
    Value {
        /// The value's type.
        ty: TypeId,
        /// The value.
        value: ValueId,
    },
    /// Operands; `None` is a null operand.
    Node(Vec<Option<MetadataId>>),
    /// A node of its own, never merged with a node of the same operands (`METADATA_DISTINCT_NODE`: the loop
    /// identifiers `llvm.loop` names, whose first operand is the node itself).
    Distinct(Vec<Option<MetadataId>>),
    /// A debug-information node (a program built with `-Zi`), and whether it is distinct.
    Debug {
        /// The node is distinct (never merged with one of the same fields).
        distinct: bool,
        /// The node.
        node: DebugNode,
    },
}

impl Metadata {
    /// The operands of a node of generic operands, distinct or not; `None` for a string, a value or a debug node (whose
    /// operands [`DebugNode::operands`] gives).
    pub fn operands(&self) -> Option<&[Option<MetadataId>]> {
        match self {
            Metadata::Node(ops) | Metadata::Distinct(ops) => Some(ops),
            Metadata::String(_) | Metadata::Value { .. } | Metadata::Debug { .. } => None,
        }
    }
}

/// A binary operator code (LLVM's `BinaryOpcodes`).
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum BinaryOp {
    /// Addition.
    Add,
    /// Subtraction.
    Sub,
    /// Multiplication.
    Mul,
    /// Unsigned division.
    UDiv,
    /// Signed division.
    SDiv,
    /// Unsigned remainder.
    URem,
    /// Signed remainder.
    SRem,
    /// Shift left.
    Shl,
    /// Logical shift right.
    LShr,
    /// Arithmetic shift right.
    AShr,
    /// Bitwise and.
    And,
    /// Bitwise or.
    Or,
    /// Bitwise exclusive or.
    Xor,
}
/// A cast opcode (LLVM's `CastOpcodes`).
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum CastOp {
    /// Truncate an integer.
    Trunc,
    /// Zero-extend an integer.
    ZExt,
    /// Sign-extend an integer.
    SExt,
    /// Float to unsigned integer.
    FpToUi,
    /// Float to signed integer.
    FpToSi,
    /// Unsigned integer to float.
    UiToFp,
    /// Signed integer to float.
    SiToFp,
    /// Truncate a float.
    FpTrunc,
    /// Extend a float.
    FpExt,
    /// Pointer to integer.
    PtrToInt,
    /// Integer to pointer.
    IntToPtr,
    /// Reinterpret the bits as another type.
    BitCast,
    /// A pointer into another address space.
    AddrSpaceCast,
}

/// An instruction, with the value ids (absolute) and block numbers it names.
#[derive(Clone, Debug, PartialEq)]
pub enum Op {
    /// Integer opcodes apply to integers; for floating types Add, Sub, Mul, (S)Div, (S)Rem are the float forms.
    Binary {
        /// The operation.
        op: BinaryOp,
        /// The left operand.
        lhs: ValueId,
        /// The right operand.
        rhs: ValueId,
    },
    /// A conversion.
    Cast {
        /// The conversion.
        op: CastOp,
        /// The value converted; the instruction's result type is the target.
        value: ValueId,
    },
    /// A comparison by its LLVM predicate (0..15 float, 32..41 integer).
    Compare {
        /// The predicate.
        predicate: u64,
        /// The left operand.
        lhs: ValueId,
        /// The right operand.
        rhs: ValueId,
    },
    /// `select`: one of two values by a condition.
    Select {
        /// The condition (an `i1`).
        condition: ValueId,
        /// The value when the condition is true.
        then: ValueId,
        /// The value when it is false.
        otherwise: ValueId,
    },
    /// A field or element of an aggregate.
    ExtractValue {
        /// The aggregate.
        aggregate: ValueId,
        /// The indices into it, outermost first.
        indices: Vec<u64>,
    },
    /// An aggregate with one field or element replaced.
    InsertValue {
        /// The aggregate.
        aggregate: ValueId,
        /// The new field or element.
        value: ValueId,
        /// The indices of the replaced one, outermost first.
        indices: Vec<u64>,
    },
    /// One lane of a vector.
    ExtractElement {
        /// The vector.
        vector: ValueId,
        /// The lane number.
        index: ValueId,
    },
    /// A vector with one lane replaced.
    InsertElement {
        /// The vector.
        vector: ValueId,
        /// The new lane.
        value: ValueId,
        /// The lane number.
        index: ValueId,
    },
    /// The lanes of two vectors the mask (a constant vector of lane numbers) picks.
    ShuffleVector {
        /// The first vector.
        first: ValueId,
        /// The second vector.
        second: ValueId,
        /// The constant vector of lane numbers.
        mask: ValueId,
    },
    /// A call.
    Call {
        /// The callee.
        function: ValueId,
        /// The arguments, one per parameter.
        args: Vec<ValueId>,
        /// The attribute list of the call site (an index into [`Module::attribute_lists`]), where it names one.
        attributes: Option<usize>,
        /// The calling convention (0 is C's).
        calling_conv: u64,
        /// Whether it is marked a tail call.
        tail: TailCall,
    },
    /// The value from the predecessor block control came from: (value, block) pairs.
    Phi {
        /// The (value, predecessor block) pairs.
        incoming: Vec<(ValueId, usize)>,
    },
    /// `ret`, with the value returned where there is one.
    Return(Option<ValueId>),
    /// An unconditional branch.
    Branch {
        /// The block branched to.
        target: usize,
    },
    /// A conditional branch.
    CondBranch {
        /// The condition (an `i1`).
        condition: ValueId,
        /// The block when it is true.
        then: usize,
        /// The block when it is false.
        otherwise: usize,
    },
    /// A multi-way branch: the value, the default block and the (case constant, block) pairs.
    Switch {
        /// The value switched on.
        value: ValueId,
        /// The block when no case matches.
        default: usize,
        /// The (case constant, block) pairs.
        cases: Vec<(ValueId, usize)>,
    },
    /// `unreachable`.
    Unreachable,
    /// A local variable of this type (the result is a pointer to it).
    Alloca {
        /// The type of the variable.
        ty: TypeId,
        /// The number of variables (an integer value; the compilers write the constant `i32 1`).
        size: ValueId,
        /// The alignment in bytes; 0 where the record states none.
        align: u64,
        /// The variable is an argument passed in memory (`inalloca`).
        inalloca: bool,
    },
    /// A load.
    Load {
        /// The pointer loaded from; the result type is the loaded type.
        pointer: ValueId,
        /// The alignment in bytes; 0 where the record states none.
        align: u64,
        /// `volatile`.
        volatile: bool,
        /// The ordering of an atomic load (`FUNC_CODE_INST_LOADATOMIC`).
        atomic: Option<Atomic>,
    },
    /// A store.
    Store {
        /// The pointer stored to.
        pointer: ValueId,
        /// The value stored.
        value: ValueId,
        /// The alignment in bytes; 0 where the record states none.
        align: u64,
        /// `volatile`.
        volatile: bool,
        /// The ordering of an atomic store (`FUNC_CODE_INST_STOREATOMIC`).
        atomic: Option<Atomic>,
    },
    /// `getelementptr`: the base pointer and its indices (the first steps over the pointer itself).
    Gep {
        /// The base pointer.
        base: ValueId,
        /// The indices.
        indices: Vec<ValueId>,
        /// The type the first index steps over: the base's pointee, which the record states.
        source: TypeId,
        /// `inbounds`.
        inbounds: bool,
    },
    /// `atomicrmw`: the operation (LLVM's code: 0 xchg, 1 add, 2 sub, 3 and, 4 nand, 5 or, 6 xor, 7 max, 8 min, 9 umax,
    /// 10 umin); the result is the value the pointer held.
    AtomicRmw {
        /// The pointer.
        pointer: ValueId,
        /// The value operated with.
        value: ValueId,
        /// The operation code.
        op: u64,
        /// `volatile`.
        volatile: bool,
        /// Its ordering.
        atomic: Atomic,
    },
    /// `cmpxchg`: the result is the pair (the value the pointer held, whether it was swapped).
    CmpXchg {
        /// The pointer.
        pointer: ValueId,
        /// The value compared with.
        compare: ValueId,
        /// The new value stored where the comparison holds.
        value: ValueId,
        /// `volatile`.
        volatile: bool,
        /// `weak`: it may fail even where the comparison holds.
        weak: bool,
        /// The ordering where it swaps, and the scope of both.
        success: Atomic,
        /// The ordering where it does not.
        failure: Ordering,
    },
    /// `fence`: ordering between invocations, which a lockstep reading does not have.
    Fence(Atomic),
}

/// The ordering of an atomic operation (LLVM's `AtomicOrdering`, by its bitcode code 0 to 6).
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum Ordering {
    /// Not atomic (0).
    NotAtomic,
    /// `unordered` (1).
    Unordered,
    /// `monotonic` (2).
    Monotonic,
    /// `acquire` (3).
    Acquire,
    /// `release` (4).
    Release,
    /// `acq_rel` (5).
    AcquireRelease,
    /// `seq_cst` (6).
    SequentiallyConsistent,
}

/// The ordering of an atomic operation and the invocations it orders against.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub struct Atomic {
    /// The ordering.
    pub ordering: Ordering,
    /// Only against the invocation itself (`singlethread`); otherwise against all.
    pub single_thread: bool,
}

/// Whether a call is marked a tail call.
#[derive(Clone, Copy, Debug, Default, PartialEq, Eq)]
pub enum TailCall {
    /// Not marked.
    #[default]
    None,
    /// `tail`.
    Tail,
    /// `musttail`.
    MustTail,
}

impl Op {
    /// The values the operation reads (a call's arguments, not its callee; a phi's incoming values).
    pub fn operands(&self) -> Vec<ValueId> {
        match self {
            Op::Binary { lhs, rhs, .. } | Op::Compare { lhs, rhs, .. } => vec![*lhs, *rhs],
            Op::Cast { value, .. } => vec![*value],
            Op::Select {
                condition,
                then,
                otherwise,
            } => vec![*condition, *then, *otherwise],
            Op::ExtractValue { aggregate, .. } => vec![*aggregate],
            Op::InsertValue { aggregate, value, .. } => vec![*aggregate, *value],
            Op::ExtractElement { vector, index } => vec![*vector, *index],
            Op::InsertElement { vector, value, index } => vec![*vector, *value, *index],
            Op::ShuffleVector { first, second, mask } => vec![*first, *second, *mask],
            Op::Call { args, .. } => args.clone(),
            Op::Phi { incoming } => incoming.iter().map(|(v, _)| *v).collect(),
            Op::Return(value) => value.iter().copied().collect(),
            Op::CondBranch { condition, .. } => vec![*condition],
            Op::Switch { value, cases, .. } => std::iter::once(*value)
                .chain(cases.iter().map(|(c, _)| *c))
                .collect(),
            Op::Load { pointer, .. } => vec![*pointer],
            Op::Store { pointer, value, .. } | Op::AtomicRmw { pointer, value, .. } => vec![*pointer, *value],
            Op::Gep { base, indices, .. } => std::iter::once(*base).chain(indices.iter().copied()).collect(),
            Op::CmpXchg {
                pointer,
                compare,
                value,
                ..
            } => vec![*pointer, *compare, *value],
            Op::Alloca { size, .. } => vec![*size],
            Op::Branch { .. } | Op::Unreachable | Op::Fence(_) => Vec::new(),
        }
    }

    /// The basic blocks the operation names (a branch's targets, a phi's predecessors).
    pub fn blocks(&self) -> Vec<usize> {
        match self {
            Op::Branch { target } => vec![*target],
            Op::CondBranch { then, otherwise, .. } => vec![*then, *otherwise],
            Op::Switch { default, cases, .. } => std::iter::once(*default)
                .chain(cases.iter().map(|(_, b)| *b))
                .collect(),
            Op::Phi { incoming } => incoming.iter().map(|(_, b)| *b).collect(),
            _ => Vec::new(),
        }
    }
}

/// An instruction of a function body.
#[derive(Clone, Debug, PartialEq)]
pub struct Instruction {
    /// What it does.
    pub op: Op,
    /// The result's value id and type, when the instruction produces one.
    pub result: Option<(ValueId, TypeId)>,
    /// The basic block it belongs to.
    pub block: usize,
    /// Bit offset of its record.
    pub at: usize,
    /// The optimisation flags its record states (0 for none): for an integer `add`, `sub`, `mul` or `shl` bit 0 is
    /// `nuw` and bit 1 `nsw`; for `udiv`, `sdiv`, `lshr` and `ashr` bit 0 is `exact`; for a float operation or
    /// comparison they are the fast-math flags (bit 0 `fast`, then `nnan`, `ninf`, `nsz` and `arcp`).
    pub flags: u64,
    /// The instruction carries the `dx.precise` attachment, which the compiler writes for HLSL's `precise`: the value
    /// is not to be fused or reassociated. In skate.'s stock programs it is on calls only: 88,541 `tertiary` (mad),
    /// 13,005 `loadInput`, 3,546 `unary`, 1,421 `dot3`, 331 `legacyF16ToF32`, 307 `binary`, 213 `dot4` and 105 `dot2`,
    /// in vertex programs (107,109 instructions in 3,185 of 3,341) and compute programs (360 in 12), in no pixel
    /// program; none of Elden Ring's has it.
    pub precise: bool,
    /// The metadata attached to the instruction, in the order the file stores the pairs (`dx.precise` among them).
    pub attachments: Vec<Attachment>,
    /// The instruction's source location, in a program with debug information.
    pub debug_loc: Option<DebugLoc>,
}

/// A metadata node attached to an instruction or a function: the kind (the id [`Module::kinds`] names) and the node.
/// In the games' programs the kinds are `dx.controlflow.hints`, `llvm.loop`, `tbaa`, `noalias`, `alias.scope`, `range`
/// and `dx.precise`.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub struct Attachment {
    /// The metadata kind id (`dx.precise`, `tbaa`, ... by [`Module::kind_name`]).
    pub kind: u64,
    /// The attached node, an id into [`Module::metadata`].
    pub node: MetadataId,
}

/// An attribute of an attribute group, as the bitcode stores it.
#[derive(Clone, Debug, PartialEq, Eq)]
pub enum Attribute {
    /// A flag attribute, by LLVM's bitcode kind number (see [`attribute_name`]).
    Enum(u64),
    /// An attribute with an integer value: its kind number and the value.
    Integer(u64, u64),
    /// A string attribute: the key and the value (empty where the attribute has none).
    String(String, String),
}

/// A group of attributes, which an attribute list names by its id.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct AttributeGroup {
    /// The group's id, as the lists name it.
    pub id: u64,
    /// The slot the attributes apply to: [`FUNCTION_SLOT`] the function itself, 0 its result, 1 and up its parameters.
    pub slot: u64,
    /// The attributes, in the order stored.
    pub attributes: Vec<Attribute>,
}

/// The slot of an [`AttributeGroup`] that holds a function's own attributes (`0xFFFFFFFF`).
pub const FUNCTION_SLOT: u64 = 0xFFFF_FFFF;

/// The name of an LLVM 3.7 enum attribute's bitcode kind number (`nounwind` for 18), for the kinds whose number dxc's own
/// listing confirms: 9 `noalias`, 11 `nocapture`, 12 `noduplicate`, 17 `noreturn`, 18 `nounwind`, 20 `readnone`, 21
/// `readonly`, 39 `nonnull`. They are the kinds the games' programs and the test compilations use.
pub fn attribute_name(kind: u64) -> Option<&'static str> {
    Some(match kind {
        9 => "noalias",
        11 => "nocapture",
        12 => "noduplicate",
        17 => "noreturn",
        18 => "nounwind",
        20 => "readnone",
        21 => "readonly",
        39 => "nonnull",
        _ => return None,
    })
}

/// A function body.
#[derive(Clone, Debug, PartialEq)]
pub struct Function {
    /// The function's module value id.
    pub value: ValueId,
    /// The number of basic blocks.
    pub blocks: usize,
    /// The instructions of all blocks, in order.
    pub instructions: Vec<Instruction>,
    /// The body's own values (arguments, constants, instruction results) and their types; their ids start at
    /// `first`, after the module's values.
    pub first: ValueId,
    /// The values of the body.
    pub locals: Vec<Value>,
    /// The types of [`Function::locals`].
    pub local_types: Vec<TypeId>,
    /// The metadata attached to the function itself (the attachment records of the body that name no instruction).
    pub attachments: Vec<Attachment>,
    /// The body's own metadata (in a program with debug information, the values its debug intrinsics describe, each a
    /// [`Metadata::Value`] of one of its values): their ids continue the module's, from `first_metadata`.
    pub metadata: Vec<Metadata>,
    /// The id of the body's first own metadata: the module's metadata count.
    pub first_metadata: MetadataId,
    /// The body's symbol table: the names of its values (arguments and instruction results, by absolute id).
    pub names: Vec<(ValueId, String)>,
    /// The names of its basic blocks that have one.
    pub block_names: Vec<(usize, String)>,
    /// The use-list orders of its basic blocks (`USELIST_CODE_BB`): each block and the position its uses take, in the
    /// order LLVM would otherwise keep them (the most recent first). They are the order of its predecessors.
    pub block_use_orders: Vec<(usize, Vec<u64>)>,
}

impl Function {
    /// The body's name for one of its values, where its symbol table has one.
    pub fn name(&self, value: ValueId) -> Option<&str> {
        self.names
            .iter()
            .find(|(v, _)| *v == value)
            .map(|(_, n)| n.as_str())
    }
    /// The name of a basic block, where it has one.
    pub fn block_name(&self, block: usize) -> Option<&str> {
        self.block_names
            .iter()
            .find(|(b, _)| *b == block)
            .map(|(_, n)| n.as_str())
    }
}

/// A module: its types, values, metadata and function bodies.
#[derive(Clone, Debug, Default, PartialEq)]
pub struct Module {
    /// The type table.
    pub types: Vec<Type>,
    /// The module's values by id (globals, functions, module constants); a function body's own values continue the
    /// numbering in its [`Function`].
    pub values: Vec<Value>,
    /// Each value's type.
    pub value_types: Vec<TypeId>,
    /// The module's symbol table: the names of the module values that have one (a function body's own are in its
    /// [`Function::names`]).
    pub names: Vec<(ValueId, String)>,
    /// The target triple (`dxil-ms-dx`), where the module states one.
    pub triple: Option<String>,
    /// The data layout, where the module states one.
    pub datalayout: Option<String>,
    /// The module's inline assembly, where it has any.
    pub asm: Option<String>,
    /// The metadata records, by [`MetadataId`].
    pub metadata: Vec<Metadata>,
    /// The bit of the bitcode each metadata record (by id) starts at, for the locations of reflection errors.
    pub metadata_at: Vec<usize>,
    /// The named metadata (`dx.entryPoints`, ...): the name and the records it lists.
    pub named_metadata: Vec<(String, Vec<MetadataId>)>,
    /// The bit each named metadata record (by index in `named_metadata`) starts at.
    pub named_metadata_at: Vec<usize>,
    /// The bit of the bitcode the module block starts at: where a record the module lacks would be.
    pub at: usize,
    /// The function bodies, in the order of their definitions.
    pub functions: Vec<Function>,
    /// The id of the module's `dx.precise` metadata kind (the kind [`Instruction::precise`] reads), where it names one.
    pub precise_kind: Option<u64>,
    /// The module's metadata kinds: each id and its name, in the order stored.
    pub kinds: Vec<(u64, String)>,
    /// The attribute groups, in the order stored.
    pub attribute_groups: Vec<AttributeGroup>,
    /// The attribute lists, in the order stored: the ids of the groups each lists. A function value's `attributes` is an
    /// index into this.
    pub attribute_lists: Vec<Vec<u64>>,
}

fn op(r: &Record, i: usize) -> Result<u64> {
    r.operands
        .get(i)
        .copied()
        .ok_or_else(|| error(r.at, format!("record {} lacks operand {i}", r.code)))
}
fn text(ops: &[u64], at: usize) -> Result<Vec<u8>> {
    ops.iter()
        .map(|&c| u8::try_from(c).map_err(|_| error(at, "character above 255")))
        .collect()
}
/// The zero-terminated string starting at operand `from` of an attribute record, and the index after its terminator.
fn c_string(r: &Record, from: usize) -> Result<(String, usize)> {
    let rest = r.operands.get(from..).unwrap_or_default();
    let n = rest
        .iter()
        .position(|&c| c == 0)
        .ok_or_else(|| error(r.at, "an attribute string without its terminator"))?;
    let bytes = text(rest.get(..n).unwrap_or_default(), r.at)?;
    Ok((
        String::from_utf8_lossy(&bytes).into_owned(),
        from.saturating_add(n).saturating_add(1),
    ))
}
fn utf8(bytes: Vec<u8>, at: usize) -> Result<String> {
    String::from_utf8(bytes).map_err(|_| error(at, "name is not UTF-8"))
}
fn signed_vbr(v: u64) -> i64 {
    if v & 1 == 0 {
        i64::try_from(v >> 1).unwrap_or(i64::MAX)
    } else if v == 1 {
        i64::MIN
    } else {
        i64::try_from(v >> 1).map_or(i64::MIN, i64::wrapping_neg)
    }
}

impl Module {
    fn ty(&self, id: u64, at: usize) -> Result<TypeId> {
        let id = usize::try_from(id).map_err(|_| error(at, "type id"))?;
        if id < self.types.len() {
            Ok(id)
        } else {
            Err(error(at, format!("type {id} undefined")))
        }
    }
    /// The type `id`, which an earlier record has already checked against the table (an error where it has not).
    fn type_at(&self, id: TypeId, at: usize) -> Result<&Type> {
        self.types
            .get(id)
            .ok_or_else(|| error(at, format!("type {id} of {} types", self.types.len())))
    }
    /// The id of the type `ty`, appended to the table where it is not there yet.
    fn intern(&mut self, ty: Type) -> TypeId {
        match self.types.iter().position(|x| *x == ty) {
            Some(p) => p,
            None => {
                self.types.push(ty);
                self.types.len().saturating_sub(1)
            }
        }
    }
    /// The module's name for a value, where its symbol table has one.
    pub fn name(&self, value: ValueId) -> Option<&str> {
        self.names
            .iter()
            .find(|(v, _)| *v == value)
            .map(|(_, n)| n.as_str())
    }
    fn push(&mut self, value: Value, ty: TypeId, at: usize) -> Result<ValueId> {
        if self.values.len() >= MAX_VALUES {
            return Err(error(at, "too many values"));
        }
        self.values.push(value);
        self.value_types.push(ty);
        Ok(self.values.len().saturating_sub(1))
    }

    fn read_types(&mut self, block: &Block) -> Result<()> {
        let mut struct_name: Option<String> = None;
        for r in block.records() {
            if self.types.len() >= MAX_TYPES {
                return Err(error(r.at, "too many types"));
            }
            let t = match r.code {
                1 => continue, // NUMENTRY
                2 => Type::Void,
                3 => Type::Float,
                4 => Type::Double,
                5 => Type::Label,
                6 => Type::Opaque(struct_name.take()),
                7 => Type::Integer(
                    u32::try_from(op(r, 0)?)
                        .ok()
                        .filter(|w| (1..=64).contains(w))
                        .ok_or_else(|| error(r.at, "integer width"))?,
                ),
                8 => Type::Pointer(
                    self.ty(op(r, 0)?, r.at)?,
                    u32::try_from(op(r, 1)?).map_err(|_| error(r.at, "pointer address space"))?,
                ),
                10 => Type::Half,
                11 => Type::Array(op(r, 0)?, self.ty(op(r, 1)?, r.at)?),
                12 => Type::Vector(op(r, 0)?, self.ty(op(r, 1)?, r.at)?),
                16 => Type::Metadata,
                // STRUCT_ANON and STRUCT_NAMED: [packed, element types...]
                18 | 20 => Type::Struct {
                    name: if r.code == 20 { struct_name.take() } else { None },
                    packed: op(r, 0)? != 0,
                    literal: r.code == 18,
                    elements: r
                        .operands
                        .get(1..)
                        .unwrap_or_default()
                        .iter()
                        .map(|&t| self.ty(t, r.at))
                        .collect::<Result<_>>()?,
                },
                19 => {
                    struct_name = Some(utf8(text(&r.operands, r.at)?, r.at)?);
                    continue;
                }
                21 => Type::Function {
                    vararg: op(r, 0)? != 0,
                    ret: self.ty(op(r, 1)?, r.at)?,
                    params: r
                        .operands
                        .get(2..)
                        .unwrap_or_default()
                        .iter()
                        .map(|&t| self.ty(t, r.at))
                        .collect::<Result<_>>()?,
                },
                other => return Err(error(r.at, format!("type record {other}"))),
            };
            self.types.push(t);
        }
        Ok(())
    }

    /// Read a constants block, appending its values. Value ids inside aggregates are absolute.
    fn read_constants(&mut self, block: &Block) -> Result<()> {
        let mut ty: Option<TypeId> = None;
        for r in block.records() {
            let id = |v: u64| usize::try_from(v).map_err(|_| error(r.at, "value id"));
            if r.code == 1 {
                ty = Some(self.ty(op(r, 0)?, r.at)?);
                continue;
            }
            let t = ty.ok_or_else(|| error(r.at, "constant before SETTYPE"))?;
            let c = match r.code {
                2 => Constant::Null,
                3 => Constant::Undef,
                4 => Constant::Integer(signed_vbr(op(r, 0)?)),
                6 => Constant::Float(op(r, 0)?),
                7 => Constant::Aggregate(
                    r.operands
                        .iter()
                        .map(|&v| usize::try_from(v).map_err(|_| error(r.at, "value id")))
                        .collect::<Result<_>>()?,
                ),
                // STRING and CSTRING, whose terminating zero is not stored
                8 => Constant::String(text(&r.operands, r.at)?),
                9 => {
                    let mut bytes = text(&r.operands, r.at)?;
                    bytes.push(0);
                    Constant::String(bytes)
                }
                22 => Constant::Data(r.operands.clone()),
                // CE_GEP and CE_INBOUNDS_GEP: [source type,] then (type, value) pairs, the first the base
                12 | 20 => {
                    let explicit = r.operands.len() % 2 == 1;
                    let ops = r.operands.get(usize::from(explicit)..).unwrap_or_default();
                    let (pairs, rest) = ops.as_chunks::<2>();
                    let ([base_ty, base], true) = (
                        pairs.first().unwrap_or(&[0, 0]),
                        rest.is_empty() && !pairs.is_empty(),
                    ) else {
                        return Err(error(r.at, "constant getelementptr operands"));
                    };
                    let source = if explicit {
                        self.ty(op(r, 0)?, r.at)?
                    } else {
                        match self.type_at(self.ty(*base_ty, r.at)?, r.at)? {
                            Type::Pointer(pointee, _) => *pointee,
                            _ => {
                                return Err(error(
                                    r.at,
                                    "a constant getelementptr of a value that is not a pointer",
                                ));
                            }
                        }
                    };
                    Constant::Gep {
                        base: id(*base)?,
                        indices: pairs
                            .iter()
                            .skip(1)
                            .map(|[_, index]| id(*index))
                            .collect::<Result<_>>()?,
                        source,
                        inbounds: r.code == 20,
                    }
                }
                // CE_BINOP: [opcode, lhs, rhs, flags?]
                10 => Constant::Binary {
                    op: binary(op(r, 0)?, r.at)?,
                    lhs: id(op(r, 1)?)?,
                    rhs: id(op(r, 2)?)?,
                    flags: r.operands.get(3).copied().unwrap_or(0),
                },
                // CE_CMP: [operand type, lhs, rhs, predicate]
                17 => Constant::Compare {
                    lhs: id(op(r, 1)?)?,
                    rhs: id(op(r, 2)?)?,
                    predicate: op(r, 3)?,
                },
                // CE_CAST: [opcode, operand type, operand]
                11 => Constant::Cast {
                    op: cast(op(r, 0)?, r.at)?,
                    value: id(op(r, 2)?)?,
                },
                other => {
                    return Err(error(
                        r.at,
                        format!(
                            "constant record {other} ({} is not supported)",
                            constant_record(other)
                        ),
                    ));
                }
            };
            self.push(Value::Constant(c), t, r.at)?;
        }
        Ok(())
    }

    fn read_metadata(&mut self, block: &Block) -> Result<()> {
        let mut name: Option<String> = None;
        let md = |v: u64, at: usize| usize::try_from(v).map_err(|_| error(at, "metadata id"));
        for r in block.records() {
            match r.code {
                1 => {
                    self.metadata.push(Metadata::String(text(&r.operands, r.at)?));
                    self.metadata_at.push(r.at);
                }
                2 => {
                    self.metadata.push(Metadata::Value {
                        ty: self.ty(op(r, 0)?, r.at)?,
                        value: md(op(r, 1)?, r.at)?,
                    });
                    self.metadata_at.push(r.at);
                }
                // NODE and DISTINCT_NODE: [metadata id + 1, or 0 for null...]
                3 | 5 => {
                    let ops = r
                        .operands
                        .iter()
                        .map(|&v| {
                            if v == 0 {
                                Ok(None)
                            } else {
                                md(v.saturating_sub(1), r.at).map(Some)
                            }
                        })
                        .collect::<Result<_>>()?;
                    self.metadata.push(if r.code == 3 {
                        Metadata::Node(ops)
                    } else {
                        Metadata::Distinct(ops)
                    });
                    self.metadata_at.push(r.at);
                }
                4 => name = Some(utf8(text(&r.operands, r.at)?, r.at)?),
                10 => {
                    let n = name
                        .take()
                        .ok_or_else(|| error(r.at, "named node without a name"))?;
                    let nodes = r.operands.iter().map(|&v| md(v, r.at)).collect::<Result<_>>()?;
                    self.named_metadata.push((n, nodes));
                    self.named_metadata_at.push(r.at);
                }
                6 => {
                    // KIND: [kind id, name]
                    let id = op(r, 0)?;
                    let bytes = text(r.operands.get(1..).unwrap_or_default(), r.at)?;
                    if bytes == b"dx.precise" {
                        self.precise_kind = Some(id);
                    }
                    self.kinds
                        .push((id, String::from_utf8_lossy(&bytes).into_owned()));
                }
                7 | 12..=32 => {
                    let code = u32::try_from(r.code).unwrap_or(u32::MAX);
                    let (distinct, node) = crate::debug_info::read(code, &r.operands, r.at)?;
                    self.metadata.push(Metadata::Debug { distinct, node });
                    self.metadata_at.push(r.at);
                }
                other => return Err(error(r.at, format!("metadata record {other}"))),
            }
        }
        Ok(())
    }

    /// The attribute groups: records `[group id, slot, attribute...]`, an attribute being `[0, kind]` (a flag), `[1, kind,
    /// value]`, `[3, key..., 0]` or `[4, key..., 0, value..., 0]`.
    fn read_attribute_groups(&mut self, block: &Block) -> Result<()> {
        for r in block.records().filter(|r| r.code == 3) {
            let mut attributes = Vec::new();
            let mut i = 2;
            while i < r.operands.len() {
                match op(r, i)? {
                    0 => {
                        attributes.push(Attribute::Enum(op(r, i.saturating_add(1))?));
                        i = i.saturating_add(2);
                    }
                    1 => {
                        attributes.push(Attribute::Integer(
                            op(r, i.saturating_add(1))?,
                            op(r, i.saturating_add(2))?,
                        ));
                        i = i.saturating_add(3);
                    }
                    form @ (3 | 4) => {
                        let (key, next) = c_string(r, i.saturating_add(1))?;
                        let (value, next) = if form == 4 {
                            c_string(r, next)?
                        } else {
                            (String::new(), next)
                        };
                        attributes.push(Attribute::String(key, value));
                        i = next;
                    }
                    other => return Err(error(r.at, format!("attribute encoding {other}"))),
                }
            }
            self.attribute_groups.push(AttributeGroup {
                id: op(r, 0)?,
                slot: op(r, 1)?,
                attributes,
            });
        }
        Ok(())
    }

    /// The attribute lists: records `[group id...]`.
    fn read_attribute_lists(&mut self, block: &Block) {
        for r in block.records().filter(|r| r.code == 2) {
            self.attribute_lists.push(r.operands.clone());
        }
    }

    /// The name of a metadata kind id, where the module names it.
    pub fn kind_name(&self, kind: u64) -> Option<&str> {
        self.kinds
            .iter()
            .find(|(k, _)| *k == kind)
            .map(|(_, n)| n.as_str())
    }

    /// The node of the attachment among `attachments` whose kind is called `name`.
    pub fn attachment(&self, attachments: &[Attachment], name: &str) -> Option<MetadataId> {
        attachments
            .iter()
            .find(|a| self.kind_name(a.kind) == Some(name))
            .map(|a| a.node)
    }

    /// The attributes a function value carries on itself (the groups of its list whose slot is [`FUNCTION_SLOT`]); none
    /// for a value that is not a function or names no list.
    pub fn function_attributes(&self, function: ValueId) -> Vec<&Attribute> {
        let Some(Value::Function {
            attributes: Some(list),
            ..
        }) = self.values.get(function)
        else {
            return Vec::new();
        };
        let Some(groups) = self.attribute_lists.get(*list) else {
            return Vec::new();
        };
        groups
            .iter()
            .filter_map(|id| {
                self.attribute_groups
                    .iter()
                    .find(|g| g.id == *id && g.slot == FUNCTION_SLOT)
            })
            .flat_map(|g| g.attributes.iter())
            .collect()
    }

    /// The value of the string attribute `key` on a function (empty where the attribute has no value), if it carries it.
    pub fn string_attribute(&self, function: ValueId, key: &str) -> Option<&str> {
        self.function_attributes(function)
            .into_iter()
            .find_map(|a| match a {
                Attribute::String(k, v) if k == key => Some(v.as_str()),
                _ => None,
            })
    }
}

/// A symbol table's names: of values `[value id, name...]` (`VST_ENTRY`, and `VST_FNENTRY` with an offset before the
/// name) and of basic blocks `[block, name...]` (`VST_BBENTRY`).
type Symbols = (Vec<(ValueId, String)>, Vec<(usize, String)>);

fn read_symbols(block: &Block) -> Result<Symbols> {
    let (mut values, mut blocks) = (Vec::new(), Vec::new());
    for r in block.records() {
        let id = usize::try_from(op(r, 0)?).map_err(|_| error(r.at, "value id"))?;
        let skip = if r.code == 3 { 2 } else { 1 };
        let name = utf8(text(r.operands.get(skip..).unwrap_or_default(), r.at)?, r.at)?;
        match r.code {
            1 | 3 => values.push((id, name)),
            2 => blocks.push((id, name)),
            other => return Err(error(r.at, format!("symbol record {other}"))),
        }
    }
    Ok((values, blocks))
}

/// Function-body decoding state: relative value numbering (module version 1).
struct Body<'m> {
    m: &'m mut Module,
    block: usize,
    blocks: usize,
}
impl Body<'_> {
    fn next(&self) -> usize {
        self.m.values.len()
    }
    /// A relative operand (absolute = next - operand), with its explicit type following when it is a forward
    /// reference (a value defined later in the function's layout). Returns the value id and its type, and advances `i`.
    fn value_type(&self, r: &Record, i: &mut usize) -> Result<(ValueId, TypeId)> {
        let id = self.absolute(op(r, *i)?, r.at)?;
        *i = i.saturating_add(1);
        if id < self.next() {
            let t = self
                .m
                .value_types
                .get(id)
                .copied()
                .ok_or_else(|| error(r.at, format!("value {id} has no type")))?;
            Ok((id, t))
        } else {
            let t = self.m.ty(op(r, *i)?, r.at)?;
            *i = i.saturating_add(1);
            Ok((id, t))
        }
    }
    /// A relative operand whose type is known from another operand: a forward reference carries none.
    fn value(&self, r: &Record, i: &mut usize) -> Result<ValueId> {
        let id = self.absolute(op(r, *i)?, r.at)?;
        *i = i.saturating_add(1);
        Ok(id)
    }
    /// The absolute id a relative operand names: the next id minus the operand, in 32 bits as LLVM writes it (a value
    /// defined later is a forward reference, which wraps).
    fn absolute(&self, relative: u64, at: usize) -> Result<ValueId> {
        let relative = u32::try_from(relative)
            .map_err(|_| error(at, format!("relative value id {relative} wider than 32 bits")))?;
        let next = u32::try_from(self.next()).map_err(|_| error(at, "too many values"))?;
        Ok(next.wrapping_sub(relative) as usize)
    }
    /// The pointer to `t` in address space `space`.
    fn pointer_to(&mut self, t: TypeId, space: u32) -> TypeId {
        self.m.intern(Type::Pointer(t, space))
    }
    /// The index a constant integer value stands for, if it is one defined in the module or this function.
    fn constant_index(&self, v: ValueId) -> Option<usize> {
        match self.m.values.get(v) {
            Some(Value::Constant(Constant::Integer(i))) => usize::try_from(*i).ok(),
            Some(Value::Constant(Constant::Null)) => Some(0),
            _ => None,
        }
    }
    fn result(&mut self, ty: TypeId, at: usize) -> Result<Option<(ValueId, TypeId)>> {
        if *self.m.type_at(ty, at)? == Type::Void {
            return Ok(None);
        }
        Ok(Some((self.m.push(Value::Local, ty, at)?, ty)))
    }
}

/// An alignment as records store it: 0 for none, otherwise the log2 of the bytes plus one.
fn alignment(stored: u64, at: usize) -> Result<u64> {
    match stored {
        0 => Ok(0),
        n if n <= 30 => Ok(1u64.wrapping_shl(u32::try_from(n).unwrap_or(0).wrapping_sub(1))),
        _ => Err(error(at, "alignment")),
    }
}
fn ordering(code: u64, at: usize) -> Result<Ordering> {
    Ok(match code {
        0 => Ordering::NotAtomic,
        1 => Ordering::Unordered,
        2 => Ordering::Monotonic,
        3 => Ordering::Acquire,
        4 => Ordering::Release,
        5 => Ordering::AcquireRelease,
        6 => Ordering::SequentiallyConsistent,
        other => return Err(error(at, format!("atomic ordering {other}"))),
    })
}
/// An ordering and a scope (0 single thread, 1 all).
fn atomic(ordering_code: u64, scope: u64, at: usize) -> Result<Atomic> {
    Ok(Atomic {
        ordering: ordering(ordering_code, at)?,
        single_thread: match scope {
            0 => true,
            1 => false,
            other => return Err(error(at, format!("synchronisation scope {other}"))),
        },
    })
}
fn binary(code: u64, at: usize) -> Result<BinaryOp> {
    Ok(match code {
        0 => BinaryOp::Add,
        1 => BinaryOp::Sub,
        2 => BinaryOp::Mul,
        3 => BinaryOp::UDiv,
        4 => BinaryOp::SDiv,
        5 => BinaryOp::URem,
        6 => BinaryOp::SRem,
        7 => BinaryOp::Shl,
        8 => BinaryOp::LShr,
        9 => BinaryOp::AShr,
        10 => BinaryOp::And,
        11 => BinaryOp::Or,
        12 => BinaryOp::Xor,
        other => return Err(error(at, format!("binary opcode {other}"))),
    })
}
fn cast(code: u64, at: usize) -> Result<CastOp> {
    Ok(match code {
        0 => CastOp::Trunc,
        1 => CastOp::ZExt,
        2 => CastOp::SExt,
        3 => CastOp::FpToUi,
        4 => CastOp::FpToSi,
        5 => CastOp::UiToFp,
        6 => CastOp::SiToFp,
        7 => CastOp::FpTrunc,
        8 => CastOp::FpExt,
        9 => CastOp::PtrToInt,
        10 => CastOp::IntToPtr,
        11 => CastOp::BitCast,
        12 => CastOp::AddrSpaceCast,
        other => return Err(error(at, format!("cast opcode {other}"))),
    })
}
/// The linkage and other properties of a global variable's or function's record, from the operands at the indices given
/// (they differ between the two records). A field past the record's end is its default; a comdat is refused, and so
/// is a linkage code that implies one (1, 4, 10 and 11, in a record without the comdat field).
#[expect(clippy::too_many_arguments, reason = "the field positions of the two records")]
fn global_properties(
    r: &Record,
    linkage: usize,
    alignment_at: usize,
    section: usize,
    visibility: usize,
    unnamed_addr: usize,
    dll_storage: usize,
    comdat: usize,
    sections: &[String],
) -> Result<GlobalProperties> {
    let raw = op(r, linkage)?;
    let decoded = match raw {
        0 | 5 | 6 | 15 => Linkage::External,
        2 => Linkage::Appending,
        3 => Linkage::Internal,
        7 => Linkage::ExternWeak,
        8 => Linkage::Common,
        9 | 13 | 14 => Linkage::Private,
        12 => Linkage::AvailableExternally,
        1 | 16 => Linkage::WeakAny,
        10 | 17 => Linkage::WeakOdr,
        4 | 18 => Linkage::LinkOnceAny,
        11 | 19 => Linkage::LinkOnceOdr,
        _ => Linkage::External,
    };
    let field = |i: usize| r.operands.get(i).copied();
    if field(comdat).map_or(matches!(raw, 1 | 4 | 10 | 11), |c| c != 0) {
        return Err(error(r.at, "a global value in a comdat is not supported"));
    }
    let local = matches!(decoded, Linkage::Internal | Linkage::Private);
    Ok(GlobalProperties {
        linkage: decoded,
        // local linkage has the default visibility, whatever the record says
        visibility: match field(visibility).unwrap_or(0) {
            _ if local => 0,
            v @ 0..=2 => u8::try_from(v).unwrap_or(0),
            _ => 0,
        },
        // a record without the field says it by the old linkage codes 5 (dllimport) and 6 (dllexport)
        dll_storage: match field(dll_storage) {
            Some(v @ 0..=2) => u8::try_from(v).unwrap_or(0),
            Some(_) => 0,
            None => match raw {
                5 => 1,
                6 => 2,
                _ => 0,
            },
        },
        unnamed_addr: field(unnamed_addr).is_some_and(|v| v != 0),
        section: match op(r, section)? {
            0 => None,
            n => Some(
                usize::try_from(n.saturating_sub(1))
                    .ok()
                    .and_then(|n| sections.get(n))
                    .cloned()
                    .ok_or_else(|| error(r.at, "a global value names a section the module lacks"))?,
            ),
        },
        alignment: alignment(op(r, alignment_at)?, r.at)?,
    })
}

/// What a constants record this reader refuses holds.
fn constant_record(code: u64) -> &'static str {
    match code {
        5 => "an integer wider than 64 bits",
        13 => "a constant select",
        14 => "a constant extractelement",
        15 => "a constant insertelement",
        16 | 19 => "a constant shufflevector",
        18 => "inline assembly (old form)",
        21 => "a block address",
        23 | 30 => "inline assembly",
        _ => "an unknown constant",
    }
}

/// The name of a function-body record code this reader refuses.
fn refused(code: u64) -> &'static str {
    match code {
        4 | 30 => "getelementptr (old form)",
        13 => "invoke",
        23 => "va_arg",
        31 => "indirectbr",
        37 => "cmpxchg (old form)",
        59 => "atomicrmw (new form)",
        39 => "resume",
        40 | 47 => "landingpad",
        _ => "unknown instruction record",
    }
}

/// Reads a function's attachment block: a record `[instruction, (kind, node)...]` (an odd number of operands) attaches
/// the pairs to that instruction, a record of an even number of operands, `(kind, node)...`, to the function itself.
/// An instruction given the `dx.precise` kind is also marked [`Instruction::precise`].
fn read_attachments(
    precise: Option<u64>,
    block: &Block,
    instructions: &mut [Instruction],
    function: &mut Vec<Attachment>,
) -> Result<()> {
    for r in block.records().filter(|r| r.code == 11) {
        let per_instruction = r.operands.len() % 2 == 1;
        let mut attachments = Vec::new();
        let (pairs, _) = r
            .operands
            .get(usize::from(per_instruction)..)
            .unwrap_or_default()
            .as_chunks::<2>();
        for &[kind, node] in pairs {
            attachments.push(Attachment {
                kind,
                node: usize::try_from(node).map_err(|_| error(r.at, "attachment node"))?,
            });
        }
        if !per_instruction {
            function.extend(attachments);
            continue;
        }
        let at = usize::try_from(op(r, 0)?).map_err(|_| error(r.at, "attachment instruction"))?;
        let instruction = instructions.get_mut(at).ok_or_else(|| {
            error(
                r.at,
                format!("an attachment names instruction {at} of a shorter body"),
            )
        })?;
        if precise.is_some_and(|kind| attachments.iter().any(|a| a.kind == kind)) {
            instruction.precise = true;
        }
        instruction.attachments.extend(attachments);
    }
    Ok(())
}

impl Module {
    fn read_function(&mut self, block: &Block, value: ValueId) -> Result<Function> {
        let fty = match self.value_types.get(value).and_then(|&t| self.types.get(t)) {
            Some(Type::Pointer(t, _)) => *t,
            _ => return Err(error(block.at, "function value is not a function pointer")),
        };
        let params = match self.type_at(fty, block.at)? {
            Type::Function { params, .. } => params.clone(),
            _ => return Err(error(block.at, "function type")),
        };
        let base = self.values.len();
        for p in params {
            self.push(Value::Local, p, block.at)?;
        }
        let mut body = Body {
            m: self,
            block: 0,
            blocks: 0,
        };
        let mut instructions: Vec<Instruction> = Vec::new();
        let mut function_attachments = Vec::new();
        let mut local_metadata = Vec::new();
        // the metadata each call passes (instruction, argument, metadata id), and the last debug location
        let mut metadata_args: Vec<(usize, usize, MetadataId)> = Vec::new();
        let mut last_loc: Option<DebugLoc> = None;
        let (mut names, mut block_names, mut block_use_orders) = (Vec::new(), Vec::new(), Vec::new());
        for e in &block.elements {
            let r = match e {
                crate::bitstream::Element::Block(b) => {
                    match b.id {
                        CONSTANTS => body.m.read_constants(b)?,
                        VALUE_SYMTAB => {
                            let (values, blocks) = read_symbols(b)?;
                            names.extend(values);
                            block_names.extend(blocks);
                        }
                        METADATA_ATTACHMENT => read_attachments(
                            body.m.precise_kind,
                            b,
                            &mut instructions,
                            &mut function_attachments,
                        )?,
                        // function-local metadata: values of the body as metadata, `[type, absolute value id]`
                        METADATA => {
                            for r in b.records() {
                                if r.code != 2 {
                                    return Err(error(
                                        r.at,
                                        format!("metadata record {} in a function body", r.code),
                                    ));
                                }
                                let ty = body.m.ty(op(r, 0)?, r.at)?;
                                let value =
                                    usize::try_from(op(r, 1)?).map_err(|_| error(r.at, "value id"))?;
                                local_metadata.push(Metadata::Value { ty, value });
                            }
                        }
                        // the use-list orders: of basic blocks [position..., block] (they order its predecessors),
                        // and of values [position..., value], which say nothing a listing shows
                        USELIST => {
                            for r in b.records() {
                                let (last, order) = r
                                    .operands
                                    .split_last()
                                    .filter(|(_, order)| order.len() >= 2)
                                    .ok_or_else(|| error(r.at, "use-list order"))?;
                                match r.code {
                                    1 => {}
                                    2 => block_use_orders.push((
                                        usize::try_from(*last).map_err(|_| error(r.at, "use-list block"))?,
                                        order.to_vec(),
                                    )),
                                    other => return Err(error(r.at, format!("use-list record {other}"))),
                                }
                            }
                        }
                        other => return Err(error(b.at, format!("block {other} in a function"))),
                    }
                    continue;
                }
                crate::bitstream::Element::Record(r) => r,
            };
            let mut i = 0;
            let mut flags = 0;
            let (op, ty): (Op, Option<TypeId>) = match r.code {
                1 => {
                    body.blocks = usize::try_from(op(r, 0)?)
                        .ok()
                        .filter(|&n| n > 0 && n <= 1 << 16)
                        .ok_or_else(|| error(r.at, "basic block count"))?;
                    continue;
                }
                // DEBUG_LOC: [line, column, scope id + 1 or 0, inlined-at id + 1 or 0], of the last instruction
                35 => {
                    let node = |i: usize| -> Result<Option<MetadataId>> {
                        match op(r, i)? {
                            0 => Ok(None),
                            v => usize::try_from(v.saturating_sub(1))
                                .map(Some)
                                .map_err(|_| error(r.at, "metadata id")),
                        }
                    };
                    let loc = DebugLoc {
                        line: crate::debug_info::unsigned(op(r, 0)?),
                        column: crate::debug_info::column(crate::debug_info::unsigned(op(r, 1)?)),
                        scope: node(2)?,
                        inlined_at: node(3)?,
                    };
                    let last = instructions
                        .last_mut()
                        .ok_or_else(|| error(r.at, "a debug location before any instruction"))?;
                    last.debug_loc = Some(loc);
                    last_loc = Some(loc);
                    continue;
                }
                // DEBUG_LOC_AGAIN: the last instruction is where the last located one is
                33 => {
                    let last = instructions
                        .last_mut()
                        .ok_or_else(|| error(r.at, "a debug location before any instruction"))?;
                    last.debug_loc = last_loc;
                    continue;
                }
                // BINOP: [lhs with its type, rhs, opcode, flags?]
                2 => {
                    let (lhs, t) = body.value_type(r, &mut i)?;
                    let rhs = body.value(r, &mut i)?;
                    let o = binary(op(r, i)?, r.at)?;
                    flags = r.operands.get(i.saturating_add(1)).copied().unwrap_or(0);
                    (Op::Binary { op: o, lhs, rhs }, Some(t))
                }
                // CAST: [value with its type, target type, opcode]
                3 => {
                    let (value, _) = body.value_type(r, &mut i)?;
                    let to = body.m.ty(op(r, i)?, r.at)?;
                    let o = cast(op(r, i.saturating_add(1))?, r.at)?;
                    (Op::Cast { op: o, value }, Some(to))
                }
                // CMP and CMP2: [lhs with its type, rhs, predicate, fast-math flags?]
                9 | 28 => {
                    let (lhs, t) = body.value_type(r, &mut i)?;
                    let rhs = body.value(r, &mut i)?;
                    let predicate = op(r, i)?;
                    flags = r.operands.get(i.saturating_add(1)).copied().unwrap_or(0);
                    // i1, or a vector of i1 for vectors
                    let lanes = match body.m.type_at(t, r.at)? {
                        Type::Vector(n, _) => Some(*n),
                        _ => None,
                    };
                    let flag = body.m.intern(Type::Integer(1));
                    let bool_ty = match lanes {
                        Some(n) => body.m.intern(Type::Vector(n, flag)),
                        None => flag,
                    };
                    (Op::Compare { predicate, lhs, rhs }, Some(bool_ty))
                }
                29 => {
                    let (then, t) = body.value_type(r, &mut i)?;
                    let otherwise = body.value(r, &mut i)?;
                    let condition = body.value(r, &mut i)?;
                    (
                        Op::Select {
                            condition,
                            then,
                            otherwise,
                        },
                        Some(t),
                    )
                }
                26 => {
                    let (aggregate, mut t) = body.value_type(r, &mut i)?;
                    let indices = r.operands.get(i..).unwrap_or_default().to_vec();
                    for &k in &indices {
                        t = match body.m.type_at(t, r.at)? {
                            Type::Struct { elements, .. } => *usize::try_from(k)
                                .ok()
                                .and_then(|k| elements.get(k))
                                .ok_or_else(|| error(r.at, "extractvalue index"))?,
                            Type::Array(n, e) if k < *n => *e,
                            _ => return Err(error(r.at, "extractvalue index")),
                        };
                    }
                    (Op::ExtractValue { aggregate, indices }, Some(t))
                }
                6 => {
                    let (vector, t) = body.value_type(r, &mut i)?;
                    let (index, _) = body.value_type(r, &mut i)?;
                    let Type::Vector(_, element) = *body.m.type_at(t, r.at)? else {
                        return Err(error(r.at, "extractelement of something that is not a vector"));
                    };
                    (Op::ExtractElement { vector, index }, Some(element))
                }
                7 => {
                    let (vector, t) = body.value_type(r, &mut i)?;
                    let value = body.value(r, &mut i)?;
                    let (index, _) = body.value_type(r, &mut i)?;
                    (Op::InsertElement { vector, value, index }, Some(t))
                }
                8 => {
                    let (first, t) = body.value_type(r, &mut i)?;
                    let second = body.value(r, &mut i)?;
                    let (mask, mask_ty) = body.value_type(r, &mut i)?;
                    let (Type::Vector(_, element), Type::Vector(lanes, _)) = (
                        body.m.type_at(t, r.at)?.clone(),
                        body.m.type_at(mask_ty, r.at)?.clone(),
                    ) else {
                        return Err(error(r.at, "shufflevector of something that is not a vector"));
                    };
                    let result = body
                        .m
                        .types
                        .iter()
                        .position(|x| *x == Type::Vector(lanes, element))
                        .ok_or_else(|| error(r.at, "no type for the shuffled vector"))?;
                    (Op::ShuffleVector { first, second, mask }, Some(result))
                }
                27 => {
                    let (aggregate, t) = body.value_type(r, &mut i)?;
                    let value = body.value(r, &mut i)?;
                    let indices = r.operands.get(i..).unwrap_or_default().to_vec();
                    (
                        Op::InsertValue {
                            aggregate,
                            value,
                            indices,
                        },
                        Some(t),
                    )
                }
                // CALL: [attribute list + 1 or 0, calling convention and flags, function type if explicit, callee with
                // its type, arguments]
                34 => {
                    let attributes = usize::try_from(op(r, 0)?)
                        .map_err(|_| error(r.at, "call attribute list"))?
                        .checked_sub(1);
                    if attributes.is_some_and(|a| a >= body.m.attribute_lists.len()) {
                        return Err(error(r.at, "a call names an attribute list the module lacks"));
                    }
                    i = 1;
                    let cc = op(r, i)?;
                    i = i.saturating_add(1);
                    // bit 0 tail, bit 14 musttail, bit 15 an explicit function type, the convention from bit 1
                    let tail = if cc & (1 << 14) != 0 {
                        TailCall::MustTail
                    } else if cc & 1 != 0 {
                        TailCall::Tail
                    } else {
                        TailCall::None
                    };
                    let calling_conv = (cc >> 1) & 0x1FFF;
                    let explicit = if cc & (1 << 15) != 0 {
                        let t = body.m.ty(op(r, i)?, r.at)?;
                        i = i.saturating_add(1);
                        Some(t)
                    } else {
                        None
                    };
                    let (function, callee_ty) = body.value_type(r, &mut i)?;
                    let fty = match (explicit, body.m.type_at(callee_ty, r.at)?) {
                        (Some(t), _) => t,
                        (None, Type::Pointer(t, _)) => *t,
                        _ => return Err(error(r.at, "callee is not a function pointer")),
                    };
                    let (ret, params, vararg) = match body.m.type_at(fty, r.at)? {
                        Type::Function { ret, params, vararg } => (*ret, params.clone(), *vararg),
                        _ => return Err(error(r.at, "call through a non-function type")),
                    };
                    if vararg {
                        return Err(error(r.at, "vararg call"));
                    }
                    let mut args = Vec::with_capacity(params.len());
                    for (n, p) in params.iter().enumerate() {
                        // a fixed parameter carries no type, even for a value defined later in the layout
                        let a = body.value(r, &mut i)?;
                        // a `metadata` parameter's operand is a metadata id, relative as a value's is; the argument is
                        // given its value once the body is read
                        if *body.m.type_at(*p, r.at)? == Type::Metadata {
                            metadata_args.push((instructions.len(), n, a));
                            args.push(usize::MAX);
                            continue;
                        }
                        if a < body.next() && body.m.value_types.get(a) != Some(p) {
                            return Err(error(r.at, "call argument type"));
                        }
                        args.push(a);
                    }
                    if i != r.operands.len() {
                        return Err(error(r.at, "call operands left over"));
                    }
                    (
                        Op::Call {
                            function,
                            args,
                            attributes,
                            calling_conv,
                            tail,
                        },
                        Some(ret),
                    )
                }
                16 => {
                    let t = body.m.ty(op(r, 0)?, r.at)?;
                    let pairs = r.operands.get(1..).unwrap_or_default();
                    if pairs.is_empty() || pairs.len() % 2 != 0 {
                        return Err(error(r.at, "phi operands"));
                    }
                    let next = i64::try_from(body.next()).map_err(|_| error(r.at, "too many values"))?;
                    let mut incoming = Vec::with_capacity(pairs.len() / 2);
                    for pair in pairs.as_chunks::<2>().0 {
                        // Signed and relative to the phi itself; it may name a value defined later.
                        let id = next
                            .checked_sub(signed_vbr(pair[0]))
                            .and_then(|v| usize::try_from(v).ok())
                            .ok_or_else(|| error(r.at, "phi value"))?;
                        let block = usize::try_from(pair[1])
                            .ok()
                            .filter(|&b| b < body.blocks)
                            .ok_or_else(|| error(r.at, "phi block"))?;
                        incoming.push((id, block));
                    }
                    (Op::Phi { incoming }, Some(t))
                }
                10 => {
                    if r.operands.is_empty() {
                        (Op::Return(None), None)
                    } else {
                        (Op::Return(Some(body.value(r, &mut i)?)), None)
                    }
                }
                11 => {
                    let target = |v: u64| -> Result<usize> {
                        usize::try_from(v)
                            .ok()
                            .filter(|&b| b < body.blocks)
                            .ok_or_else(|| error(r.at, "branch target"))
                    };
                    if r.operands.len() == 1 {
                        (
                            Op::Branch {
                                target: target(op(r, 0)?)?,
                            },
                            None,
                        )
                    } else {
                        let then = target(op(r, 0)?)?;
                        let otherwise = target(op(r, 1)?)?;
                        i = 2;
                        let condition = body.value(r, &mut i)?;
                        (
                            Op::CondBranch {
                                condition,
                                then,
                                otherwise,
                            },
                            None,
                        )
                    }
                }
                12 => {
                    // [type, value, default block, (case constant, block)*]; case constants are absolute ids
                    let block = |v: u64| -> Result<usize> {
                        usize::try_from(v)
                            .ok()
                            .filter(|&b| b < body.blocks)
                            .ok_or_else(|| error(r.at, "switch target"))
                    };
                    if op(r, 0)? >> 16 == 0x4B5 {
                        return Err(error(r.at, "switch with case ranges is not supported"));
                    }
                    i = 1;
                    let value = body.value(r, &mut i)?;
                    let default = block(op(r, i)?)?;
                    let pairs = r.operands.get(i.saturating_add(1)..).unwrap_or_default();
                    if pairs.len() % 2 != 0 {
                        return Err(error(r.at, "switch cases"));
                    }
                    let cases = pairs
                        .as_chunks::<2>()
                        .0
                        .iter()
                        .map(|p| {
                            Ok((
                                usize::try_from(p[0]).map_err(|_| error(r.at, "case value"))?,
                                block(p[1])?,
                            ))
                        })
                        .collect::<Result<Vec<_>>>()?;
                    (
                        Op::Switch {
                            value,
                            default,
                            cases,
                        },
                        None,
                    )
                }
                15 => (Op::Unreachable, None),
                // ALLOCA: [type, size type, size (an absolute id), alignment with flags: bit 5 inalloca, bit 6 the
                // type is the allocated one rather than a pointer to it]
                19 => {
                    let stated = body.m.ty(op(r, 0)?, r.at)?;
                    let packed = op(r, 3)?;
                    let ty = if packed & (1 << 6) != 0 {
                        stated
                    } else {
                        match body.m.type_at(stated, r.at)? {
                            Type::Pointer(t, _) => *t,
                            _ => {
                                return Err(error(
                                    r.at,
                                    "an alloca of the old form whose type is not a pointer",
                                ));
                            }
                        }
                    };
                    let size = usize::try_from(op(r, 2)?).map_err(|_| error(r.at, "alloca size"))?;
                    (
                        Op::Alloca {
                            ty,
                            size,
                            align: alignment(packed & !((1 << 5) | (1 << 6)), r.at)?,
                            inalloca: packed & (1 << 5) != 0,
                        },
                        Some(body.pointer_to(ty, 0)),
                    )
                }
                // LOAD: [pointer with its type, loaded type if explicit, alignment, volatile], and LOADATOMIC with the
                // ordering and scope after them
                20 | 41 => {
                    let (pointer, pt) = body.value_type(r, &mut i)?;
                    let tail = if r.code == 20 { 2 } else { 4 };
                    let ty = if r.operands.len() == i.saturating_add(tail).saturating_add(1) {
                        let t = body.m.ty(op(r, i)?, r.at)?;
                        i = i.saturating_add(1);
                        t
                    } else {
                        match body.m.type_at(pt, r.at)? {
                            Type::Pointer(t, _) => *t,
                            _ => return Err(error(r.at, "a load from a value that is not a pointer")),
                        }
                    };
                    if r.operands.len() != i.saturating_add(tail) {
                        return Err(error(r.at, "load operands"));
                    }
                    let atomic = if r.code == 41 {
                        Some(atomic(
                            op(r, i.saturating_add(2))?,
                            op(r, i.saturating_add(3))?,
                            r.at,
                        )?)
                    } else {
                        None
                    };
                    (
                        Op::Load {
                            pointer,
                            align: alignment(op(r, i)?, r.at)?,
                            volatile: op(r, i.saturating_add(1))? != 0,
                            atomic,
                        },
                        Some(ty),
                    )
                }
                // STORE: [pointer with its type, value with its type, alignment, volatile], STOREATOMIC with the
                // ordering and scope after them; the old forms (24, 42) give the value without a type
                24 | 42 | 44 | 45 => {
                    let (pointer, _) = body.value_type(r, &mut i)?;
                    let value = if matches!(r.code, 44 | 45) {
                        body.value_type(r, &mut i)?.0
                    } else {
                        body.value(r, &mut i)?
                    };
                    let tail = if matches!(r.code, 24 | 44) { 2 } else { 4 };
                    if r.operands.len() != i.saturating_add(tail) {
                        return Err(error(r.at, "store operands"));
                    }
                    let atomic = if matches!(r.code, 42 | 45) {
                        Some(atomic(
                            op(r, i.saturating_add(2))?,
                            op(r, i.saturating_add(3))?,
                            r.at,
                        )?)
                    } else {
                        None
                    };
                    (
                        Op::Store {
                            pointer,
                            value,
                            align: alignment(op(r, i)?, r.at)?,
                            volatile: op(r, i.saturating_add(1))? != 0,
                            atomic,
                        },
                        None,
                    )
                }
                // ATOMICRMW: [pointer with its type, value, operation, volatile, ordering, scope]
                38 => {
                    let (pointer, pt) = body.value_type(r, &mut i)?;
                    let value = body.value(r, &mut i)?;
                    let ty = match body.m.type_at(pt, r.at)? {
                        Type::Pointer(t, _) => *t,
                        _ => return Err(error(r.at, "an atomicrmw on a value that is not a pointer")),
                    };
                    (
                        Op::AtomicRmw {
                            pointer,
                            value,
                            op: op(r, i)?,
                            volatile: op(r, i.saturating_add(1))? != 0,
                            atomic: atomic(op(r, i.saturating_add(2))?, op(r, i.saturating_add(3))?, r.at)?,
                        },
                        Some(ty),
                    )
                }
                // CMPXCHG: [pointer with its type, compare with its type, new value, volatile, success ordering, scope,
                // failure ordering, weak]; the result is a structure of the value and a flag
                46 => {
                    let (pointer, _) = body.value_type(r, &mut i)?;
                    let (compare, ty) = body.value_type(r, &mut i)?;
                    let value = body.value(r, &mut i)?;
                    if r.operands.len() != i.saturating_add(5) {
                        return Err(error(
                            r.at,
                            "cmpxchg without its failure ordering and weak flag (an old form)",
                        ));
                    }
                    let success = atomic(op(r, i.saturating_add(1))?, op(r, i.saturating_add(2))?, r.at)?;
                    let failure = ordering(op(r, i.saturating_add(3))?, r.at)?;
                    let flag = body.m.intern(Type::Integer(1));
                    let pair = Type::Struct {
                        name: None,
                        elements: vec![ty, flag],
                        packed: false,
                        literal: true,
                    };
                    let result = body.m.intern(pair);
                    (
                        Op::CmpXchg {
                            pointer,
                            compare,
                            value,
                            volatile: op(r, i)? != 0,
                            weak: op(r, i.saturating_add(4))? != 0,
                            success,
                            failure,
                        },
                        Some(result),
                    )
                }
                // FENCE: [ordering, scope]
                36 => (Op::Fence(atomic(op(r, 0)?, op(r, 1)?, r.at)?), None),
                43 => {
                    // [inbounds, source element type, then each operand with its type when a forward reference]
                    i = 2;
                    let inbounds = op(r, 0)? != 0;
                    let source = body.m.ty(op(r, 1)?, r.at)?;
                    let (base, base_ty) = body.value_type(r, &mut i)?;
                    // the result points into the base's address space
                    let space = match body.m.type_at(base_ty, r.at)? {
                        Type::Pointer(_, space) => *space,
                        _ => return Err(error(r.at, "getelementptr of a value that is not a pointer")),
                    };
                    let mut indices = Vec::new();
                    while i < r.operands.len() {
                        indices.push(body.value_type(r, &mut i)?.0);
                    }
                    // the result points at what the indices reach: the first steps over the pointer, the rest into
                    // arrays, vectors and structures
                    let mut t = source;
                    for &index in indices.iter().skip(1) {
                        t = match body.m.type_at(t, r.at)?.clone() {
                            Type::Array(_, e) | Type::Vector(_, e) => e,
                            Type::Struct { elements, .. } => {
                                let k = match body.constant_index(index) {
                                    Some(k) => k,
                                    None => {
                                        return Err(error(r.at, "a structure index that is not constant"));
                                    }
                                };
                                *elements
                                    .get(k)
                                    .ok_or_else(|| error(r.at, "getelementptr structure index"))?
                            }
                            _ => return Err(error(r.at, "getelementptr into a scalar")),
                        };
                    }
                    (
                        Op::Gep {
                            base,
                            indices,
                            source,
                            inbounds,
                        },
                        Some(body.pointer_to(t, space)),
                    )
                }
                other => {
                    return Err(error(
                        r.at,
                        format!("instruction {} (record {other}) is not supported", refused(other)),
                    ));
                }
            };
            let result = match ty {
                Some(t) => body.result(t, r.at)?,
                None => None,
            };
            let terminator = matches!(
                op,
                Op::Return(_)
                    | Op::Branch { .. }
                    | Op::CondBranch { .. }
                    | Op::Switch { .. }
                    | Op::Unreachable
            );
            instructions.push(Instruction {
                op,
                result,
                block: body.block,
                at: r.at,
                flags,
                precise: false,
                attachments: Vec::new(),
                debug_loc: None,
            });
            if terminator {
                body.block = body.block.saturating_add(1);
            }
        }
        if body.block != body.blocks {
            return Err(error(block.at, "basic blocks without terminators"));
        }
        let end = body.next();
        let blocks = body.blocks;
        // each metadata a call passes is a value of the body, after its others, once per metadata id
        let metadata_type = self.intern(Type::Metadata);
        let first_metadata = self.metadata.len();
        let mut metadata_values: Vec<(MetadataId, ValueId)> = Vec::new();
        for (inst, arg, md) in metadata_args {
            let at = instructions.get(inst).map_or(block.at, |i| i.at);
            if md >= first_metadata.saturating_add(local_metadata.len()) {
                return Err(error(
                    at,
                    format!("a call passes metadata {md}, which the module lacks"),
                ));
            }
            let value = match metadata_values.iter().find(|(m, _)| *m == md) {
                Some((_, v)) => *v,
                None => {
                    let v = self.push(Value::Metadata(md), metadata_type, at)?;
                    metadata_values.push((md, v));
                    v
                }
            };
            if let Some(Op::Call { args, .. }) = instructions.get_mut(inst).map(|i| &mut i.op)
                && let Some(a) = args.get_mut(arg)
            {
                *a = value;
            }
        }
        let metadata_value = |v: ValueId| metadata_values.iter().any(|(_, m)| *m == v);
        // everything an instruction names is something the function has: a value (an earlier one, or a later one a phi
        // or a loop reads), a basic block, and a callee taking the arguments it is given
        for inst in &instructions {
            if inst.block >= blocks {
                return Err(error(inst.at, "an instruction after the last terminator"));
            }
            if let Some(v) = inst
                .op
                .operands()
                .into_iter()
                .find(|v| *v >= end && !metadata_value(*v))
            {
                return Err(error(inst.at, format!("value {v} of {end} values")));
            }
            if let Some(b) = inst.op.blocks().into_iter().find(|b| *b >= blocks) {
                return Err(error(inst.at, format!("basic block {b} of {blocks}")));
            }
            if let Op::Call { function, args, .. } = &inst.op {
                if *function >= end {
                    return Err(error(inst.at, format!("callee {function} of {end} values")));
                }
                if let Some(Value::Function { ty, .. }) = self.values.get(*function)
                    && let Some(Type::Function {
                        vararg: false,
                        params,
                        ..
                    }) = self.types.get(*ty)
                    && params.len() != args.len()
                {
                    return Err(error(
                        inst.at,
                        format!(
                            "a call of {} arguments to a function of {} parameters",
                            args.len(),
                            params.len()
                        ),
                    ));
                }
            }
        }
        let locals = self.values.split_off(base);
        let local_types = self.value_types.split_off(base);
        Ok(Function {
            value,
            blocks,
            instructions,
            first: base,
            locals,
            local_types,
            attachments: function_attachments,
            metadata: local_metadata,
            first_metadata,
            names,
            block_names,
            block_use_orders,
        })
    }

    /// Read a module from the bitcode's top-level blocks.
    pub fn read(top: &[Block]) -> Result<Self> {
        let module = match top {
            [m] if m.id == MODULE => m,
            _ => return Err(error(0, "bitcode is not one module block")),
        };
        let mut m = Module {
            at: module.at,
            ..Module::default()
        };
        let mut bodies: Vec<ValueId> = Vec::new();
        let mut version = None;
        let (mut sections, mut gcs) = (Vec::new(), Vec::new());
        for e in &module.elements {
            match e {
                crate::bitstream::Element::Record(r) => match r.code {
                    1 => version = Some(op(r, 0)?),
                    2 => m.triple = Some(utf8(text(&r.operands, r.at)?, r.at)?),
                    3 => m.datalayout = Some(utf8(text(&r.operands, r.at)?, r.at)?),
                    4 => m.asm = Some(utf8(text(&r.operands, r.at)?, r.at)?),
                    5 => sections.push(utf8(text(&r.operands, r.at)?, r.at)?),
                    11 => gcs.push(utf8(text(&r.operands, r.at)?, r.at)?),
                    6 | 13 | 16 => {} // deplib, the symbol table's offset, source file
                    7 => {
                        // GLOBALVAR: [type, flags (bit 0 constant, bit 1 explicit type, from bit 2 the address space),
                        // initial value + 1 or 0, linkage, alignment, section, visibility, thread local, unnamed_addr,
                        // externally initialized, DLL storage, comdat]
                        let t = m.ty(op(r, 0)?, r.at)?;
                        let flags = op(r, 1)?;
                        let (ty, value_ty, address_space) = if flags & 2 != 0 {
                            let space =
                                u32::try_from(flags >> 2).map_err(|_| error(r.at, "address space"))?;
                            (m.intern(Type::Pointer(t, space)), t, space)
                        } else {
                            match m.type_at(t, r.at)? {
                                Type::Pointer(inner, space) => (t, *inner, *space),
                                _ => return Err(error(r.at, "a global whose type is not a pointer")),
                            }
                        };
                        let init = match op(r, 2)? {
                            0 => None,
                            n => Some(
                                usize::try_from(n.saturating_sub(1))
                                    .map_err(|_| error(r.at, "initial value id"))?,
                            ),
                        };
                        let properties = global_properties(r, 3, 4, 5, 6, 8, 10, 11, &sections)?;
                        m.push(
                            Value::Global {
                                ty,
                                value_ty,
                                init,
                                constant: flags & 1 != 0,
                                address_space,
                                properties,
                                thread_local: u8::try_from(r.operands.get(7).copied().unwrap_or(0))
                                    .ok()
                                    .filter(|&t| t <= 4)
                                    .ok_or_else(|| error(r.at, "thread-local model"))?,
                                externally_initialized: r.operands.get(9).is_some_and(|&v| v != 0),
                            },
                            ty,
                            r.at,
                        )?;
                    }
                    8 => {
                        // FUNCTION: [function type, calling convention, declaration, linkage, attribute list + 1 or 0,
                        // alignment, section, visibility, gc, unnamed_addr, prologue, DLL storage, comdat, prefix,
                        // personality]
                        let t = m.ty(op(r, 0)?, r.at)?;
                        let pointer = m.intern(Type::Pointer(t, 0));
                        let declaration = op(r, 2)? != 0;
                        // the attribute list is named by its 1-based index (0 for none)
                        let attributes = r
                            .operands
                            .get(4)
                            .and_then(|&n| usize::try_from(n).ok())
                            .and_then(|n| n.checked_sub(1));
                        for (field, what) in [
                            (10, "prologue data"),
                            (13, "prefix data"),
                            (14, "a personality function"),
                        ] {
                            if r.operands.get(field).is_some_and(|&v| v != 0) {
                                return Err(error(r.at, format!("a function with {what} is not supported")));
                            }
                        }
                        let gc = match r.operands.get(8).copied().unwrap_or(0) {
                            0 => None,
                            n => Some(
                                usize::try_from(n.saturating_sub(1))
                                    .ok()
                                    .and_then(|n| gcs.get(n))
                                    .cloned()
                                    .ok_or_else(|| {
                                        error(r.at, "a function names a garbage collector the module lacks")
                                    })?,
                            ),
                        };
                        let v = m.push(
                            Value::Function {
                                ty: t,
                                declaration,
                                attributes,
                                properties: global_properties(r, 3, 5, 6, 7, 9, 11, 12, &sections)?,
                                calling_conv: op(r, 1)?,
                                gc,
                            },
                            pointer,
                            r.at,
                        )?;
                        if !declaration {
                            bodies.push(v);
                        }
                    }
                    other => return Err(error(r.at, format!("module record {other}"))),
                },
                crate::bitstream::Element::Block(b) => match b.id {
                    BLOCKINFO | USELIST => {}
                    PARAMATTR_GROUP => m.read_attribute_groups(b)?,
                    PARAMATTR => m.read_attribute_lists(b),
                    TYPES => m.read_types(b)?,
                    CONSTANTS => m.read_constants(b)?,
                    METADATA => m.read_metadata(b)?,
                    VALUE_SYMTAB => {
                        let (values, blocks) = read_symbols(b)?;
                        if let Some((_, name)) = blocks.first() {
                            return Err(error(
                                b.at,
                                format!("a basic block name ({name}) in the module's symbol table"),
                            ));
                        }
                        m.names.extend(values);
                    }
                    FUNCTION => {
                        if version != Some(1) {
                            return Err(error(b.at, "only relative value ids (module version 1)"));
                        }
                        // Bodies are stored in the order of their definitions (a hull program has two).
                        if bodies.is_empty() {
                            return Err(error(b.at, "function body without a definition"));
                        }
                        let value = bodies.remove(0);
                        // A body's values are its own; the next body numbers from the module's values again.
                        let f = m.read_function(b, value)?;
                        m.functions.push(f);
                    }
                    other => return Err(error(b.at, format!("module block {other}"))),
                },
            }
        }
        if !bodies.is_empty() {
            return Err(error(module.at, "a defined function has no body"));
        }
        Ok(m)
    }
}

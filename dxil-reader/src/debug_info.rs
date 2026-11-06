//! Debug information as a program built with `-Zi` keeps it in its module (`-Qembed_debug`, or the `ILDB` part of a
//! container): LLVM 3.7's `DI*` metadata nodes, read from their metadata records as dxc 1.9.2609's bitcode reader reads
//! them, and the source location of each instruction ([`DebugLoc`]).
//!
//! A node's references to other metadata are metadata ids ([`MetadataId`], `None` for a null reference), strings
//! included: a name is the id of a metadata string ([`crate::module::Metadata::String`]), and a reference to a value
//! (a subprogram's function, a global variable's variable, a template parameter's value) is the id of a value as
//! metadata ([`crate::module::Metadata::Value`]). Numbers keep LLVM's widths: a line, column, tag or flags word is the
//! `unsigned` LLVM keeps (the low 32 bits of the record's operand), sizes and offsets are 64 bits.
use crate::module::MetadataId;
use crate::{Result, error};

/// A debug-information node: one of LLVM 3.7's `DI*` metadata classes.
#[derive(Clone, Debug, PartialEq, Eq)]
pub enum DebugNode {
    /// `DILocation`: a source position, in a scope, maybe inlined at another location.
    Location {
        /// The line (0 for none).
        line: u32,
        /// The column (0 for none, and where the record's does not fit in 16 bits).
        column: u32,
        /// The scope (a subprogram or lexical block).
        scope: MetadataId,
        /// The location of the call this one was inlined into.
        inlined_at: Option<MetadataId>,
    },
    /// `GenericDINode`: a DWARF entry LLVM has no class for.
    Generic {
        /// Its DWARF tag.
        tag: u32,
        /// Its header string.
        header: Option<MetadataId>,
        /// Its DWARF operands.
        operands: Vec<Option<MetadataId>>,
    },
    /// `DISubrange`: an array dimension.
    Subrange {
        /// The element count (-1 for an unknown count).
        count: i64,
        /// The first index.
        lower_bound: i64,
    },
    /// `DIEnumerator`: one value of an enumeration.
    Enumerator {
        /// Its value.
        value: i64,
        /// Its name.
        name: Option<MetadataId>,
    },
    /// `DIBasicType`: a scalar type.
    BasicType {
        /// Its DWARF tag (`DW_TAG_base_type` and `DW_TAG_unspecified_type`).
        tag: u32,
        /// Its name.
        name: Option<MetadataId>,
        /// Its size in bits.
        size: u64,
        /// Its alignment in bits.
        align: u64,
        /// Its encoding (`DW_ATE_*`).
        encoding: u32,
    },
    /// `DIDerivedType`: a type made from another (a member, typedef, pointer, qualifier, ...).
    DerivedType {
        /// Its DWARF tag.
        tag: u32,
        /// Its name.
        name: Option<MetadataId>,
        /// Its file.
        file: Option<MetadataId>,
        /// Its line.
        line: u32,
        /// Its scope.
        scope: Option<MetadataId>,
        /// The type it derives from.
        base_type: Option<MetadataId>,
        /// Its size in bits.
        size: u64,
        /// Its alignment in bits.
        align: u64,
        /// Its offset in bits (a member's).
        offset: u64,
        /// Its `DIFlag*` bits.
        flags: u32,
        /// Extra data (a static member's value, a pointer to member's class, ...).
        extra_data: Option<MetadataId>,
    },
    /// `DICompositeType`: a structure, class, union, array or enumeration.
    CompositeType {
        /// Its DWARF tag.
        tag: u32,
        /// Its name.
        name: Option<MetadataId>,
        /// Its file.
        file: Option<MetadataId>,
        /// Its line.
        line: u32,
        /// Its scope.
        scope: Option<MetadataId>,
        /// Its base type (an array's elements, an enumeration's underlying type).
        base_type: Option<MetadataId>,
        /// Its size in bits.
        size: u64,
        /// Its alignment in bits.
        align: u64,
        /// Its offset in bits.
        offset: u64,
        /// Its `DIFlag*` bits.
        flags: u32,
        /// Its members, enumerators or subranges (a node listing them).
        elements: Option<MetadataId>,
        /// Its runtime language (`DW_LANG_*`, 0 for none).
        runtime_lang: u32,
        /// The type holding its virtual table.
        vtable_holder: Option<MetadataId>,
        /// Its template parameters (a node listing them).
        template_params: Option<MetadataId>,
        /// Its unique identifier.
        identifier: Option<MetadataId>,
    },
    /// `DISubroutineType`: a function type.
    SubroutineType {
        /// Its `DIFlag*` bits.
        flags: u32,
        /// Its return type and parameter types (a node listing them).
        types: Option<MetadataId>,
    },
    /// `DIFile`: a source file.
    File {
        /// The file's name.
        filename: Option<MetadataId>,
        /// Its directory.
        directory: Option<MetadataId>,
    },
    /// `DICompileUnit`: the compilation the program's debug information describes.
    CompileUnit {
        /// The source language (`DW_LANG_*`).
        language: u32,
        /// The main file.
        file: Option<MetadataId>,
        /// The compiler that made it.
        producer: Option<MetadataId>,
        /// Whether it was optimized.
        optimized: bool,
        /// The compiler's flags.
        flags: Option<MetadataId>,
        /// The runtime version.
        runtime_version: u32,
        /// The file split debug information goes to.
        split_debug_filename: Option<MetadataId>,
        /// How much debug information it emits (1 full, 2 line tables only).
        emission_kind: u32,
        /// Its enumeration types (a node listing them).
        enums: Option<MetadataId>,
        /// The types it keeps whether used or not.
        retained_types: Option<MetadataId>,
        /// Its subprograms.
        subprograms: Option<MetadataId>,
        /// Its global variables.
        globals: Option<MetadataId>,
        /// Its imported entities.
        imports: Option<MetadataId>,
        /// The split debug information's id.
        dwo_id: u64,
    },
    /// `DISubprogram`: a function.
    Subprogram {
        /// Its scope.
        scope: Option<MetadataId>,
        /// Its name.
        name: Option<MetadataId>,
        /// Its linkage (decorated) name.
        linkage_name: Option<MetadataId>,
        /// Its file.
        file: Option<MetadataId>,
        /// Its line.
        line: u32,
        /// Its type.
        ty: Option<MetadataId>,
        /// It is local to the compilation unit.
        local: bool,
        /// It is a definition.
        definition: bool,
        /// The line its body's scope starts at.
        scope_line: u32,
        /// The type holding its virtual table entry.
        containing_type: Option<MetadataId>,
        /// Its virtuality (`DW_VIRTUALITY_*`).
        virtuality: u32,
        /// Its index in the virtual table.
        virtual_index: u32,
        /// Its `DIFlag*` bits.
        flags: u32,
        /// It was optimized.
        optimized: bool,
        /// The function it describes (a value as metadata).
        function: Option<MetadataId>,
        /// Its template parameters.
        template_params: Option<MetadataId>,
        /// Its declaration.
        declaration: Option<MetadataId>,
        /// Its variables.
        variables: Option<MetadataId>,
    },
    /// `DILexicalBlock`: a block scope.
    LexicalBlock {
        /// The enclosing scope.
        scope: Option<MetadataId>,
        /// Its file.
        file: Option<MetadataId>,
        /// Its line.
        line: u32,
        /// Its column.
        column: u32,
    },
    /// `DILexicalBlockFile`: a part of a scope in another file.
    LexicalBlockFile {
        /// The enclosing scope.
        scope: Option<MetadataId>,
        /// Its file.
        file: Option<MetadataId>,
        /// Its discriminator.
        discriminator: u32,
    },
    /// `DINamespace`: a namespace.
    Namespace {
        /// The enclosing scope.
        scope: Option<MetadataId>,
        /// Its file.
        file: Option<MetadataId>,
        /// Its name.
        name: Option<MetadataId>,
        /// Its line.
        line: u32,
    },
    /// `DIModule`: a module of the source language.
    Module {
        /// The enclosing scope.
        scope: Option<MetadataId>,
        /// Its name.
        name: Option<MetadataId>,
        /// Its configuration macros.
        config_macros: Option<MetadataId>,
        /// Its include path.
        include_path: Option<MetadataId>,
        /// Its system root.
        isysroot: Option<MetadataId>,
    },
    /// `DITemplateTypeParameter`: a template's type parameter.
    TemplateType {
        /// Its name.
        name: Option<MetadataId>,
        /// Its type.
        ty: Option<MetadataId>,
    },
    /// `DITemplateValueParameter`: a template's value parameter.
    TemplateValue {
        /// Its DWARF tag.
        tag: u32,
        /// Its name.
        name: Option<MetadataId>,
        /// Its type.
        ty: Option<MetadataId>,
        /// Its value.
        value: Option<MetadataId>,
    },
    /// `DIGlobalVariable`: a global variable.
    GlobalVariable {
        /// Its scope.
        scope: Option<MetadataId>,
        /// Its name.
        name: Option<MetadataId>,
        /// Its linkage (decorated) name.
        linkage_name: Option<MetadataId>,
        /// Its file.
        file: Option<MetadataId>,
        /// Its line.
        line: u32,
        /// Its type.
        ty: Option<MetadataId>,
        /// It is local to the compilation unit.
        local: bool,
        /// It is a definition.
        definition: bool,
        /// The global it describes (a value as metadata).
        variable: Option<MetadataId>,
        /// A static data member's declaration.
        declaration: Option<MetadataId>,
    },
    /// `DILocalVariable`: a local variable or parameter.
    LocalVariable {
        /// Its DWARF tag (`DW_TAG_auto_variable` or `DW_TAG_arg_variable`).
        tag: u32,
        /// Its scope.
        scope: Option<MetadataId>,
        /// Its name.
        name: Option<MetadataId>,
        /// Its file.
        file: Option<MetadataId>,
        /// Its line.
        line: u32,
        /// Its type.
        ty: Option<MetadataId>,
        /// A parameter's position (from 1; 0 for a variable).
        arg: u32,
        /// Its `DIFlag*` bits.
        flags: u32,
    },
    /// `DIExpression`: how a variable's value is reached from what the debug intrinsic names: DWARF operations and their
    /// arguments, as stored.
    Expression(Vec<u64>),
    /// `DIObjCProperty`: an Objective-C property.
    ObjcProperty {
        /// Its name.
        name: Option<MetadataId>,
        /// Its file.
        file: Option<MetadataId>,
        /// Its line.
        line: u32,
        /// Its getter's name.
        getter: Option<MetadataId>,
        /// Its setter's name.
        setter: Option<MetadataId>,
        /// Its attributes.
        attributes: u32,
        /// Its type.
        ty: Option<MetadataId>,
    },
    /// `DIImportedEntity`: a `using` declaration or directive.
    ImportedEntity {
        /// Its DWARF tag.
        tag: u32,
        /// Its scope.
        scope: Option<MetadataId>,
        /// What it imports.
        entity: Option<MetadataId>,
        /// Its line.
        line: u32,
        /// Its name.
        name: Option<MetadataId>,
    },
}

/// An instruction's source location (`FUNC_CODE_DEBUG_LOC`): the fields of the `DILocation` it is.
#[derive(Clone, Copy, Debug, PartialEq, Eq, Hash)]
pub struct DebugLoc {
    /// The line.
    pub line: u32,
    /// The column (0 where the record's does not fit in 16 bits).
    pub column: u32,
    /// The scope.
    pub scope: Option<MetadataId>,
    /// The location it was inlined at.
    pub inlined_at: Option<MetadataId>,
}

/// An `unsigned` field of a record as LLVM reads it: the operand's low 32 bits.
pub(crate) fn unsigned(v: u64) -> u32 {
    u32::try_from(v & 0xFFFF_FFFF).unwrap_or(0)
}

/// LLVM's `adjustColumn`: a column of 16 bits or more is unknown.
pub(crate) fn column(column: u32) -> u32 {
    if column >= 1 << 16 { 0 } else { column }
}

impl DebugNode {
    /// The node's metadata operands in the order LLVM keeps them (`MDNode::operands`, which numbering the nodes of a
    /// listing walks), strings and null references included.
    pub fn operands(&self) -> Vec<Option<MetadataId>> {
        use DebugNode as N;
        match self {
            N::Location {
                scope, inlined_at, ..
            } => {
                let mut ops = vec![Some(*scope)];
                if inlined_at.is_some() {
                    ops.push(*inlined_at);
                }
                ops
            }
            N::Generic { header, operands, .. } => {
                let mut ops = vec![*header];
                ops.extend(operands);
                ops
            }
            N::Subrange { .. } | N::Expression(_) => Vec::new(),
            N::Enumerator { name, .. } => vec![*name],
            N::BasicType { name, .. } => vec![None, None, *name],
            N::DerivedType {
                file,
                scope,
                name,
                base_type,
                extra_data,
                ..
            } => {
                vec![*file, *scope, *name, *base_type, *extra_data]
            }
            N::CompositeType {
                file,
                scope,
                name,
                base_type,
                elements,
                vtable_holder,
                template_params,
                identifier,
                ..
            } => vec![
                *file,
                *scope,
                *name,
                *base_type,
                *elements,
                *vtable_holder,
                *template_params,
                *identifier,
            ],
            N::SubroutineType { types, .. } => vec![None, None, None, None, *types, None, None, None],
            N::File { filename, directory } => vec![*filename, *directory],
            N::CompileUnit {
                file,
                producer,
                flags,
                split_debug_filename,
                enums,
                retained_types,
                subprograms,
                globals,
                imports,
                ..
            } => vec![
                *file,
                *producer,
                *flags,
                *split_debug_filename,
                *enums,
                *retained_types,
                *subprograms,
                *globals,
                *imports,
            ],
            N::Subprogram {
                file,
                scope,
                name,
                linkage_name,
                ty,
                containing_type,
                function,
                template_params,
                declaration,
                variables,
                ..
            } => vec![
                *file,
                *scope,
                *name,
                *name,
                *linkage_name,
                *ty,
                *containing_type,
                *function,
                *template_params,
                *declaration,
                *variables,
            ],
            N::LexicalBlock { file, scope, .. } | N::LexicalBlockFile { file, scope, .. } => {
                vec![*file, *scope]
            }
            N::Namespace {
                file, scope, name, ..
            } => vec![*file, *scope, *name],
            N::Module {
                scope,
                name,
                config_macros,
                include_path,
                isysroot,
            } => {
                vec![*scope, *name, *config_macros, *include_path, *isysroot]
            }
            N::TemplateType { name, ty } => vec![*name, *ty],
            N::TemplateValue { name, ty, value, .. } => vec![*name, *ty, *value],
            N::GlobalVariable {
                scope,
                name,
                file,
                ty,
                linkage_name,
                variable,
                declaration,
                ..
            } => {
                vec![
                    *scope,
                    *name,
                    *file,
                    *ty,
                    *name,
                    *linkage_name,
                    *variable,
                    *declaration,
                ]
            }
            N::LocalVariable {
                scope,
                name,
                file,
                ty,
                ..
            } => vec![*scope, *name, *file, *ty],
            N::ObjcProperty {
                name,
                file,
                getter,
                setter,
                ty,
                ..
            } => vec![*name, *file, *getter, *setter, *ty],
            N::ImportedEntity {
                scope, entity, name, ..
            } => vec![*scope, *entity, *name],
        }
    }

    /// The scope a local variable or location names (`getScope`), for finding the subprogram it belongs to.
    pub fn scope(&self) -> Option<MetadataId> {
        use DebugNode as N;
        match self {
            N::Location { scope, .. } => Some(*scope),
            N::LexicalBlock { scope, .. }
            | N::LexicalBlockFile { scope, .. }
            | N::LocalVariable { scope, .. }
            | N::Subprogram { scope, .. } => *scope,
            _ => None,
        }
    }
}

/// Reads the debug-information metadata record `code` (`METADATA_LOCATION` 7, `METADATA_GENERIC_DEBUG` 12 to
/// `METADATA_MODULE` 32) of `ops` as dxc's bitcode reader does: whether the node is distinct (the first operand), and the
/// node. A record of another length than its kind's is refused, as the reader refuses it.
pub(crate) fn read(code: u32, ops: &[u64], at: usize) -> Result<(bool, DebugNode)> {
    let n = |i: usize| -> Result<u64> {
        ops.get(i)
            .copied()
            .ok_or_else(|| error(at, format!("metadata record {code} lacks operand {i}")))
    };
    let u = |i: usize| -> Result<u32> { n(i).map(unsigned) };
    let id = |v: u64| -> Result<MetadataId> { usize::try_from(v).map_err(|_| error(at, "metadata id")) };
    // `getMDOrNull`: the id plus one, or 0 for null
    let md = |i: usize| -> Result<Option<MetadataId>> {
        match n(i)? {
            0 => Ok(None),
            v => id(v.saturating_sub(1)).map(Some),
        }
    };
    let length = |want: &[usize]| -> Result<()> {
        if want.contains(&ops.len()) {
            Ok(())
        } else {
            Err(error(
                at,
                format!("metadata record {code} of {} operands", ops.len()),
            ))
        }
    };
    let distinct = n(0)? != 0;
    use DebugNode as N;
    let node = match code {
        7 => {
            length(&[5])?;
            N::Location {
                line: u(1)?,
                column: column(u(2)?),
                // the scope is not optional: its id is stored as is
                scope: id(n(3)?)?,
                inlined_at: md(4)?,
            }
        }
        12 => {
            if ops.len() < 4 {
                return Err(error(
                    at,
                    format!("metadata record {code} of {} operands", ops.len()),
                ));
            }
            let tag = u16::try_from(n(1)?).ok().filter(|_| n(2).is_ok_and(|v| v == 0));
            let Some(tag) = tag else {
                return Err(error(at, "a generic debug node of an unknown tag or version"));
            };
            N::Generic {
                tag: u32::from(tag),
                header: md(3)?,
                operands: (4..ops.len()).map(md).collect::<Result<_>>()?,
            }
        }
        13 => {
            length(&[3])?;
            N::Subrange {
                count: n(1)? as i64,
                lower_bound: unrotate(n(2)?),
            }
        }
        14 => {
            length(&[3])?;
            N::Enumerator {
                value: unrotate(n(1)?),
                name: md(2)?,
            }
        }
        15 => {
            length(&[6])?;
            N::BasicType {
                tag: u(1)?,
                name: md(2)?,
                size: n(3)?,
                align: n(4)?,
                encoding: u(5)?,
            }
        }
        17 => {
            length(&[12])?;
            N::DerivedType {
                tag: u(1)?,
                name: md(2)?,
                file: md(3)?,
                line: u(4)?,
                scope: md(5)?,
                base_type: md(6)?,
                size: n(7)?,
                align: n(8)?,
                offset: n(9)?,
                flags: u(10)?,
                extra_data: md(11)?,
            }
        }
        18 => {
            length(&[16])?;
            N::CompositeType {
                tag: u(1)?,
                name: md(2)?,
                file: md(3)?,
                line: u(4)?,
                scope: md(5)?,
                base_type: md(6)?,
                size: n(7)?,
                align: n(8)?,
                offset: n(9)?,
                flags: u(10)?,
                elements: md(11)?,
                runtime_lang: u(12)?,
                vtable_holder: md(13)?,
                template_params: md(14)?,
                identifier: md(15)?,
            }
        }
        19 => {
            length(&[3])?;
            N::SubroutineType {
                flags: u(1)?,
                types: md(2)?,
            }
        }
        32 => {
            length(&[6])?;
            N::Module {
                scope: md(1)?,
                name: md(2)?,
                config_macros: md(3)?,
                include_path: md(4)?,
                isysroot: md(5)?,
            }
        }
        16 => {
            length(&[3])?;
            N::File {
                filename: md(1)?,
                directory: md(2)?,
            }
        }
        20 => {
            length(&[14, 15])?;
            N::CompileUnit {
                language: u(1)?,
                file: md(2)?,
                producer: md(3)?,
                optimized: n(4)? != 0,
                flags: md(5)?,
                runtime_version: u(6)?,
                split_debug_filename: md(7)?,
                emission_kind: u(8)?,
                enums: md(9)?,
                retained_types: md(10)?,
                subprograms: md(11)?,
                globals: md(12)?,
                imports: md(13)?,
                dwo_id: ops.get(14).copied().unwrap_or(0),
            }
        }
        21 => {
            length(&[19])?;
            N::Subprogram {
                scope: md(1)?,
                name: md(2)?,
                linkage_name: md(3)?,
                file: md(4)?,
                line: u(5)?,
                ty: md(6)?,
                local: n(7)? != 0,
                definition: n(8)? != 0,
                scope_line: u(9)?,
                containing_type: md(10)?,
                virtuality: u(11)?,
                virtual_index: u(12)?,
                flags: u(13)?,
                optimized: n(14)? != 0,
                function: md(15)?,
                template_params: md(16)?,
                declaration: md(17)?,
                variables: md(18)?,
            }
        }
        22 => {
            length(&[5])?;
            N::LexicalBlock {
                scope: md(1)?,
                file: md(2)?,
                line: u(3)?,
                column: u(4)?,
            }
        }
        23 => {
            length(&[4])?;
            N::LexicalBlockFile {
                scope: md(1)?,
                file: md(2)?,
                discriminator: u(3)?,
            }
        }
        24 => {
            length(&[5])?;
            N::Namespace {
                scope: md(1)?,
                file: md(2)?,
                name: md(3)?,
                line: u(4)?,
            }
        }
        25 => {
            length(&[3])?;
            N::TemplateType {
                name: md(1)?,
                ty: md(2)?,
            }
        }
        26 => {
            length(&[5])?;
            N::TemplateValue {
                tag: u(1)?,
                name: md(2)?,
                ty: md(3)?,
                value: md(4)?,
            }
        }
        27 => {
            length(&[11])?;
            N::GlobalVariable {
                scope: md(1)?,
                name: md(2)?,
                linkage_name: md(3)?,
                file: md(4)?,
                line: u(5)?,
                ty: md(6)?,
                local: n(7)? != 0,
                definition: n(8)? != 0,
                variable: md(9)?,
                declaration: md(10)?,
            }
        }
        28 => {
            // a tenth operand is the obsolete `inlinedAt`, which the reader drops
            length(&[9, 10])?;
            N::LocalVariable {
                tag: u(1)?,
                scope: md(2)?,
                name: md(3)?,
                file: md(4)?,
                line: u(5)?,
                ty: md(6)?,
                arg: u(7)?,
                flags: u(8)?,
            }
        }
        29 => N::Expression(ops.get(1..).unwrap_or_default().to_vec()),
        30 => {
            length(&[8])?;
            N::ObjcProperty {
                name: md(1)?,
                file: md(2)?,
                line: u(3)?,
                getter: md(4)?,
                setter: md(5)?,
                attributes: u(6)?,
                ty: md(7)?,
            }
        }
        31 => {
            length(&[6])?;
            N::ImportedEntity {
                tag: u(1)?,
                scope: md(2)?,
                entity: md(3)?,
                line: u(4)?,
                name: md(5)?,
            }
        }
        other => {
            return Err(error(
                at,
                format!("metadata record {other} is not debug information"),
            ));
        }
    };
    Ok((distinct, node))
}

/// `unrotateSign`: a signed number stored with its sign in the low bit, the rest complemented for a negative one (the
/// metadata's encoding, not the instructions' `decodeSignRotatedValue`).
fn unrotate(v: u64) -> i64 {
    let magnitude = (v >> 1) as i64;
    if v & 1 == 0 { magnitude } else { !magnitude }
}

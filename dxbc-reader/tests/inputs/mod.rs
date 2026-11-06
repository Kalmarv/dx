//! The real-data inputs this crate's tests read, each with what it is, where it comes from and whether a full run
//! needs it (`primase_testdata::inputs!`; README.md here lists them). Integration tests reach it with `mod inputs;`,
//! and tests/real_data_inputs.rs checks that every query the crate's sources write is declared here.

primase_testdata::inputs! {
    games {
        Riders = "riders",
        Sekiro = "sekiro",
        Sledding = "sledding",
    }
    installs {}
    keys {}
    tools {}
    oracle_sets {
        D3dDisassembler = "d3d-disassembler" {
            about: "Microsoft's D3D shader disassembly of a game's shader programs: each program with its listing beside it",
            source: "independent: Microsoft d3dcompiler_47.dll D3DDisassemble, run over the user's own install",
        },
    }
    declared {
        Query::Oracle(OracleSet::D3dDisassembler, Game::Riders, "shader-pack") => {
            status: Live,
            gate: true,
            about: r#"the 2,443 Shader Model 5 programs of Riders Republic's shader pack (`NNNN.dxbc`), each with Microsoft's listing with no flags (`NNNN.txt`); tests/corpora.rs"#,
            source: r#"independent: Microsoft's D3D Shader Disassembler over the programs of the user's own Riders Republic install; programs and listings stay outside the repository"#,
        },
        Query::Oracle(OracleSet::D3dDisassembler, Game::Sekiro, "programs") => {
            status: Live,
            gate: true,
            about: r#"Sekiro's 432 Shader Model 5 programs (`NAME.ppo`, `NAME.vpo`), each with Microsoft's listing under no flags (`NAME.ppo.asm`) and 22 other flag words (`NAME.ppo.flagNN.asm`); tests/corpora.rs"#,
            source: r#"independent: d3dcompiler_47.dll 10.0.26100.4654 D3DDisassemble (primase-oracles tools/wine/d3d_disassemble.py) over the programs of the user's own Sekiro install; programs and listings stay outside the repository"#,
        },
        Query::Oracle(OracleSet::D3dDisassembler, Game::Sledding, "corpus-unity") => {
            status: Live,
            gate: true,
            about: r#"the 4,854 Shader Model 4.0 and 5.0 programs of Sledding Game's Unity player (`NNNNN.dxbc`), each with Microsoft's listing with no flags (`NNNNN.dxbc.asm`); 16 carry an SPDB part; tests/corpora.rs"#,
            source: r#"independent: d3dcompiler_47.dll 10.0.26100.4654 D3DDisassemble (primase-oracles tools/wine/d3d_disassemble.py) over the programs of the user's own Sledding Game install; programs and listings stay outside the repository"#,
        },
    }
    debug {}
}

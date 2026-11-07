//! The real-data inputs this crate's tests read, each with what it is, where it comes from and whether a full run
//! needs it (`primase_testdata::inputs!`; README.md here lists them). Integration tests reach it with `mod inputs;`,
//! and tests/real_data_inputs.rs checks that every query the crate's sources write is declared here.

primase_testdata::inputs! {
    games {
        General = "general",
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
        Query::Oracle(OracleSet::D3dDisassembler, Game::General, "fxc-sweep-zi") => {
            status: Live,
            gate: true,
            about: r#"the /Zi sweep's 4,613 programs (`NAME.dxbc`): fxc 10.0.26100.4654 `/Zi` builds of the HLSL in dxc's tests, vkd3d's and vkd3d-proton's shader tests and MiniEngine, each with Microsoft's listing under no flags (`NAME.dxbc.asm`) and 22 other flag words (`NAME.dxbc.flagNN.asm`); tests/corpora.rs"#,
            source: r#"independent: fxc and d3dcompiler_47.dll 10.0.26100.4654 D3DDisassemble (tests/inputs/fxc_sweep.py) over outside open-source HLSL, the commits in the set's MANIFEST.toml; programs and listings stay outside the repository"#,
        },
        Query::Oracle(OracleSet::D3dDisassembler, Game::General, "fxc-sweep-zod") => {
            status: Live,
            gate: true,
            about: r#"the /Zi sweep's 4,614 programs built with `/Zi /Od` (`NAME.dxbc`), as `fxc-sweep-zi` otherwise: each with Microsoft's listing under no flags and 22 other flag words; tests/corpora.rs"#,
            source: r#"independent: fxc and d3dcompiler_47.dll 10.0.26100.4654 D3DDisassemble (tests/inputs/fxc_sweep.py) over outside open-source HLSL, the commits in the set's MANIFEST.toml; programs and listings stay outside the repository"#,
        },
    }
    debug {}
}

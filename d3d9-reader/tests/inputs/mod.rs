//! The real-data inputs this crate's tests read, each with what it is, where it comes from and whether a full run
//! needs it (`primase_testdata::inputs!`; README.md here lists them). Integration tests reach it with `mod inputs;`,
//! and tests/real_data_inputs.rs checks that every query the crate's sources write is declared here.

primase_testdata::inputs! {
    games {
        General = "general",
        ShaunWhite = "shaun-white",
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
        Query::Oracle(OracleSet::D3dDisassembler, Game::General, "sm3") => {
            status: Live,
            gate: true,
            about: r#"a raw ps_3_0 program (`pixel.bin`) and two vs_3_0 ones (`vertex.bin`, `vertex-layered.bin`), each with Microsoft's listing with no flags (`.asm`); tests/corpora.rs"#,
            source: r#"independent: Microsoft d3dcompiler_47.dll D3DDisassemble on shipped Shaun White Skateboarding SDB2 programs; programs and listings stay outside the repository"#,
        },
        Query::Oracle(OracleSet::D3dDisassembler, Game::ShaunWhite, "sdb2") => {
            status: Live,
            gate: true,
            about: r#"every distinct vertex (`.vs`) and pixel (`.ps`) program of Shaun White Skateboarding's three SDB2 bundles, 7,306 in all, each with Microsoft's listing with no flags (`.vs.asm`, `.ps.asm`); tests/corpora.rs"#,
            source: r#"independent: Microsoft d3dcompiler_47.dll D3DDisassemble over the programs of the user's own Shaun White Skateboarding install; programs and listings stay outside the repository"#,
        },
    }
    debug {}
}

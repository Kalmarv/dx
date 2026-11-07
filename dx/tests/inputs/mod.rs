//! The real-data inputs this crate's tests read, each with what it is, where it comes from and whether a full run
//! needs it (`primase_testdata::inputs!`; README.md here lists them). Integration tests reach it with `mod inputs;`,
//! and tests/real_data_inputs.rs checks that every query the crate's sources write is declared here.

primase_testdata::inputs! {
    games {
        General = "general",
    }
    installs {}
    keys {}
    tools {}
    oracle_sets {
        Corpus = "corpus" {
            about: "shader programs gathered from outside sources, each with the listing Microsoft's tools write of it",
            source: "independent: open-source shader tests and the user's own installs; Microsoft's d3dcompiler_47.dll and dxc",
        },
    }
    declared {
        Query::Oracle(OracleSet::Corpus, Game::General, "slim") => {
            status: Live,
            gate: true,
            about: r#"the slim shader set: 8,287 programs (`programs/<family>/<sha256>.<family>`: 557 `d3d9`, 3,671 `dxbc`, 4,059 `dxil`) that reach every region and branch side of the readers the full pool of 108,000 does, each with Microsoft's listing beside it (`.d3d9.asm` and `.dxbc.asm` D3DDisassemble 10.0.26100.4654 with no flags, `.dxil.txt` dxc 1.9.2609 `-dumpbin`) but the 10 programs `microsoft-refused.tsv` names; tests/slim.rs"#,
            source: r#"independent: programs of open-source shader tests and of the user's own installs, listed by Microsoft's d3dcompiler_47.dll and dxc; programs and listings stay outside the repository"#,
        },
    }
    debug {}
}

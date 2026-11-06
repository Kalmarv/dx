//! The real-data inputs this crate's tests read, each with what it is, where it comes from and whether a full run
//! needs it (`primase_testdata::inputs!`; README.md here lists them). Integration tests reach it with `mod inputs;`,
//! and tests/real_data_inputs.rs checks that every query the crate's sources write is declared here.

primase_testdata::inputs! {
    games {
        Elden = "elden",
    }
    installs {}
    keys {}
    tools {}
    oracle_sets {
        Corpus = "corpus" {
            about: "a game's own files, copied out of its install unchanged",
            source: "the user's own install",
        },
        Dxc = "dxc" {
            about: "what Microsoft's DXC writes of a game's DXIL programs",
            source: "independent: Microsoft's DXC (Linux release) run over the programs of the user's own install",
        },
    }
    declared {
        Query::Oracle(OracleSet::Corpus, Game::Elden, "shaders") => {
            status: Live,
            gate: true,
            about: r#"Elden Ring's 50,283 DXIL programs (`.ppo`, `.vpo` and the other stages, nested by shader bundle), as the game stores them; tests/corpora.rs"#,
            source: r#"the user's own Elden Ring install; programs stay outside the repository"#,
        },
        Query::Oracle(OracleSet::Dxc, Game::Elden, "shader-listings") => {
            status: Live,
            gate: true,
            about: r#"dxc 1.9.2609's `-dumpbin` listing of each of Elden Ring's 50,283 programs (`<path>.txt`, mirroring `oracles.corpus.elden/shaders`); tests/corpora.rs"#,
            source: r#"independent: Microsoft's DXC 1.9.2609 Linux release (primase-oracles tools/dxc/dumpbin_tree.py) over the programs of the user's own Elden Ring install; programs and listings stay outside the repository"#,
        },
    }
    debug {}
}

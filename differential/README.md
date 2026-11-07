# Differential against D3DDisassemble

dx's listings against Microsoft's disassembler (`D3DDisassemble` in `d3dcompiler_47.dll`, Windows SDK 10.0.26100.4654)
on programs nobody wrote by hand: compiled programs with a few words of bytecode edited and the container's digest
redone, and random HLSL compiled by `D3DCompile`. Where the fixtures and the corpora test the programs that exist, this
finds the rules of Microsoft's listing that only odd or broken programs reach. It needs Windows, Microsoft's DLL and
Python 3; it is not part of CI.

| file | does |
|---|---|
| `differ.py` | one batch: makes the programs, lists them with Microsoft's disassembler under every flags word (each in a worker process, so a program that crashes or hangs it is set aside) and with `dxlist`, and keeps each program where they differ |
| `hlslgen.py` | random well-typed HLSL for Direct3D 9, feature level 9 and Shader Models 4 and 5 |
| `dxbc_hash.py` | the digest a DXBC container stores, to redo after an edit |
| `dxlist/` | dx's listings of a folder of programs under every flags word (a workspace member, so CI builds it) |
| `report.py` | the report of a run's batches; exits 1 when one found something to fix |
| `recheck.py` | lists a run's kept findings again with the current `dxlist` and prints those that still differ |
| `weekly.sh` | the weekly run |

```sh
bash differential/weekly.sh                 # 5 batches of 1,500 edited programs, about 25 minutes
python -I differential/differ.py edit --kinds control --cases 500 --seed 7 --out runs/manual
python -I differential/differ.py hlsl --cases 200 --seed 7 --out runs/manual
python -I differential/recheck.py runs/manual
```

`$DX_D3DCOMPILER` names another `d3dcompiler_47.dll`. A batch writes its programs and both listings to
`OUT/batch-<mode>-<seed>/`, each program that differs to `OUT/findings/<kind>/` with the edit or source that made it,
the programs that crashed or hung Microsoft's disassembler to `OUT/microsoft-crashes/` and `OUT/microsoft-hangs/`, and
a line of counts to `OUT/summary.jsonl`. An edit starts from the programs committed in the readers' tests, and from
those of earlier `hlsl` batches in the same `OUT`.

## What a difference means

- A listing that differs (`line_*`), a panic (`dx_panics`), or a program dx lists where Microsoft's disassembler
  refuses it: something to fix. Minimise the program to a fixture under `dxbc-reader/tests/disasm` or
  `d3d9-reader/tests/disasm` (the HLSL beside it, the listings from `generate.py`), fix the reader, and release the
  fixes together in a patch.
- dx refusing a program Microsoft's disassembler lists anyway (`refused_*`): dx keeps these refusals. They are programs
  no compiler writes (an operand token without its bit 31, an instruction longer than the program, an index form that
  does not exist), which Microsoft's disassembler lists by reading what is there, or past it.

## The weekly run

`weekly.sh` runs one batch for each kind of edit (`swizzle`, `control`, `immediate`, `byte`, `special`), seeded by
the date, and keeps the report, the summary, the findings to fix and the programs that crashed or hung Microsoft's
disassembler under `$DX_DIFF_STORE/<date>/` (default `differential/runs/`, ignored by git); `$DX_DIFF_STORE/latest.md`
is the last report. It exits 1 when a batch found something to fix and 2 when the run itself failed. Run it before
every minor release as well.

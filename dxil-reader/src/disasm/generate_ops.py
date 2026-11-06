"""Write `ops.rs`: the name and operand list dxc's listing gives each DXIL operation, from dxc's own database.

dxc builds the table its disassembler annotates calls with (`; Sample(srv,sampler,...)`) from `utils/hct/hctdb.py`
when it compiles; this runs the same functions (`get_db_dxil`, and the operands as `get_opsigs` lists them) over a
dxc source tree at the release the listings are compared with.

    python -I generate_ops.py --source <DirectXShaderCompiler checkout at v1.9.2609>
"""
import argparse, os, subprocess, sys

TAG = "v1.9.2609"
HERE = os.path.dirname(os.path.abspath(__file__))


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--source", required=True, help="a DirectXShaderCompiler checkout at " + TAG)
    a = ap.parse_args()
    described = subprocess.run(["git", "-C", a.source, "describe", "--tags", "--exact-match"],
                               capture_output=True, text=True).stdout.strip()
    if described != TAG:
        sys.exit(f"the checkout is at {described or 'no tag'!r}, not {TAG}")
    sys.path.insert(0, os.path.join(os.path.abspath(a.source), "utils", "hct"))
    import hctdb_instrhelp

    db = hctdb_instrhelp.get_db_dxil()
    out = [
        f"//! Written by `generate_ops.py` from dxc's operation database at {TAG}; do not edit.",
        "//! Each table lists, by operation index, the name and the operands (after the opcode) dxc's listing annotates a",
        "//! call with.",
        "",
    ]
    tables = []
    for table in db.op_tables:
        rows = []
        for i in table:
            ops = ",".join(o.name for o in i.ops if o.pos > 1)
            rows.append(f'    ("{i.name}", "({ops})"),')
        const = "".join("_" + c if c.isupper() and n else c for n, c in enumerate(table.name)).upper()
        tables.append((table.id, const))
        out.append(f"/// The `{table.name}` table (table id {table.id:#x}, the opcode's upper 16 bits).")
        out.append(f"pub(crate) const {const}: [(&str, &str); {len(rows)}] = [")
        out.extend(rows)
        out.append("];")
        out.append("")
    out.append("/// The name and operands of an encoded opcode (the table id in its upper 16 bits, the index in the lower), where")
    out.append("/// dxc's tables have it.")
    out.append("pub(crate) fn operation(opcode: u32) -> Option<(&'static str, &'static str)> {")
    out.append("    let index = usize::try_from(opcode & 0xFFFF).ok()?;")
    out.append("    match opcode >> 16 {")
    for id_, const in tables:
        out.append(f"        {id_:#x} => {const}.get(index).copied(),")
    out.append("        _ => None,")
    out.append("    }")
    out.append("}")
    with open(os.path.join(HERE, "ops.rs"), "w", newline="\n") as f:
        f.write("\n".join(out) + "\n")
    print(", ".join(f"{t.name} {len(list(t))}" for t in db.op_tables))


if __name__ == "__main__":
    main()

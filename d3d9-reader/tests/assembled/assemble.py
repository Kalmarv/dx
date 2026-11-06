"""Microsoft's D3DAssemble and D3DDisassemble over every <name>.asm here (a Windows Python: on Windows, or under Wine).

    python -I assemble.py d3dcompiler_47.dll

Writes <name>.bin (the token stream), <name>.asm.ms (D3DDisassemble's listing with no flags) and <name>.flag04.ms
(with D3D_DISASM_ENABLE_INSTRUCTION_NUMBERING), each listing without the blob's trailing zero byte; a source the
assembler refuses gets <name>.err with its messages. ../assembled.rs compares the disassembler with the listings. The
listings were made with d3dcompiler_47 10.0.26100.4654 (the Windows SDK's) under Wine 9.0.
"""
import ctypes
import sys
from pathlib import Path

compiler = ctypes.WinDLL(sys.argv[1])
blob_p = ctypes.POINTER(ctypes.c_void_p)
compiler.D3DAssemble.argtypes = [
    ctypes.c_void_p, ctypes.c_size_t, ctypes.c_char_p, ctypes.c_void_p, ctypes.c_void_p, ctypes.c_uint,
    blob_p, blob_p,
]
compiler.D3DAssemble.restype = ctypes.c_long
compiler.D3DDisassemble.argtypes = [ctypes.c_void_p, ctypes.c_size_t, ctypes.c_uint, ctypes.c_char_p, blob_p]
compiler.D3DDisassemble.restype = ctypes.c_long


def take(blob):
    """The bytes of an ID3DBlob, which is then released."""
    if not blob:
        return b""
    table = ctypes.cast(blob, ctypes.POINTER(ctypes.POINTER(ctypes.c_void_p))).contents
    try:
        pointer = ctypes.WINFUNCTYPE(ctypes.c_void_p, ctypes.c_void_p)(table[3])(blob)
        size = ctypes.WINFUNCTYPE(ctypes.c_size_t, ctypes.c_void_p)(table[4])(blob)
        return ctypes.string_at(pointer, size)
    finally:
        ctypes.WINFUNCTYPE(ctypes.c_ulong, ctypes.c_void_p)(table[2])(blob)


here = Path(__file__).resolve().parent
for source in sorted(here.glob("*.asm")):
    for written in (".bin", ".asm.ms", ".flag04.ms", ".err"):
        source.with_name(source.stem + written).unlink(missing_ok=True)
    text = source.read_bytes()
    shader, messages = ctypes.c_void_p(), ctypes.c_void_p()
    result = compiler.D3DAssemble(text, len(text), source.name.encode(), None, None, 0,
                                  ctypes.byref(shader), ctypes.byref(messages))
    errors = take(messages)
    if result < 0:
        source.with_name(source.stem + ".err").write_bytes(errors or f"{result & 0xffffffff:#x}".encode())
        continue
    tokens = take(shader)
    source.with_name(source.stem + ".bin").write_bytes(tokens)
    for flags, ending in ((0, ".asm.ms"), (0x04, ".flag04.ms")):
        listing = ctypes.c_void_p()
        if compiler.D3DDisassemble(tokens, len(tokens), flags, None, ctypes.byref(listing)) >= 0:
            source.with_name(source.stem + ending).write_bytes(take(listing).rstrip(b"\0"))

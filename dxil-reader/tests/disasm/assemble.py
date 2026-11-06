"""assemble.py DXCOMPILER_DLL IN.ll OUT.dxil: assembles LLVM IR text into a DXIL container with dxcompiler.dll's
IDxcAssembler (AssembleToContainer), printing the error text where it fails. The assembler leaves the container's digest
zero; it is written as the validator writes it (`dxcontainer::checksum`), as every committed fixture stores it.
`assemble.py --check FILE...` instead tells whether each container stores the digest this computes."""
import ctypes, struct, sys
from ctypes import POINTER, byref, c_uint32, c_void_p, c_long, c_size_t

MASK = 0xFFFFFFFF
SHIFTS = [7, 12, 17, 22] * 4 + [5, 9, 14, 20] * 4 + [4, 11, 16, 23] * 4 + [6, 10, 15, 21] * 4
SINES = [int(abs(__import__("math").sin(i + 1)) * 2**32) & MASK for i in range(64)]


def md5_block(state, block):
    """MD5's block function (RFC 1321) over one 64-byte block."""
    x = struct.unpack("<16I", block)
    a, b, c, d = state
    for i in range(64):
        if i < 16:
            f, g = (b & c) | (~b & d), i
        elif i < 32:
            f, g = (d & b) | (~d & c), (5 * i + 1) % 16
        elif i < 48:
            f, g = b ^ c ^ d, (3 * i + 5) % 16
        else:
            f, g = c ^ (b | ~d & MASK), (7 * i) % 16
        f = (f + a + SINES[i] + x[g]) & MASK
        a, d, c = d, c, b
        b = (b + ((f << SHIFTS[i]) | (f >> (32 - SHIFTS[i])))) & MASK
    return [(s + v) & MASK for s, v in zip(state, (a, b, c, d))]


def checksum(container):
    """The digest of bytes 4 to 20, as `dxcontainer::checksum` computes it: MD5's block function over the bytes from 20
    on, the last block holding the bit count first, the rest, 0x80, zeros, and at 60 the bit count over 4, or 1 (a rest
    of 56 bytes or more padded in a block of its own first)."""
    data = container[20:]
    bits = (len(data) * 8) & MASK
    state = [0x67452301, 0xEFCDAB89, 0x98BADCFE, 0x10325476]
    whole = len(data) - len(data) % 64
    for at in range(0, whole, 64):
        state = md5_block(state, data[at:at + 64])
    rest = data[whole:]
    last = bytearray(64)
    if len(rest) < 56:
        last[4:4 + len(rest)] = rest
        last[4 + len(rest)] = 0x80
    else:
        first = bytearray(64)
        first[:len(rest)] = rest
        first[len(rest)] = 0x80
        state = md5_block(state, bytes(first))
    last[0:4] = struct.pack("<I", bits)
    last[60:64] = struct.pack("<I", (bits >> 2) | 1)
    state = md5_block(state, bytes(last))
    return struct.pack("<4I", *state)


if sys.argv[1] == "--check":
    for path in sys.argv[2:]:
        b = open(path, "rb").read()
        print("ok" if b[4:20] == checksum(b) else "DIFFERS", path)
    sys.exit(0)

dll_path, src, dst = sys.argv[1:4]


class GUID(ctypes.Structure):
    _fields_ = [("a", ctypes.c_uint32), ("b", ctypes.c_uint16), ("c", ctypes.c_uint16), ("d", ctypes.c_ubyte * 8)]


def guid(s):
    import uuid
    u = uuid.UUID(s)
    g = GUID()
    g.a, g.b, g.c = u.fields[0], u.fields[1], u.fields[2]
    for i, b in enumerate(u.bytes[8:]):
        g.d[i] = b
    return g


CLSID_DxcUtils = guid("6245d6af-66e0-48fd-80b4-4d271796748c")
IID_IDxcUtils = guid("4605C4CB-2019-492A-ADA4-65F20BB7D67F")
CLSID_DxcAssembler = guid("d728db68-f903-4f80-94cd-dccf76ec7151")
IID_IDxcAssembler = guid("091f7a26-1c1f-4948-904b-e6e3a8a771d5")

dll = ctypes.WinDLL(dll_path)
create = dll.DxcCreateInstance
create.argtypes = [POINTER(GUID), POINTER(GUID), POINTER(c_void_p)]
create.restype = c_long


def method(obj, index, restype, *argtypes):
    vt = ctypes.cast(obj, POINTER(POINTER(c_void_p))).contents
    return ctypes.WINFUNCTYPE(restype, c_void_p, *argtypes)(vt[index])


utils, asm = c_void_p(), c_void_p()
assert create(byref(CLSID_DxcUtils), byref(IID_IDxcUtils), byref(utils)) == 0
assert create(byref(CLSID_DxcAssembler), byref(IID_IDxcAssembler), byref(asm)) == 0
text = open(src, "rb").read()
buf = ctypes.create_string_buffer(text, len(text))
blob = c_void_p()
# IDxcUtils::CreateBlobFromPinned(data, size, codePage, IDxcBlobEncoding**): code page 65001 (UTF-8)
hr = method(utils, 4, c_long, c_void_p, c_uint32, c_uint32, POINTER(c_void_p))(utils, buf, len(text), 65001, byref(blob))
assert hr == 0, hex(hr & 0xFFFFFFFF)
result = c_void_p()
# IDxcAssembler::AssembleToContainer(IDxcBlob*, IDxcOperationResult**)
hr = method(asm, 3, c_long, c_void_p, POINTER(c_void_p))(asm, blob, byref(result))
assert hr == 0, hex(hr & 0xFFFFFFFF)
status = c_long()
method(result, 3, c_long, POINTER(c_long))(result, byref(status))
if status.value != 0:
    err = c_void_p()
    method(result, 5, c_long, POINTER(c_void_p))(result, byref(err))
    ptr = method(err, 3, c_void_p)(err)
    size = method(err, 4, c_size_t)(err)
    print("assembly failed:", ctypes.string_at(ptr, size).decode(errors="replace"))
    sys.exit(1)
out = c_void_p()
method(result, 4, c_long, POINTER(c_void_p))(result, byref(out))
ptr = method(out, 3, c_void_p)(out)
size = method(out, 4, c_size_t)(out)
container = bytearray(ctypes.string_at(ptr, size))
container[4:20] = checksum(bytes(container))
open(dst, "wb").write(bytes(container))
print(f"{dst}: {size} bytes")

"""The digest a DXBC container stores at bytes 4 to 20 (MD5's block function with the compiler's padding), to re-hash
an edited container so D3DDisassemble reads it."""
import math, struct

_S = [7, 12, 17, 22] * 4 + [5, 9, 14, 20] * 4 + [4, 11, 16, 23] * 4 + [6, 10, 15, 21] * 4
_K = [int(abs(math.sin(i + 1)) * 2**32) & 0xFFFFFFFF for i in range(64)]
_INIT = (0x67452301, 0xEFCDAB89, 0x98BADCFE, 0x10325476)


def _block(state, block):
    m = struct.unpack("<16I", block)
    a, b, c, d = state
    for i in range(64):
        if i < 16:
            f, g = (b & c) | (~b & d), i
        elif i < 32:
            f, g = (d & b) | (~d & c), (5 * i + 1) % 16
        elif i < 48:
            f, g = b ^ c ^ d, (3 * i + 5) % 16
        else:
            f, g = c ^ (b | ~d), (7 * i) % 16
        f = (f + a + _K[i] + m[g]) & 0xFFFFFFFF
        a, d, c = d, c, b
        b = (b + ((f << _S[i]) | (f >> (32 - _S[i])))) & 0xFFFFFFFF
    return tuple((x + y) & 0xFFFFFFFF for x, y in zip(state, (a, b, c, d)))


def digest(container: bytes) -> bytes:
    data = container[20:]
    bits = (len(data) * 8) & 0xFFFFFFFF
    whole = len(data) - len(data) % 64
    state = _INIT
    for at in range(0, whole, 64):
        state = _block(state, data[at:at + 64])
    rest = data[whole:]
    last = bytearray(64)
    if len(rest) < 56:
        last[4:4 + len(rest)] = rest
        last[4 + len(rest)] = 0x80
    else:
        first = bytearray(64)
        first[:len(rest)] = rest
        first[len(rest)] = 0x80
        state = _block(state, bytes(first))
    last[0:4] = struct.pack("<I", bits)
    last[60:64] = struct.pack("<I", (bits >> 2) | 1)
    state = _block(state, bytes(last))
    return struct.pack("<4I", *state)


def rehash(container: bytes) -> bytes:
    return container[:4] + digest(container) + container[20:]


if __name__ == "__main__":
    import glob, sys
    files = [f for d in sys.argv[1:] for f in glob.glob(d + "/*.dx*")]
    bad = [f for f in files if digest(open(f, "rb").read()) != open(f, "rb").read()[4:20]]
    print(f"{len(files) - len(bad)} of {len(files)} stored digests match", bad[:5])

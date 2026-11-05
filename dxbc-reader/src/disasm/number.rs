//! Numbers as Microsoft's disassembler writes them: floats with C's `%f` (MSVC's spelling of infinities and NaNs),
//! integers in decimal up to ten thousand either way and as eight hex digits beyond, and typeless values by what their
//! bits look like.

/// How an instruction's immediate values are written.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub(crate) enum Style {
    /// By what the bits look like: an integer where they are a zero, a denormal, an infinity or a NaN as a float, a
    /// float otherwise (`mov`, `movc`, the addresses of loads).
    Typeless,
    /// As floats.
    Float,
    /// As integers.
    Integer,
}

/// One 32-bit value in `style`.
pub(crate) fn value(bits: u32, style: Style) -> String {
    match style {
        Style::Float => float(bits),
        Style::Integer => integer(bits),
        Style::Typeless => {
            let exponent = (bits >> 23) & 0xff;
            // -0.0 is written as a float
            if (exponent == 0 || exponent == 0xff) && bits != 0x8000_0000 {
                integer(bits)
            } else {
                float(bits)
            }
        }
    }
}

/// A 32-bit integer: decimal from -10000 to 10000, its 32 bits in hex beyond.
pub(crate) fn integer(bits: u32) -> String {
    let signed = bits.cast_signed();
    if (-10000..=10000).contains(&signed) {
        signed.to_string()
    } else {
        format!("0x{bits:08x}")
    }
}

/// A 32-bit float as `%f` writes it.
pub(crate) fn float(bits: u32) -> String {
    let value = f32::from_bits(bits);
    special(value.is_nan(), value.is_infinite(), bits >> 31 != 0, bits == 0xffc0_0000)
        .unwrap_or_else(|| format!("{:.6}", f64::from(value)))
}

/// A 64-bit float as `%f` writes it, with the `l` suffix of a double literal.
pub(crate) fn double(low: u32, high: u32) -> String {
    let bits = (u64::from(high) << 32) | u64::from(low);
    let value = f64::from_bits(bits);
    let text = special(
        value.is_nan(),
        value.is_infinite(),
        high >> 31 != 0,
        bits == 0xfff8_0000_0000_0000,
    )
    .unwrap_or_else(|| format!("{value:.6}"));
    format!("{text}l")
}

/// MSVC's `%f` of an infinity or a NaN: `1.#INF00`, `-1.#IND00` (the default NaN), `1.#QNAN0`.
fn special(nan: bool, infinite: bool, negative: bool, indefinite: bool) -> Option<String> {
    let sign = if negative { "-" } else { "" };
    if infinite {
        Some(format!("{sign}1.#INF00"))
    } else if indefinite {
        Some("-1.#IND00".to_owned())
    } else if nan {
        Some(format!("{sign}1.#QNAN0"))
    } else {
        None
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn floats_and_integers() {
        assert_eq!(float(0x3f80_0000), "1.000000");
        assert_eq!(float(0x7149_f2ca), "1000000015047466219876688855040.000000");
        assert_eq!(float(0x8000_0000), "-0.000000");
        assert_eq!(float(0x7f80_0000), "1.#INF00");
        assert_eq!(integer(0xffff_fc7c), "-900");
        assert_eq!(integer(10001), "0x00002711");
        assert_eq!(value(0x8000_0000, Style::Typeless), "-0.000000");
        assert_eq!(value(1, Style::Typeless), "1");
        assert_eq!(value(0x3f00_0000, Style::Typeless), "0.500000");
    }
}

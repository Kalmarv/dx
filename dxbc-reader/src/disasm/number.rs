//! Numbers as Microsoft's disassembler writes them: floats with C's `%f` (MSVC's spelling of infinities and NaNs),
//! integers in decimal up to ten thousand either way and as eight hex digits beyond, and typeless values by what their
//! bits look like.

/// How an instruction's immediate values are written.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub(crate) enum Style {
    /// By what the bits look like: an integer where they are a zero, a denormal, an infinity or a NaN as a float, a
    /// float otherwise (the addresses of loads), with a space after each comma.
    Typeless,
    /// As [`Style::Typeless`], with no space after the commas: the values a move or a store copies (`mov`, `movc`,
    /// `store_structured`, ...) and a debug message's operands.
    Data,
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
        Style::Typeless | Style::Data => {
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
    // `%f` takes the float as a double, and widening it quiets a signaling NaN
    let class = if value.is_infinite() {
        Class::Infinite
    } else if bits == 0xffc0_0000 {
        Class::Indefinite
    } else if value.is_nan() {
        Class::Quiet
    } else {
        Class::Finite
    };
    special(class, bits >> 31 != 0).unwrap_or_else(|| format!("{:.6}", f64::from(value)))
}

/// A 64-bit float as `%f` writes it, with the `l` suffix of a double literal.
pub(crate) fn double(low: u32, high: u32) -> String {
    let bits = (u64::from(high) << 32) | u64::from(low);
    let value = f64::from_bits(bits);
    let class = if value.is_infinite() {
        Class::Infinite
    } else if bits == 0xfff8_0000_0000_0000 {
        Class::Indefinite
    } else if value.is_nan() && bits & (1 << 51) == 0 {
        Class::Signaling
    } else if value.is_nan() {
        Class::Quiet
    } else {
        Class::Finite
    };
    let text = special(class, high >> 31 != 0).unwrap_or_else(|| format!("{value:.6}"));
    format!("{text}l")
}

/// What kind of value a float is, for its spelling.
enum Class {
    Finite,
    Infinite,
    /// The default NaN, negative with only the quiet bit set.
    Indefinite,
    /// A NaN with the quiet bit (the mantissa's highest) set.
    Quiet,
    /// A NaN with the quiet bit clear.
    Signaling,
}

/// MSVC's `%f` of an infinity or a NaN: `1.#INF00`, `-1.#IND00` (the default NaN), `1.#QNAN0`, `1.#SNAN0`; `None` for
/// a finite value.
fn special(class: Class, negative: bool) -> Option<String> {
    let sign = if negative { "-" } else { "" };
    match class {
        Class::Finite => None,
        Class::Infinite => Some(format!("{sign}1.#INF00")),
        Class::Indefinite => Some("-1.#IND00".to_owned()),
        Class::Quiet => Some(format!("{sign}1.#QNAN0")),
        Class::Signaling => Some(format!("{sign}1.#SNAN0")),
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

    #[test]
    fn doubles_keep_a_signaling_nan() {
        // Microsoft's listings of tests/disasm/double_specials.hlsl
        assert_eq!(double(0, 0xfff0_0000), "-1.#INF00l");
        assert_eq!(double(0, 0x7ff0_0000), "1.#INF00l");
        assert_eq!(double(1, 0x7ff0_0001), "1.#SNAN0l");
        assert_eq!(double(1, 0xfff0_0001), "-1.#SNAN0l");
        assert_eq!(double(0, 0xfff8_0000), "-1.#IND00l");
        assert_eq!(double(5, 0x7ff8_0000), "1.#QNAN0l");
        assert_eq!(double(5, 0xfff8_0000), "-1.#QNAN0l");
    }
}

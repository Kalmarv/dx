// Locals declared through typedefs: Microsoft's disassembler follows one alias in the debug information to the type
// it names, but finds no length for an alias of an alias, so a location of a variable of more than one value typed by
// one is named by the variable alone with its internal error, and one of a single value by the variable alone without
// one (vkd3d's type-names test).
// fxc: /T ps_5_0 /E main /Zi /Od /Fo zi_typedefs.ps50.zod.dxbc
typedef float2 pair;
typedef float single;
typedef const pair fixed_pair;
typedef const float2 const_pair;
float4 main(float4 a : A) : sv_target
{
    typedef pair twin;
    typedef single one;
    twin v1 = a.xy * 2;
    pair v2 = a.zw + 1;
    single v3 = a.x * a.w;
    one v4 = a.y * a.z;
    const pair v5 = a.yx * 3;
    const twin v6 = a.wz * 4;
    fixed_pair v7 = a.xz * 5;
    const_pair v8 = a.zx * 6;
    return float4(v1.x + v5.y, v2.y + v6.x, v1.y + v2.x + v7.x, v3 + v4 + v5.x + v6.y + v7.y + v8.x * v8.y);
}

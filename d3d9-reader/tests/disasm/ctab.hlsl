// The constant table's Parameters list: texture objects (Texture1D to TextureCube, each with the sampler it is read
// with), structs first, between and last in the list, nested and in an array, and 74 float4s, whose types and classes
// generate.py's PATCHED sets to every value (ctab.types.ps30).
// fxc: /T ps_3_0 /E main /D TEXTURES /Fo ctab.textures.ps30.bin
// fxc: /T ps_3_0 /E main /D STRUCTS /Fo ctab.structs.ps30.bin
// fxc: /T ps_3_0 /E main /D NESTED /Fo ctab.nested.ps30.bin
// fxc: /T ps_3_0 /E main /D MANY /Fo ctab.many.ps30.bin
struct inner { float2 p; float q; };
struct outer { inner first; float mid; inner last; };
struct plain { float4 a; float b; };
#if defined(TEXTURES)
SamplerState s1;
SamplerState s2;
SamplerState s3;
SamplerState s4;
Texture1D t1;
Texture2D t2;
Texture3D t3;
TextureCube t4;
float4 main(float4 uv : TEXCOORD0) : COLOR
{
    return t1.Sample(s1, uv.x) + t2.Sample(s2, uv.xy) + t3.Sample(s3, uv.xyz) + t4.Sample(s4, uv.xyz);
}
#elif defined(STRUCTS)
plain a_first;
float4 b_mid;
plain c_struct;
plain d_struct;
float4 e_last;
plain f_last;
float4 main() : COLOR { return a_first.a + b_mid + c_struct.b + d_struct.a + e_last + f_last.a; }
#elif defined(NESTED)
outer a_nested;
plain b_array[2];
float4 main() : COLOR { return a_nested.first.p.xyxy + a_nested.mid + a_nested.last.q + b_array[0].a + b_array[1].b; }
#elif defined(MANY)
float4 t00;
float4 t01;
float4 t02;
float4 t03;
float4 t04;
float4 t05;
float4 t06;
float4 t07;
float4 t08;
float4 t09;
float4 t10;
float4 t11;
float4 t12;
float4 t13;
float4 t14;
float4 t15;
float4 t16;
float4 t17;
float4 t18;
float4 t19;
float4 t20;
float4 t21;
float4 t22;
float4 t23;
float4 t24;
float4 t25;
float4 t26;
float4 t27;
float4 t28;
float4 t29;
float4 t30;
float4 t31;
float4 t32;
float4 t33;
float4 t34;
float4 t35;
float4 t36;
float4 t37;
float4 t38;
float4 t39;
float4 t40;
float4 t41;
float4 t42;
float4 t43;
float4 t44;
float4 t45;
float4 t46;
float4 t47;
float4 t48;
float4 t49;
float4 t50;
float4 t51;
float4 t52;
float4 t53;
float4 t54;
float4 t55;
float4 t56;
float4 t57;
float4 t58;
float4 t59;
float4 t60;
float4 t61;
float4 t62;
float4 t63;
float4 t64;
float4 t65;
float4 t66;
float4 t67;
float4 t68;
float4 t69;
float4 t70;
float4 t71;
float4 t72;
float4 t73;
float4 main() : COLOR { return t00 + t01 + t02 + t03 + t04 + t05 + t06 + t07 + t08 + t09 + t10 + t11 + t12 + t13 + t14 + t15 + t16 + t17 + t18 + t19 + t20 + t21 + t22 + t23 + t24 + t25 + t26 + t27 + t28 + t29 + t30 + t31 + t32 + t33 + t34 + t35 + t36 + t37 + t38 + t39 + t40 + t41 + t42 + t43 + t44 + t45 + t46 + t47 + t48 + t49 + t50 + t51 + t52 + t53 + t54 + t55 + t56 + t57 + t58 + t59 + t60 + t61 + t62 + t63 + t64 + t65 + t66 + t67 + t68 + t69 + t70 + t71 + t72 + t73; }
#endif

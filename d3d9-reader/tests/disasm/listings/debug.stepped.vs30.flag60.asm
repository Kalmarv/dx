    vs_3_0
0x000002E4:     dcl_position v0  // p<0,1,2,3>
0x000002F0:     dcl_position o0

#line 30 "C:\dx9-fixtures\debug.hlsl"
0x000002FC:     mov r0, c0  // ::k<0,1,2,3>
0x00000308:     mad r1, v0.yzwx, r0.yzwx, c3  // ::h2<1,2,3,0>

#line 37
0x0000031C:     mov r2, c2  // ::m<0,1,2,3>
0x00000328:     mad r1, r1, r2.zwxy, c1.yzwx  // ::o<1,2,3,0>

#line 42
0x0000033C:     mad r0, r1, c1.zwxy, -r0.wxyz  // ::o<1,2,3,0>

#line 4 "C:\dx9-fixtures\debug.hlsli"
0x00000350:     mul r0, r0.wxyz, r0  // ::twist<0,1,2,3>

#line 45 "C:\dx9-fixtures\debug.hlsl"
0x00000360:     mad o0, r0, r2, c3  // ::stepped<0,1,2,3>

// approximately 7 instruction slots used

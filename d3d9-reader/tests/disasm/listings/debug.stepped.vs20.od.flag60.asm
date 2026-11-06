    vs_2_0
0x000003C8:     dcl_position v0  // p<0,1,2,3>

#line 33 "C:\dx9-fixtures\debug.hlsl"
0x000003D4:     mul r0, v0.yzwx, c0.yzwx  // ::o<1,2,3,0>
0x000003E4:     nop
0x000003E8:     mov r0, r0  // h2::v<1,2,3,0>

#line 30
0x000003F4:     add r0, r0, c3  // ::h2<1,2,3,0>

#line 34
0x00000404:     mov r0, r0  // ::o<1,2,3,0>
0x00000410:     nop
0x00000414:     mov r0, r0  // h1::v<1,2,3,0>

#line 28
0x00000420:     mul r0, r0, c2.zwxy  // ::h1<1,2,3,0>

#line 35
0x00000430:     mov r0, r0  // ::o<1,2,3,0>
0x0000043C:     add r0, r0, c1.yzwx  // ::o<1,2,3,0>
0x0000044C:     mul r0, r0, c1.zwxy  // ::o<1,2,3,0>

#line 42
0x0000045C:     mov r1, -c0.wxyz
0x00000468:     add r0, r0, r1  // ::o<1,2,3,0>
0x00000478:     nop
0x0000047C:     mov r0, r0  // twist::v<1,2,3,0>

#line 4 "C:\dx9-fixtures\debug.hlsli"
0x00000488:     mul r0, r0.wxyz, r0  // ::twist<0,1,2,3>

#line 43 "C:\dx9-fixtures\debug.hlsl"
0x00000498:     mov r0, r0  // ::o<0,1,2,3>
0x000004A4:     mul r0, r0, c2  // ::o<0,1,2,3>
0x000004B4:     add r0, r0, c3  // ::o<0,1,2,3>
0x000004C4:     mov oPos, r0  // ::stepped<0,1,2,3>

// approximately 17 instruction slots used

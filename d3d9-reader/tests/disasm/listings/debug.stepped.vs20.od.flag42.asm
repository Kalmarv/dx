    vs_2_0
    dcl_position v0  // p<0,1,2,3>

#line 33 "C:\dx9-fixtures\debug.hlsl"
    mul r0, v0.yzwx, c0.yzwx  // ::o<1,2,3,0>
    nop
    mov r0, r0  // h2::v<1,2,3,0>

#line 30
    add r0, r0, c3  // ::h2<1,2,3,0>

#line 34
    mov r0, r0  // ::o<1,2,3,0>
    nop
    mov r0, r0  // h1::v<1,2,3,0>

#line 28
    mul r0, r0, c2.zwxy  // ::h1<1,2,3,0>

#line 35
    mov r0, r0  // ::o<1,2,3,0>
    add r0, r0, c1.yzwx  // ::o<1,2,3,0>
    mul r0, r0, c1.zwxy  // ::o<1,2,3,0>

#line 42
    mov r1, -c0.wxyz
    add r0, r0, r1  // ::o<1,2,3,0>
    nop
    mov r0, r0  // twist::v<1,2,3,0>

#line 4 "C:\dx9-fixtures\debug.hlsli"
    mul r0, r0.wxyz, r0  // ::twist<0,1,2,3>

#line 43 "C:\dx9-fixtures\debug.hlsl"
    mov r0, r0  // ::o<0,1,2,3>
    mul r0, r0, c2  // ::o<0,1,2,3>
    add r0, r0, c3  // ::o<0,1,2,3>
    mov oPos, r0  // ::stepped<0,1,2,3>

// approximately 17 instruction slots used

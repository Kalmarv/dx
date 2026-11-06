    vs_3_0
    def c6, 0x3f800000, 0x40000000, 0x00000000, 0x00000000
    dcl_position v0  // p<0,1,2,3>
    dcl_texcoord v1  // t<0,1>
    dcl_position o0
    dcl_texcoord o1.xy
    dcl_texcoord1 o2.x

#line 59 "C:\dx9-fixtures\debug.hlsl"
    mov r0, c5  // ::j<0,1,2,3>
    mad o0, v0, r0, c3  // ::packed<0,1,2,3>

#line 54
    mul r0.xy, c4, v0  // ::a<0>, ::b<0>
    mul r1.y, r0.x, c0.y  // ::mm<2>
    mul r1.z, r0.x, c1.y  // ::mm<3>

#line 60
    mul r0.yz, r0.y, r1

#line 56
    mul r0.x, r0.x, r0.x

#line 60
    mad r1.x, c0.x, r0.x, r0.y
    mad r1.y, c1.x, r0.x, r0.z
    add o1.xy, r1, v1  // ::packed<4,5>

#line 57
    mov r0.xy, c4  // ::k<0,1>
    mad r0.xy, v0, r0, c6  // ::vals<0,1>

#line 61
    mul o2.x, r0.y, r0.x  // ::packed<6>

// approximately 13 instruction slots used

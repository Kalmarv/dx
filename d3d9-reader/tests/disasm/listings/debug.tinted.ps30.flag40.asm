    ps_3_0
    dcl_texcoord v0.xy  // uv<0,1>
    dcl_2d s0

#line 21 "C:\dx9-fixtures\debug.hlsl"
    texld r0, v0, s0

#line 24
    mov r1, c0  // ::k<0,1,2,3>
    mad oC0, r0, r1, c1  // ::tinted<0,1,2,3>

// approximately 3 instruction slots used (1 texture, 2 arithmetic)

    ps_2_0
    def c3, 0x00000000, 0x3f800000, 0x00000000, 0x00000000
    dcl t0.xy  // uv<0,1>
    dcl_2d s0

#line 75 "C:\dx9-fixtures\debug.hlsl"
    texld r0, t0, s0
    mov r0.x, -r0.x
    add r0.x, r0.x, c0.x
    cmp r0, r0.x, c3.x, c3.y
    mov r1, -r0
    mov r0, -r0
    add r0, r0, r1
    cmp r0, r0, c3.x, c3.y
    mov r0, -r0
    mov r1, c2  // ::n<0,1,2,3>
    cmp r0, r0, r1, c1  // ::near1<0,1,2,3>
    mov oC0, r0  // ::near1<0,1,2,3>

// approximately 12 instruction slots used (1 texture, 11 arithmetic)

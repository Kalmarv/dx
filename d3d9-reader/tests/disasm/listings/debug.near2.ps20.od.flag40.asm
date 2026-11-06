    ps_2_0
    def c4, 0, 1, 0, 0
    dcl t0.xy  // uv<0,1>
    dcl_2d s0

#line 77 "C:\dx9-fixtures\debug.hlsl"
    texld r0, t0, s0
    mul r0, r0, c0.x  // ::c<0,1,2,3>
    mov r1.w, -r0.y
    add r1.x, r1.w, c1.y
    cmp r1, r1.x, c4.x, c4.y
    mul r2, r0, c2
    add r2, r2, c3
    mov r3, -c1
    add r0, r0, r3
    mov r3, -r1
    mov r1, -r1
    add r1, r1, r3
    cmp r1, r1, c4.x, c4.y
    mov r1, -r1
    cmp r0, r1, r0, r2  // ::near2<0,1,2,3>
    mov oC0, r0  // ::near2<0,1,2,3>

// approximately 16 instruction slots used (1 texture, 15 arithmetic)

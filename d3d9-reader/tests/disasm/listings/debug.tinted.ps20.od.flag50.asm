    ps_2_0
    dcl t0.xy
    dcl_2d s0
    texld r0, t0, s0
    mul r0, r0, c0
    add r0, r0, c1
    mov oC0, r0

// approximately 4 instruction slots used (1 texture, 3 arithmetic)

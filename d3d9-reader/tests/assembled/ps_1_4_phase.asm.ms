    ps_1_4
    texcrd r0.xyz, t0
    add r0.xyz, r0, c0
    phase
    texld r1, r0
    mov r0, r1

// approximately 4 instruction slots used (2 texture, 2 arithmetic)

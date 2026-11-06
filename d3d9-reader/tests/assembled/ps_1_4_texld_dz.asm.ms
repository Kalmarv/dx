    ps_1_4
    texcrd r0.xyz, t0
    phase
    texld r1, r0_dz
    mov r0, r1

// approximately 3 instruction slots used (2 texture, 1 arithmetic)

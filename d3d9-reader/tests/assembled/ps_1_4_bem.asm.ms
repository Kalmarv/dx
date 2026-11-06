    ps_1_4
    texcrd r1.xyz, t0
    texcrd r2.xyz, t1
    bem r0.xy, r1, r2
    phase
    mov r0.zw, c0

// approximately 4 instruction slots used (2 texture, 2 arithmetic)

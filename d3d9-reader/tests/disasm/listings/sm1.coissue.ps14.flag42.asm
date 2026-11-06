    ps_1_4
    texld r0, t0
    phase
    mul r0, r0, v0
    mov r0.xyz, c0
  + mov r0.w, c0

// approximately 3 instruction slots used (1 texture, 2 arithmetic)

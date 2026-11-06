    ps_3_0
    def c0, 1, 0, 0, 1
    def c1, 0, 1, 0, 1
    def c2, 0, 0, 0, 0
    dcl vFace
    if_gt vFace, c2.x
      mov r0, c0
    else
      mov r0, c1
    endif
    mov oC0, r0

// approximately 8 instruction slots used

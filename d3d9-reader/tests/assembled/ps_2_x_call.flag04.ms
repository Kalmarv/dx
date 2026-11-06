    ps_2_x
   0:     mov r0, c0
   1:     call l0
   3:     call l0
   5:     mov oC0, r0
   6:     ret
          label l0
   7:     add r0, r0, r0
   8:     ret

// approximately 9 instruction slots used

    vs_2_0
          dcl_position v0
   0:     mov oPos, v0
   1:     mov r0, c0
   2:     call l0
   4:     mov oT0, r0
   5:     call l0
   7:     mov oT1, r0
   8:     ret
          label l0
   9:     add r0, r0, r0
  10:     ret

// approximately 11 instruction slots used

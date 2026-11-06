    vs_2_0
          dcl_position v0
   0:     mov oPos, v0
   1:     mov r0, c0
   2:     callnz l1, b0
   5:     mov oT0, r0
   6:     ret
          label l1
   7:     add r0, r0, r0
   8:     ret

// approximately 9 instruction slots used

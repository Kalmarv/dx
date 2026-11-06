    vs_2_0
          dcl_position v0
   0:     mov oPos, v0
   1:     mov r9, c0
   2:     pow r0.x, r9.x, c0.y
   5:     mov oT0.x, r0.x
   6:     mov r1, c1
   7:     nrm r2.xyz, r1
  10:     mov oT1.xyz, r2
  11:     mov r3, c2
  12:     lrp r4.x, r3.x, r3.y, r3.z
  13:     mov oT2.x, r4.x

// approximately 14 instruction slots used

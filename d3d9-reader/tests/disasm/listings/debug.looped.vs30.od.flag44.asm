    vs_3_0
          def c4, 0, 0, 1, 0
          defi i0, 255, 0, 0, 0
          dcl_position v0  // p<0,1,2,3>
          dcl_position o0

#line 67 "C:\dx9-fixtures\debug.hlsl"
   0:     mov r0, v0  // ::o<0,1,2,3>
   1:     mov r1.x, c4.x  // ::i<0>
   2:     mov r2, r0  // ::o<0,1,2,3>
   3:     mov r1.y, r1.x  // ::i<0>
   4:     rep i0
   7:       slt r1.z, r1.y, c3.x
   8:       mov r1.w, -r1.z
   9:       sge r1.z, r1.w, r1.z
  10:       break_ne r1.z, -r1.z
  13:       mul r3, r1.y, c2
  14:       add r2, r2, r3  // ::o<0,1,2,3>
  15:       add r1.y, r1.y, c4.z  // ::i<0>
  16:     endrep
  18:     if b0
  21:       mov r2, -r2  // ::o<0,1,2,3>
  22:     endif
  23:     mov o0, r2  // ::looped<0,1,2,3>

// approximately 24 instruction slots used

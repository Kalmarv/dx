    ps_2_0
          def c4, 0, 1, 0, 0
          dcl t0.xy  // uv<0,1>
          dcl_2d s0

#line 77 "C:\dx9-fixtures\debug.hlsl"
   0:     texld r0, t0, s0
   0:     mul r0, r0, c0.x  // ::c<0,1,2,3>
   1:     mov r1.w, -r0.y
   2:     add r1.x, r1.w, c1.y
   3:     cmp r1, r1.x, c4.x, c4.y
   4:     mul r2, r0, c2
   5:     add r2, r2, c3
   6:     mov r3, -c1
   7:     add r0, r0, r3
   8:     mov r3, -r1
   9:     mov r1, -r1
  10:     add r1, r1, r3
  11:     cmp r1, r1, c4.x, c4.y
  12:     mov r1, -r1
  13:     cmp r0, r1, r0, r2  // ::near2<0,1,2,3>
  14:     mov oC0, r0  // ::near2<0,1,2,3>

// approximately 16 instruction slots used (1 texture, 15 arithmetic)

      vs_4_0
      dcl_constantbuffer CB2[2], immediateIndexed
      dcl_constantbuffer CB3[3], immediateIndexed
      dcl_input v0.xyzw
      dcl_output_siv o0.xyzw, position
      dcl_temps 4
//
// Initial variable locations:
//   v0.x <- p.x; v0.y <- p.y; v0.z <- p.z; v0.w <- p.w; 
//   o0.x <- <twice return value>.x; o0.y <- <twice return value>.y; o0.z <- <twice return value>.z; o0.w <- <twice return value>.w
//
#line 34 "C:\dx-fixtures\level9.hlsl"
   0: mov r0.xyzw, v0.xyzw  // r0.x <- o.x; r0.y <- o.y; r0.z <- o.z; r0.w <- o.w

#line 35
   1: mov r1.x, l(0)  // r1.x <- k
   2: mov r2.xyzw, r0.xyzw  // r2.x <- o.x; r2.y <- o.y; r2.z <- o.z; r2.w <- o.w
   3: mov r1.y, r1.x  // r1.y <- k
   4: loop 
   5:   ilt r1.z, r1.y, cb3[1].z
   6:   breakc_z r1.z
   7:   itof r3.xyzw, r1.yyyy
   8:   mul r3.xyzw, r3.xyzw, cb2[1].xyzw
   9:   add r2.xyzw, r2.xyzw, r3.xyzw
  10:   iadd r1.y, r1.y, l(1)
  11: endloop 

#line 36
  12: mov r0.x, l(0)  // r0.x <- j
  13: mov r1.xyzw, r2.xyzw  // r1.x <- o.x; r1.y <- o.y; r1.z <- o.z; r1.w <- o.w
  14: mov r0.y, r0.x  // r0.y <- j
  15: loop 
  16:   ilt r0.z, r0.y, cb3[1].y
  17:   breakc_z r0.z
  18:   mul r1.xyzw, r1.yzwx, r1.xyzw
  19:   iadd r0.y, r0.y, l(1)
  20: endloop 

#line 37
  21: ine r0.x, l(0, 0, 0, 0), cb3[2].x
  22: if_nz r0.x
  23:   mov r1.xyzw, -r1.xyzw
  24: endif 

#line 38
  25: mov o0.xyzw, r1.xyzw
  26: ret 

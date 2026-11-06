      vs_4_0
      dcl_constantbuffer CB4[1], immediateIndexed
      dcl_input v0.xyzw
      dcl_output_siv o0.xyzw, position
      dcl_temps 3
//
// Initial variable locations:
//   v0.x <- p.x; v0.y <- p.y; v0.z <- p.z; v0.w <- p.w; 
//   o0.x <- <lone return value>.x; o0.y <- <lone return value>.y; o0.z <- <lone return value>.z; o0.w <- <lone return value>.w
//
#line 44 "C:\dx-fixtures\level9.hlsl"
   0: mov r0.xyzw, v0.xyzw  // r0.x <- o.x; r0.y <- o.y; r0.z <- o.z; r0.w <- o.w

#line 45
   1: mov r1.x, l(0)  // r1.x <- k
   2: mov r2.xyzw, r0.xyzw  // r2.x <- o.x; r2.y <- o.y; r2.z <- o.z; r2.w <- o.w
   3: mov r1.y, r1.x  // r1.y <- k
   4: loop 
   5:   ilt r1.z, r1.y, cb4[0].w
   6:   breakc_z r1.z
   7:   mul r2.xyzw, r2.yzwx, r2.xyzw
   8:   iadd r1.y, r1.y, l(1)
   9: endloop 

#line 46
  10: ine r0.x, l(0, 0, 0, 0), cb4[0].y
  11: if_nz r0.x
  12:   mov r2.xyzw, -r2.xyzw
  13: endif 

#line 47
  14: mov o0.xyzw, r2.xyzw
  15: ret 

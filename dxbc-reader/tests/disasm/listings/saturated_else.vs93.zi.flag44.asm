      vs_4_0
      dcl_constantbuffer CB2[2], immediateIndexed
      dcl_constantbuffer CB3[3], immediateIndexed
      dcl_input v0.xyzw
      dcl_output_siv o0.xyzw, position
      dcl_temps 3
//
// Initial variable locations:
//   v0.x <- p.x; v0.y <- p.y; v0.z <- p.z; v0.w <- p.w; 
//   o0.x <- o.x; o0.y <- o.y; o0.z <- o.z; o0.w <- o.w
//
#line 35 "C:\dx-fixtures\level9.hlsl"
   0: mov r0.xyzw, v0.xyzw  // r0.x <- o.x; r0.y <- o.y; r0.z <- o.z; r0.w <- o.w
   1: mov r1.x, l(0)  // r1.x <- k
   2: loop 
   3:   ige r1.y, r1.x, cb3[1].z
   4:   breakc_nz r1.y
   5:   itof r1.y, r1.x
   6:   mad r0.xyzw, cb2[1].xyzw, r1.yyyy, r0.xyzw
   7:   iadd r1.x, r1.x, l(1)
   8: endloop 

#line 36
   9: mov r1.xyzw, r0.xyzw  // r1.x <- o.x; r1.y <- o.y; r1.z <- o.z; r1.w <- o.w
  10: mov r2.x, l(0)  // r2.x <- j
  11: loop 
  12:   ige r2.y, r2.x, cb3[1].y
  13:   breakc_nz r2.y
  14:   mul r1.xyzw, r1.yzwx, r1.xyzw
  15:   iadd r2.x, r2.x, l(1)
  16: endloop 

#line 37
  17: if_nz cb3[2].x
  18:   mov o0.xyzw, -r1.xyzw
  19: else_sat   // Prior locations: r1.x <- o.x; r1.y <- o.y; r1.z <- o.z; r1.w <- o.w
  20:   mov o0.xyzw, r1.xyzw  // o0.x <- o.x; o0.y <- o.y; o0.z <- o.z; o0.w <- o.w
  21: endif 

#line 38
  22: ret 

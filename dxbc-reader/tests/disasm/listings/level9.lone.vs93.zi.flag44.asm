      vs_4_0
      dcl_constantbuffer CB4[1], immediateIndexed
      dcl_input v0.xyzw
      dcl_output_siv o0.xyzw, position
      dcl_temps 2
//
// Initial variable locations:
//   v0.x <- p.x; v0.y <- p.y; v0.z <- p.z; v0.w <- p.w; 
//   o0.x <- o.x; o0.y <- o.y; o0.z <- o.z; o0.w <- o.w
//
#line 45 "C:\dx-fixtures\level9.hlsl"
   0: mov r0.xyzw, v0.xyzw  // r0.x <- o.x; r0.y <- o.y; r0.z <- o.z; r0.w <- o.w
   1: mov r1.x, l(0)  // r1.x <- k
   2: loop 
   3:   ige r1.y, r1.x, cb4[0].w
   4:   breakc_nz r1.y
   5:   mul r0.xyzw, r0.yzwx, r0.xyzw
   6:   iadd r1.x, r1.x, l(1)
   7: endloop 

#line 46
   8: if_nz cb4[0].y
   9:   mov o0.xyzw, -r0.xyzw
  10: else   // Prior locations: r0.x <- o.x; r0.y <- o.y; r0.z <- o.z; r0.w <- o.w
  11:   mov o0.xyzw, r0.xyzw  // o0.x <- o.x; o0.y <- o.y; o0.z <- o.z; o0.w <- o.w
  12: endif 

#line 47
  13: ret 

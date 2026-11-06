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
mov r0.xyzw, v0.xyzw  // r0.x <- o.x; r0.y <- o.y; r0.z <- o.z; r0.w <- o.w
mov r1.x, l(0x00000000)  // r1.x <- k
loop 
  ige r1.y, r1.x, cb3[1].z
  breakc_nz r1.y
  itof r1.y, r1.x
  mad r0.xyzw, cb2[1].xyzw, r1.yyyy, r0.xyzw
  iadd r1.x, r1.x, l(0x00000001)
endloop 

#line 36
mov r1.xyzw, r0.xyzw  // r1.x <- o.x; r1.y <- o.y; r1.z <- o.z; r1.w <- o.w
mov r2.x, l(0x00000000)  // r2.x <- j
loop 
  ige r2.y, r2.x, cb3[1].y
  breakc_nz r2.y
  mul r1.xyzw, r1.yzwx, r1.xyzw
  iadd r2.x, r2.x, l(0x00000001)
endloop 

#line 37
if_nz cb3[2].x
  mov o0.xyzw, -r1.xyzw
else   // Prior locations: r1.x <- o.x; r1.y <- o.y; r1.z <- o.z; r1.w <- o.w
  mov o0.xyzw, r1.xyzw  // o0.x <- o.x; o0.y <- o.y; o0.z <- o.z; o0.w <- o.w
endif 

#line 38
ret 

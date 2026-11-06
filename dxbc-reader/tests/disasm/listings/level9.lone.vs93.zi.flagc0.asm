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
mov r0.xyzw, v0.xyzw  // r0.x <- o.x; r0.y <- o.y; r0.z <- o.z; r0.w <- o.w
mov r1.x, l(0x00000000)  // r1.x <- k
loop 
  ige r1.y, r1.x, cb4[0].w
  breakc_nz r1.y
  mul r0.xyzw, r0.yzwx, r0.xyzw
  iadd r1.x, r1.x, l(0x00000001)
endloop 

#line 46
if_nz cb4[0].y
  mov o0.xyzw, -r0.xyzw
else   // Prior locations: r0.x <- o.x; r0.y <- o.y; r0.z <- o.z; r0.w <- o.w
  mov o0.xyzw, r0.xyzw  // o0.x <- o.x; o0.y <- o.y; o0.z <- o.z; o0.w <- o.w
endif 

#line 47
ret 

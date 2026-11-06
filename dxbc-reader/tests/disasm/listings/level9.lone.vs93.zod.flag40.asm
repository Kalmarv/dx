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
mov r0.xyzw, v0.xyzw  // r0.x <- o.x; r0.y <- o.y; r0.z <- o.z; r0.w <- o.w

#line 45
mov r1.x, l(0)  // r1.x <- k
mov r2.xyzw, r0.xyzw  // r2.x <- o.x; r2.y <- o.y; r2.z <- o.z; r2.w <- o.w
mov r1.y, r1.x  // r1.y <- k
loop 
  ilt r1.z, r1.y, cb4[0].w
  breakc_z r1.z
  mul r2.xyzw, r2.yzwx, r2.xyzw
  iadd r1.y, r1.y, l(1)
endloop 

#line 46
ine r0.x, l(0, 0, 0, 0), cb4[0].y
if_nz r0.x
  mov r2.xyzw, -r2.xyzw
endif 

#line 47
mov o0.xyzw, r2.xyzw
ret 

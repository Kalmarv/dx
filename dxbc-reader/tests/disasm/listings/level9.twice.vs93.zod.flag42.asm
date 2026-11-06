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
mov r0.xyzw, v0.xyzw  // r0.x <- o.x; r0.y <- o.y; r0.z <- o.z; r0.w <- o.w

#line 35
mov r1.x, l(0)  // r1.x <- k
mov r2.xyzw, r0.xyzw  // r2.x <- o.x; r2.y <- o.y; r2.z <- o.z; r2.w <- o.w
mov r1.y, r1.x  // r1.y <- k
loop 
  ilt r1.z, r1.y, cb3[1].z
  breakc_z r1.z
  itof r3.xyzw, r1.yyyy
  mul r3.xyzw, r3.xyzw, cb2[1].xyzw
  add r2.xyzw, r2.xyzw, r3.xyzw
  iadd r1.y, r1.y, l(1)
endloop 

#line 36
mov r0.x, l(0)  // r0.x <- j
mov r1.xyzw, r2.xyzw  // r1.x <- o.x; r1.y <- o.y; r1.z <- o.z; r1.w <- o.w
mov r0.y, r0.x  // r0.y <- j
loop 
  ilt r0.z, r0.y, cb3[1].y
  breakc_z r0.z
  mul r1.xyzw, r1.yzwx, r1.xyzw
  iadd r0.y, r0.y, l(1)
endloop 

#line 37
ine r0.x, l(0, 0, 0, 0), cb3[2].x
if_nz r0.x
  mov r1.xyzw, -r1.xyzw
endif 

#line 38
mov o0.xyzw, r1.xyzw
ret 

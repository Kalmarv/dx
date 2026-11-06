vs_4_0
dcl_constantbuffer CB1[3], immediateIndexed
dcl_constantbuffer CB2[3], dynamicIndexed
dcl_input v0.xyzw
dcl_output_siv o0.xyzw, position
dcl_temps 3
//
// Initial variable locations:
//   v0.x <- p.x; v0.y <- p.y; v0.z <- p.z; v0.w <- p.w; 
//   o0.x <- <looped return value>.x; o0.y <- <looped return value>.y; o0.z <- <looped return value>.z; o0.w <- <looped return value>.w
//
#line 26 "C:\dx-fixtures\level9.hlsl"
mov r0.xyzw, v0.xyzw  // r0.x <- o.x; r0.y <- o.y; r0.z <- o.z; r0.w <- o.w

#line 27
mov r1.x, l(0x00000000)  // r1.x <- k
mov r2.xyzw, r0.xyzw  // r2.x <- o.x; r2.y <- o.y; r2.z <- o.z; r2.w <- o.w
mov r1.y, r1.x  // r1.y <- k
loop 
  ilt r1.z, r1.y, cb1[0].x
  breakc_z r1.z
  add r2.xyzw, r2.xyzw, cb2[r1.y + 0].xyzw
  iadd r1.y, r1.y, l(0x00000001)
endloop 

#line 28
mul o0.xyzw, r2.xyzw, cb1[2].yyyy
ret 

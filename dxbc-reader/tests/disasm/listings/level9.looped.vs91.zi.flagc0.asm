vs_4_0
dcl_constantbuffer CB1[3], immediateIndexed
dcl_constantbuffer CB2[3], dynamicIndexed
dcl_input v0.xyzw
dcl_output_siv o0.xyzw, position
dcl_temps 2
//
// Initial variable locations:
//   v0.x <- p.x; v0.y <- p.y; v0.z <- p.z; v0.w <- p.w; 
//   o0.x <- <looped return value>.x; o0.y <- <looped return value>.y; o0.z <- <looped return value>.z; o0.w <- <looped return value>.w
//
#line 27 "C:\dx-fixtures\level9.hlsl"
mov r0.xyzw, v0.xyzw  // r0.x <- o.x; r0.y <- o.y; r0.z <- o.z; r0.w <- o.w
mov r1.x, l(0x00000000)  // r1.x <- k
loop 
  ige r1.y, r1.x, cb1[0].x
  breakc_nz r1.y
  add r0.xyzw, r0.xyzw, cb2[r1.x + 0].xyzw
  iadd r1.x, r1.x, l(0x00000001)
endloop 

#line 28
mul o0.xyzw, r0.xyzw, cb1[2].yyyy
ret 

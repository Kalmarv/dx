ps_4_0
dcl_input_ps linear v1.xyzw
dcl_output o0.xyzw
//
// Initial variable locations:
//   v0.x <- pos.x; v0.y <- pos.y; v0.z <- pos.z; v0.w <- pos.w; 
//   v1.x <- c.x; v1.y <- c.y; v1.z <- c.z; v1.w <- c.w; 
//   o0.x <- <bare return value>.x; o0.y <- <bare return value>.y; o0.z <- <bare return value>.z; o0.w <- <bare return value>.w
//
#line 67 "C:\dx-fixtures\level9.hlsl"
mul o0.xyzw, v1.xyzw, v1.xyzw
ret 

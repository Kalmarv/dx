gs_4_0
dcl_input_siv v[1][0].xyzw, position
dcl_input v[1][1].xy
dcl_temps 1
dcl_inputprimitive point 
dcl_outputtopology linestrip 
dcl_output_siv o0.xyzw, position
dcl_output o1.xy
dcl_maxout 4
//
// Initial variable locations:
//   m0 <- s; 
//   v[0][0].x <- input[0].pos.x; v[0][0].y <- input[0].pos.y; v[0][0].z <- input[0].pos.z; v[0][0].w <- input[0].pos.w; 
//   v[0][1].x <- input[0].uv.x; v[0][1].y <- input[0].uv.y
//
#line 33 "C:\dx-fixtures\gs_streams.hlsl"
mov o0.xyzw, v[0][0].xyzw
mov o1.xy, v[0][1].xyxx
emit 

#line 34
add r0.x, l(1.000000), v[0][0].x  // r0.x <- a.pos.x

#line 35
mov o0.x, r0.x
mov o0.yzw, v[0][0].yyzw
mov o1.xy, v[0][1].xyxx
emit 

#line 36
cut 

#line 37
ret 

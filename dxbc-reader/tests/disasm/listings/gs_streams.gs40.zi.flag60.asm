0x00000000: gs_4_0
0x00000008: dcl_input_siv v[1][0].xyzw, position
0x0000001C: dcl_input v[1][1].xy
0x0000002C: dcl_temps 1
0x00000034: dcl_inputprimitive point 
0x00000038: dcl_outputtopology linestrip 
0x0000003C: dcl_output_siv o0.xyzw, position
0x0000004C: dcl_output o1.xy
0x00000058: dcl_maxout 4
//
// Initial variable locations:
//   m0 <- s; 
//   v[0][0].x <- input[0].pos.x; v[0][0].y <- input[0].pos.y; v[0][0].z <- input[0].pos.z; v[0][0].w <- input[0].pos.w; 
//   v[0][1].x <- input[0].uv.x; v[0][1].y <- input[0].uv.y
//
#line 33 "C:\dx-fixtures\gs_streams.hlsl"
0x00000060: mov o0.xyzw, v[0][0].xyzw
0x00000078: mov o1.xy, v[0][1].xyxx
0x00000090: emit 

#line 34
0x00000094: add r0.x, l(1.000000), v[0][0].x  // r0.x <- a.pos.x

#line 35
0x000000B4: mov o0.x, r0.x
0x000000C8: mov o0.yzw, v[0][0].yyzw
0x000000E0: mov o1.xy, v[0][1].xyxx
0x000000F8: emit 

#line 36
0x000000FC: cut 

#line 37
0x00000100: ret 

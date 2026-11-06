0x00000000: gs_4_0
0x00000008: dcl_input_siv v[1][0].xyzw, position
0x0000001C: dcl_input v[1][1].xy
0x0000002C: dcl_temps 2
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
#line 32 "C:\dx-fixtures\gs_streams.hlsl"
0x00000060: mov r0.xyzw, v[0][0].xyzw  // r0.x <- a.pos.x; r0.y <- a.pos.y; r0.z <- a.pos.z; r0.w <- a.pos.w
0x00000078: mov r1.xy, v[0][1].xyxx  // r1.x <- a.uv.x; r1.y <- a.uv.y

#line 33
0x00000090: mov o0.xyzw, r0.xyzw
0x000000A4: mov o1.xy, r1.xyxx
0x000000B8: emit 

#line 34
0x000000BC: itof r1.z, l(1)
0x000000D0: add r0.x, r0.x, r1.z

#line 35
0x000000EC: mov o0.x, r0.x
0x00000100: mov o0.yzw, r0.yyzw
0x00000114: mov o1.xy, r1.xyxx
0x00000128: emit 

#line 36
0x0000012C: cut 

#line 37
0x00000130: ret 

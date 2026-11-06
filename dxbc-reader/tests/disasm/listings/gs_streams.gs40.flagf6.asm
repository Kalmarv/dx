      0x00000000: gs_4_0
      0x00000008: dcl_input_siv v[1][0].xyzw, position
      0x0000001C: dcl_input v[1][1].xy
      0x0000002C: dcl_temps 1
      0x00000034: dcl_inputprimitive point 
      0x00000038: dcl_outputtopology linestrip 
      0x0000003C: dcl_output_siv o0.xyzw, position
      0x0000004C: dcl_output o1.xy
      0x00000058: dcl_maxout 4
   0  0x00000060: mov o0.xyzw, v[0][0].xyzw
   1  0x00000078: mov o1.xy, v[0][1].xyxx
   2  0x00000090: emit 
   3  0x00000094: add r0.x, l(0x3f800000), v[0][0].x
   4  0x000000B4: mov o0.x, r0.x
   5  0x000000C8: mov o0.yzw, v[0][0].yyzw
   6  0x000000E0: mov o1.xy, v[0][1].xyxx
   7  0x000000F8: emit 
   8  0x000000FC: cut 
   9  0x00000100: ret 

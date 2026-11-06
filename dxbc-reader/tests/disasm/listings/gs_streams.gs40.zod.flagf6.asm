      0x00000000: gs_4_0
      0x00000008: dcl_input_siv v[1][0].xyzw, position
      0x0000001C: dcl_input v[1][1].xy
      0x0000002C: dcl_temps 2
      0x00000034: dcl_inputprimitive point 
      0x00000038: dcl_outputtopology linestrip 
      0x0000003C: dcl_output_siv o0.xyzw, position
      0x0000004C: dcl_output o1.xy
      0x00000058: dcl_maxout 4
   0  0x00000060: mov r0.xyzw, v[0][0].xyzw
   1  0x00000078: mov r1.xy, v[0][1].xyxx
   2  0x00000090: mov o0.xyzw, r0.xyzw
   3  0x000000A4: mov o1.xy, r1.xyxx
   4  0x000000B8: emit 
   5  0x000000BC: itof r1.z, l(0x00000001)
   6  0x000000D0: add r0.x, r0.x, r1.z
   7  0x000000EC: mov o0.x, r0.x
   8  0x00000100: mov o0.yzw, r0.yyzw
   9  0x00000114: mov o1.xy, r1.xyxx
  10  0x00000128: emit 
  11  0x0000012C: cut 
  12  0x00000130: ret 

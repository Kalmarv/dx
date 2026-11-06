      0x00000000: gs_5_0
      0x00000008: dcl_globalFlags refactoringAllowed
      0x0000000C: dcl_input_siv v[3][0].xyzw, position
      0x00000020: dcl_input v[3][1].xy
      0x00000030: dcl_temps 1
      0x00000038: dcl_inputprimitive triangle 
      0x0000003C: dcl_stream m0
      0x00000048: dcl_outputtopology trianglestrip 
      0x0000004C: dcl_output_siv o0.xyzw, position
      0x0000005C: dcl_output o1.xy
      0x00000068: dcl_maxout 4
   0  0x00000070: mov o0.xyzw, v[0][0].xyzw
   1  0x00000088: mov o1.xy, v[0][1].xyxx
   2  0x000000A0: emit_stream m0
   3  0x000000AC: mov o0.xyzw, v[1][0].xyzw
   4  0x000000C4: mov o1.xy, v[1][1].xyxx
   5  0x000000DC: emit_stream m0
   6  0x000000E8: mov o0.xyzw, v[2][0].xyzw
   7  0x00000100: mov o1.xy, v[2][1].xyxx
   8  0x00000118: emit_stream m0
   9  0x00000124: add r0.x, l(0x3f800000), v[0][0].x
  10  0x00000144: mov o0.x, r0.x
  11  0x00000158: mov o0.yzw, v[0][0].yyzw
  12  0x00000170: mov o1.xy, v[0][1].xyxx
  13  0x00000188: emit_stream m0
  14  0x00000194: ret 

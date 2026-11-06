0x00000000: gs_5_0
0x00000008: dcl_globalFlags refactoringAllowed
0x0000000C: dcl_input_siv v[2][0].xyzw, position
0x00000020: dcl_input v[2][1].xy
0x00000030: dcl_inputprimitive patch2 
0x00000034: dcl_stream m0
0x00000040: dcl_outputtopology linestrip 
0x00000044: dcl_output_siv o0.xyzw, position
0x00000054: dcl_output o1.xy
0x00000060: dcl_maxout 2
0x00000068: mov o0.xyzw, v[0][0].xyzw
0x00000080: mov o1.xy, v[0][1].xyxx
0x00000098: emit_stream m0
0x000000A4: mov o0.xyzw, v[1][0].xyzw
0x000000BC: mov o1.xy, v[1][1].xyxx
0x000000D4: emit_stream m0
0x000000E0: ret 

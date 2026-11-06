      gs_5_0
      dcl_globalFlags refactoringAllowed
      dcl_input_siv v[3][0].xyzw, position
      dcl_input v[3][1].xy
      dcl_temps 1
      dcl_inputprimitive triangle 
      dcl_stream m0
      dcl_outputtopology trianglestrip 
      dcl_output_siv o0.xyzw, position
      dcl_output o1.xy
      dcl_maxout 4
   0: mov o0.xyzw, v[0][0].xyzw
   1: mov o1.xy, v[0][1].xyxx
   2: emit_stream m0
   3: mov o0.xyzw, v[1][0].xyzw
   4: mov o1.xy, v[1][1].xyxx
   5: emit_stream m0
   6: mov o0.xyzw, v[2][0].xyzw
   7: mov o1.xy, v[2][1].xyxx
   8: emit_stream m0
   9: add r0.x, l(1.000000), v[0][0].x
  10: mov o0.x, r0.x
  11: mov o0.yzw, v[0][0].yyzw
  12: mov o1.xy, v[0][1].xyxx
  13: emit_stream m0
  14: ret 

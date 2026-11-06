      gs_5_0
      dcl_globalFlags refactoringAllowed
      dcl_input_siv v[2][0].xyzw, position
      dcl_input v[2][1].xy
      dcl_inputprimitive patch2 
      dcl_stream m0
      dcl_outputtopology linestrip 
      dcl_output_siv o0.xyzw, position
      dcl_output o1.xy
      dcl_maxout 2
   0: mov o0.xyzw, v[0][0].xyzw
   1: mov o1.xy, v[0][1].xyxx
   2: emit_stream m0
   3: mov o0.xyzw, v[1][0].xyzw
   4: mov o1.xy, v[1][1].xyxx
   5: emit_stream m0
   6: ret 

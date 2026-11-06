      vs_5_0
      dcl_globalFlags refactoringAllowed
      dcl_constantbuffer CB0[2], immediateIndexed
      dcl_function_body fb0
      dcl_function_body fb1
      dcl_function_table ft0 = {fb0}
      dcl_function_table ft1 = {fb1}
      dcl_interface fp0[1][1] = {ft0, ft1}
      dcl_input v0.xyzw
      dcl_output_siv o0.xyzw, position
      dcl_temps 2
   0: fcall fp0[0][0]
   1: mov o0.xyzw, r0.xyzw
   2: ret 
   3: label fb0
   4: mov r0.xyzw, v0.wzyx
   5: ret 
   6: label fb1
   7: mov r1.xy, this[0].yxyy
   8: mul r0.xyzw, v0.xyzw, cb[r1.y + 0][r1.x + 0].xyzw
   9: ret 

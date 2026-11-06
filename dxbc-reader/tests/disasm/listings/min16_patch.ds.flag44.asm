      ds_5_0
      dcl_input_control_point_count 3
      dcl_tessellator_domain domain_tri
      dcl_globalFlags refactoringAllowed | enableMinimumPrecision
      dcl_input vpc4.xyzw {min16f}
      dcl_input vDomain.xyz
      dcl_input vicp[3][0].xyzw
      dcl_input vicp[3][1].xyz {min16f}
      dcl_output_siv o0.xyzw, position
      dcl_output o1.xyzw {min16f}
      dcl_temps 1
   0: mul r0.xyzw, vDomain.yyyy, vicp[1][0].xyzw
   1: mad r0.xyzw, vicp[0][0].xyzw, vDomain.xxxx, r0.xyzw
   2: mad o0.xyzw, vicp[2][0].xyzw, vDomain.zzzz, r0.xyzw
   3: mov r0.xyz {min16f}, vicp[0][1].xyzx {min16f}
   4: mov r0.w {min16f}, l(1.000000) {def32 as min16f}
   5: mul o1.xyzw {min16f}, r0.xyzw {min16f}, vpc4.xyzw {min16f}
   6: ret 

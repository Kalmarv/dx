      ds_5_0
      dcl_input_control_point_count 3
      dcl_tessellator_domain domain_tri
      dcl_globalFlags refactoringAllowed
      dcl_input vpc4.xyzw
      dcl_input vDomain.xyz
      dcl_input vicp[3][0].xyzw
      dcl_input vicp[3][1].xyz
      dcl_output_siv o0.xyzw, position
      dcl_output o1.xyzw
      dcl_temps 1
   0: mul r0.xyzw, vDomain.yyyy, vicp[1][0].xyzw
   1: mad r0.xyzw, vicp[0][0].xyzw, vDomain.xxxx, r0.xyzw
   2: mad o0.xyzw, vicp[2][0].xyzw, vDomain.zzzz, r0.xyzw
   3: mov r0.xyz, vicp[0][1].xyzx
   4: mov r0.w, l(1.000000)
   5: mul o1.xyzw, r0.xyzw, vpc4.xyzw
   6: ret 

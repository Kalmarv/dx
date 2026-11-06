      ds_5_0
      dcl_input_control_point_count 2
      dcl_tessellator_domain domain_isoline
      dcl_globalFlags refactoringAllowed
      dcl_input_siv vpc0.x, finalLineDensityTessFactor
      dcl_input vDomain.x
      dcl_input vicp[2][0].xyzw
      dcl_input vicp[2][1].xyz
      dcl_output_siv o0.xyzw, position
      dcl_output o1.xyz
      dcl_temps 1
   0: add r0.xyzw, -vicp[0][0].xyzw, vicp[1][0].xyzw
   1: mad r0.xyzw, vDomain.xxxx, r0.xyzw, vicp[0][0].xyzw
   2: mul o0.xyzw, r0.xyzw, vpc0.xxxx
   3: mov o1.xyz, vicp[0][1].xyzx
   4: ret 

      ds_5_0
      dcl_input_control_point_count 3
      dcl_tessellator_domain domain_tri
      dcl_globalFlags refactoringAllowed
      dcl_constantbuffer CB0[5], immediateIndexed
      dcl_input vpc0.yzw
      dcl_input_siv vpc1.x, finalTriVeq0EdgeTessFactor
      dcl_input_siv vpc3.x, finalTriInsideTessFactor
      dcl_input vDomain.xyz
      dcl_input vicp[3][0].xyzw
      dcl_input vicp[3][1].xyz
      dcl_output_siv o0.xyzw, position
      dcl_output o1.xyz
      dcl_temps 2
   0: mul r0.xyzw, vDomain.yyyy, vicp[1][0].xyzw
   1: mad r0.xyzw, vicp[0][0].xyzw, vDomain.xxxx, r0.xyzw
   2: mad r0.xyzw, vicp[2][0].xyzw, vDomain.zzzz, r0.xyzw
   3: mov r1.xyz, vpc0.yzwy
   4: mov r1.w, l(0)
   5: mad r0.xyzw, r1.xyzw, vpc1.xxxx, r0.xyzw
   6: dp4 o0.x, r0.xyzw, cb0[1].xyzw
   7: dp4 o0.y, r0.xyzw, cb0[2].xyzw
   8: dp4 o0.z, r0.xyzw, cb0[3].xyzw
   9: dp4 o0.w, r0.xyzw, cb0[4].xyzw
  10: mul r0.xyz, vDomain.yyyy, vicp[1][1].xyzx
  11: mad r0.xyz, vicp[0][1].xyzx, vDomain.xxxx, r0.xyzx
  12: mad r0.xyz, vicp[2][1].xyzx, vDomain.zzzz, r0.xyzx
  13: dp3 r0.w, r0.xyzx, r0.xyzx
  14: rsq r0.w, r0.w
  15: mul r0.xyz, r0.wwww, r0.xyzx
  16: mul o1.xyz, r0.xyzx, vpc3.xxxx
  17: ret 

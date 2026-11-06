      0x00000000: ds_5_0
      0x00000008: dcl_input_control_point_count 3
      0x0000000C: dcl_tessellator_domain domain_tri
      0x00000010: dcl_globalFlags refactoringAllowed
      0x00000014: dcl_constantbuffer CB0[5], immediateIndexed
      0x00000024: dcl_input vpc0.yzw
      0x00000030: dcl_input_siv vpc1.x, finalTriVeq0EdgeTessFactor
      0x00000040: dcl_input_siv vpc3.x, finalTriInsideTessFactor
      0x00000050: dcl_input vDomain.xyz
      0x00000058: dcl_input vicp[3][0].xyzw
      0x00000068: dcl_input vicp[3][1].xyz
      0x00000078: dcl_output_siv o0.xyzw, position
      0x00000088: dcl_output o1.xyz
      0x00000094: dcl_temps 2
   0  0x0000009C: mul r0.xyzw, vDomain.yyyy, vicp[1][0].xyzw
   1  0x000000B8: mad r0.xyzw, vicp[0][0].xyzw, vDomain.xxxx, r0.xyzw
   2  0x000000DC: mad r0.xyzw, vicp[2][0].xyzw, vDomain.zzzz, r0.xyzw
   3  0x00000100: mov r1.xyz, vpc0.yzwy
   4  0x00000114: mov r1.w, l(0x00000000)
   5  0x00000128: mad r0.xyzw, r1.xyzw, vpc1.xxxx, r0.xyzw
   6  0x0000014C: dp4 o0.x, r0.xyzw, cb0[1].xyzw
   7  0x0000016C: dp4 o0.y, r0.xyzw, cb0[2].xyzw
   8  0x0000018C: dp4 o0.z, r0.xyzw, cb0[3].xyzw
   9  0x000001AC: dp4 o0.w, r0.xyzw, cb0[4].xyzw
  10  0x000001CC: mul r0.xyz, vDomain.yyyy, vicp[1][1].xyzx
  11  0x000001E8: mad r0.xyz, vicp[0][1].xyzx, vDomain.xxxx, r0.xyzx
  12  0x0000020C: mad r0.xyz, vicp[2][1].xyzx, vDomain.zzzz, r0.xyzx
  13  0x00000230: dp3 r0.w, r0.xyzx, r0.xyzx
  14  0x0000024C: rsq r0.w, r0.w
  15  0x00000260: mul r0.xyz, r0.wwww, r0.xyzx
  16  0x0000027C: mul o1.xyz, r0.xyzx, vpc3.xxxx
  17  0x00000298: ret 

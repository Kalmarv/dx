      0x00000000: ds_5_0
      0x00000008: dcl_input_control_point_count 3
      0x0000000C: dcl_tessellator_domain domain_tri
      0x00000010: dcl_globalFlags refactoringAllowed | skipOptimization
      0x00000014: dcl_constantbuffer CB0[5], immediateIndexed
      0x00000024: dcl_input vpc0.yzw
      0x00000030: dcl_input_siv vpc1.x, finalTriVeq0EdgeTessFactor
      0x00000040: dcl_input_siv vpc3.x, finalTriInsideTessFactor
      0x00000050: dcl_input vDomain.xyz
      0x00000058: dcl_input vicp[3][0].xyzw
      0x00000068: dcl_input vicp[3][1].xyz
      0x00000078: dcl_output_siv o0.xyzw, position
      0x00000088: dcl_output o1.xyz
      0x00000094: dcl_temps 3
   0  0x0000009C: mul r0.xyzw, vDomain.xxxx, vicp[0][0].xyzw
   1  0x000000B8: mul r1.xyzw, vDomain.yyyy, vicp[1][0].xyzw
   2  0x000000D4: add r0.xyzw, r0.xyzw, r1.xyzw
   3  0x000000F0: mul r1.xyzw, vDomain.zzzz, vicp[2][0].xyzw
   4  0x0000010C: add r0.xyzw, r0.xyzw, r1.xyzw
   5  0x00000128: itof r1.w, l(0x00000000)
   6  0x0000013C: mov r1.xyz, vpc0.yzwy
   7  0x00000150: mul r1.xyzw, r1.xyzw, vpc1.xxxx
   8  0x0000016C: add r0.xyzw, r0.xyzw, r1.xyzw
   9  0x00000188: dp4 r1.x, r0.xyzw, cb0[1].xyzw
  10  0x000001A8: dp4 r1.y, r0.xyzw, cb0[2].xyzw
  11  0x000001C8: dp4 r1.z, r0.xyzw, cb0[3].xyzw
  12  0x000001E8: dp4 r1.w, r0.xyzw, cb0[4].xyzw
  13  0x00000208: mul r0.xyz, vDomain.xxxx, vicp[0][1].xyzx
  14  0x00000224: mul r2.xyz, vDomain.yyyy, vicp[1][1].xyzx
  15  0x00000240: add r0.xyz, r0.xyzx, r2.xyzx
  16  0x0000025C: mul r2.xyz, vDomain.zzzz, vicp[2][1].xyzx
  17  0x00000278: add r0.xyz, r0.xyzx, r2.xyzx
  18  0x00000294: dp3 r0.w, r0.xyzx, r0.xyzx
  19  0x000002B0: rsq r0.w, r0.w
  20  0x000002C4: mul r0.xyz, r0.wwww, r0.xyzx
  21  0x000002E0: mul r0.xyz, r0.xyzx, vpc3.xxxx
  22  0x000002FC: mov o0.xyzw, r1.xyzw
  23  0x00000310: mov o1.xyz, r0.xyzx
  24  0x00000324: ret 

0x00000000: vs_5_1
0x00000008: dcl_globalFlags refactoringAllowed
0x0000000C: dcl_constantbuffer CB0[2:2][4], immediateIndexed, space=0
0x00000028: dcl_constantbuffer CB1[0:7][1], dynamicIndexed, space=1
0x00000044: dcl_input v0.xyz
0x00000050: dcl_input_sgv v1.x, instance_id
0x00000060: dcl_output_siv o0.xyzw, position
0x00000070: dcl_temps 2
0x00000078: and r0.x, v1.x, l(7)
0x00000094: mov r1.xyz, v0.xyzx
0x000000A8: mov r1.w, l(1.000000)
0x000000BC: mul r0.xyzw, r1.xyzw, CB1[r0.x + 0][0].xyzw
0x000000E4: dp4 o0.x, r0.xyzw, CB0[2][0].xyzw
0x00000108: dp4 o0.y, r0.xyzw, CB0[2][1].xyzw
0x0000012C: dp4 o0.z, r0.xyzw, CB0[2][2].xyzw
0x00000150: dp4 o0.w, r0.xyzw, CB0[2][3].xyzw
0x00000174: ret 

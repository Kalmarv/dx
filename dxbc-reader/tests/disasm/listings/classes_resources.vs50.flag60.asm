0x00000000: vs_5_0
0x00000008: dcl_globalFlags refactoringAllowed
0x0000000C: dcl_constantbuffer CB0[2], immediateIndexed
0x0000001C: dcl_function_body fb0
0x00000024: dcl_function_body fb1
0x0000002C: dcl_function_table ft0 = {fb0}
0x0000003C: dcl_function_table ft1 = {fb1}
0x0000004C: dcl_interface fp0[1][1] = {ft0, ft1}
0x00000064: dcl_input v0.xyzw
0x00000070: dcl_output_siv o0.xyzw, position
0x00000080: dcl_temps 2
0x00000088: fcall fp0[0][0]
0x0000009C: mov o0.xyzw, r0.xyzw
0x000000B0: ret 
0x000000B4: label fb0
0x000000C0: mov r0.xyzw, v0.wzyx
0x000000D4: ret 
0x000000D8: label fb1
0x000000E4: mov r1.xy, this[0].yxyy
0x000000F8: mul r0.xyzw, v0.xyzw, cb[r1.y + 0][r1.x + 0].xyzw
0x00000120: ret 

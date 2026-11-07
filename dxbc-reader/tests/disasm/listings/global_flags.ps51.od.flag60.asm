0x00000000: ps_5_1
0x00000008: dcl_globalFlags refactoringAllowed | forceEarlyDepthStencil | skipOptimization | enableMinimumPrecision | allResourcesBound
0x0000000C: dcl_constantbuffer CB0[0:0][1], immediateIndexed, space=0
0x00000028: dcl_resource_structured T0[0:0], 16, space=0
0x00000044: dcl_input_ps_siv linear noperspective v0.x, position
0x00000054: dcl_output o0.xyzw
0x00000060: dcl_temps 2
0x00000068: ftou r0.x, v0.x
0x0000007C: ld_structured r1.x, r0.x, l(0), T0[0].xxxx
0x000000A4: ld_structured r1.y, r0.x, l(4), T0[0].xxxx
0x000000CC: ld_structured r1.z, r0.x, l(8), T0[0].xxxx
0x000000F4: ld_structured r1.w, r0.x, l(12), T0[0].xxxx
0x0000011C: mov r0.xyzw, CB0[0][0].xyzw {min16f as def32}
0x0000013C: mul r0.xyzw, r0.xyzw, r1.xyzw
0x00000158: mov o0.xyzw, r0.xyzw
0x0000016C: ret 

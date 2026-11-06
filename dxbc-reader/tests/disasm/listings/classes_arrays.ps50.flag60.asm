0x00000000: ps_5_0
0x00000008: dcl_globalFlags refactoringAllowed
0x0000000C: dcl_constantbuffer CB0[3], immediateIndexed
0x0000001C: dcl_sampler s0, mode_default
0x00000028: dcl_sampler s1, mode_default
0x00000034: dcl_resource_texture2d (float,float,float,float) t0
0x00000044: dcl_resource_texture2d (float,float,float,float) t1
0x00000054: dcl_function_body fb0
0x0000005C: dcl_function_body fb1
0x00000064: dcl_function_table ft0 = {fb0}
0x00000074: dcl_function_table ft1 = {fb1}
0x00000084: dcl_interface fp0[1][1] = {ft0, ft1}
0x0000009C: dcl_input_ps linear v0.xyz
0x000000A8: dcl_output o0.xyzw
0x000000B4: dcl_temps 2
0x000000BC: fcall fp0[0][0]
0x000000D0: mov o0.xyz, r0.xyzx
0x000000E4: mov o0.w, l(1.000000)
0x000000F8: ret 
0x000000FC: label fb0
0x00000108: mov r0.w, this[0].z
0x0000011C: mov r1.x, this[0].w
0x00000130: sample_indexable(texture2d)(float,float,float,float) r0.xyz, v0.xyxx, t[r0.w + 0].xyzw, s[r1.x + 0]
0x00000164: ret 
0x00000168: label fb1
0x00000174: mov r0.w, this[0].y
0x00000188: mov r1.x, this[0].x
0x0000019C: mul r0.xyz, v0.xyzx, cb[r1.x + 0][r0.w + 0].xyzx
0x000001C4: ret 

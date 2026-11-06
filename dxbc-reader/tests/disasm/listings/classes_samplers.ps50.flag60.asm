0x00000000: ps_5_0
0x00000008: dcl_globalFlags refactoringAllowed
0x0000000C: dcl_constantbuffer CB0[2], immediateIndexed
0x0000001C: dcl_sampler s0, mode_default
0x00000028: dcl_sampler s1, mode_default
0x00000034: dcl_sampler s2, mode_default
0x00000040: dcl_sampler s3, mode_default
0x0000004C: dcl_resource_texture2d (float,float,float,float) t0
0x0000005C: dcl_function_body fb0
0x00000064: dcl_function_body fb1
0x0000006C: dcl_function_table ft0 = {fb0}
0x0000007C: dcl_function_table ft1 = {fb1}
0x0000008C: dcl_interface fp0[1][1] = {ft0, ft1}
0x000000A4: dcl_input_ps linear v0.xyz
0x000000B0: dcl_output o0.xyzw
0x000000BC: dcl_temps 3
0x000000C4: fcall fp0[0][0]
0x000000D8: mov o0.xyz, r0.xyzx
0x000000EC: mov o0.w, l(1.000000)
0x00000100: ret 
0x00000104: label fb0
0x00000110: mov r0.w, this[0].w
0x00000124: sample_indexable(texture2d)(float,float,float,float) r1.xyz, v0.xyxx, t0.xyzw, s[r0.w + 0]
0x00000154: sample_indexable(texture2d)(float,float,float,float) r2.xyz, v0.yzyy, t0.xyzw, s[r0.w + 1]
0x00000188: add r1.xyz, r1.xyzx, r2.xyzx
0x000001A4: sample_indexable(texture2d)(float,float,float,float) r2.xyz, v0.zxzz, t0.xyzw, s[r0.w + 2]
0x000001D8: mov r0.w, this[0].y
0x000001EC: mov r1.w, this[0].x
0x00000200: mad r0.xyz, r2.xyzx, cb[r1.w + 0][r0.w + 0].xxxx, r1.xyzx
0x00000230: ret 
0x00000234: label fb1
0x00000240: mov r0.w, this[0].w
0x00000254: sample_indexable(texture2d)(float,float,float,float) r1.xyz, v0.xyxx, t0.xyzw, s[r0.w + 0]
0x00000284: mov r0.w, this[0].y
0x00000298: mov r1.w, this[0].x
0x000002AC: mul r0.xyz, r1.xyzx, cb[r1.w + 0][r0.w + 0].xyzx
0x000002D4: ret 

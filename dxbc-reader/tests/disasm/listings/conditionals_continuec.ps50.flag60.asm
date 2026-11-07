0x00000000: ps_5_0
0x00000008: dcl_globalFlags refactoringAllowed
0x0000000C: dcl_constantbuffer CB0[1], immediateIndexed
0x0000001C: dcl_constantbuffer CB1[7], immediateIndexed
0x0000002C: dcl_sampler s0, mode_default
0x00000038: dcl_resource_texture2d (float,float,float,float) t2
0x00000048: dcl_function_body fb0
0x00000050: dcl_function_body fb1
0x00000058: dcl_function_body fb2
0x00000060: dcl_function_body fb3
0x00000068: dcl_function_body fb4
0x00000070: dcl_function_body fb5
0x00000078: dcl_function_body fb6
0x00000080: dcl_function_body fb7
0x00000088: dcl_function_table ft0 = {fb0, fb2}
0x0000009C: dcl_function_table ft1 = {fb1, fb3}
0x000000B0: dcl_function_table ft2 = {fb4, fb6}
0x000000C4: dcl_function_table ft3 = {fb5, fb7}
0x000000D8: dcl_interface_dynamicindexed fp0[6][2] = {ft0, ft1}
0x000000F0: dcl_interface_dynamicindexed fp6[2][2] = {ft2, ft3}
0x00000108: dcl_input_ps linear v0.xyz
0x00000114: dcl_input_ps linear v1.xyz
0x00000120: dcl_input_ps linear v2.xy
0x0000012C: dcl_output o0.xyzw
0x00000138: dcl_temps 5
0x00000140: and r0.x, cb0[0].y, l(1)
0x00000160: mov r1.xyz, l(0,0,0,0)
0x00000180: mov r0.y, l(0)
0x00000194: loop 
0x00000198:   ige r0.z, r0.y, cb0[0].x
0x000001B8:   continuec_nz l(0x40000000)
0x000001C4:   bfi r0.z, l(31), l(1), r0.y, cb0[0].y
0x000001F4:   fcall fp0[r0.z + 0][0]
0x0000020C:   bfi r0.z, l(31), l(1), r0.y, l(1)
0x00000238:   fcall fp0[r0.z + 0][1]
0x00000250:   mad r1.xyz, r2.xyzx, r0.wwww, r1.xyzx
0x00000274:   iadd r0.y, r0.y, l(1)
0x00000290: endloop 
0x00000294: fcall fp6[r0.x + 0][0]
0x000002AC: mov r1.w, l(1.000000)
0x000002C0: fcall fp6[0][1]
0x000002D4: mad o0.xyzw, r1.xyzw, r2.xyzw, r0.xyzw
0x000002F8: ret 
0x000002FC: label fb0
0x00000308: mov r0.w, this[r0.z + 0].y
0x00000320: mov r2.w, this[r0.z + 0].x
0x00000338: add r3.xyz, -v1.xyzx, cb[r2.w + 0][r0.w + 0].xyzx
0x00000364: dp3 r3.w, r3.xyzx, r3.xyzx
0x00000380: rsq r4.x, r3.w
0x00000394: mul r3.xyz, r3.xyzx, r4.xxxx
0x000003B0: dp3_sat r3.x, v0.xyzx, r3.xyzx
0x000003CC: mul r3.xyz, r3.xxxx, cb[r2.w + 0][r0.w + 1].xyzx
0x000003F8: sqrt r3.w, r3.w
0x0000040C: div r0.w, r3.w, cb[r2.w + 0][r0.w + 1].w
0x00000438: add_sat r0.w, -r0.w, l(1.000000)
0x00000458: mul r2.xyz, r0.wwww, r3.xyzx
0x00000474: ret 
0x00000478: label fb1
0x00000484: mov r0.w, this[r0.z + 0].y
0x0000049C: mov r0.z, this[r0.z + 0].x
0x000004B4: dp3_sat r2.w, v0.xyzx, cb[r0.z + 0][r0.w + 0].xyzx
0x000004DC: mul r2.xyz, r2.wwww, cb[r0.z + 0][r0.w + 1].xyzx
0x00000508: ret 
0x0000050C: label fb2
0x00000518: itof r2.w, r0.y
0x0000052C: mov r3.x, this[r0.z + 0].y
0x00000544: mov r0.z, this[r0.z + 0].x
0x0000055C: div r0.z, r2.w, cb[r0.z + 0][r3.x + 1].w
0x00000588: add_sat r0.w, -r0.z, l(1.000000)
0x000005A8: ret 
0x000005AC: label fb3
0x000005B8: mov r0.w, l(1.000000)
0x000005CC: ret 
0x000005D0: label fb4
0x000005DC: mov r0.y, this[r0.x + 6].z
0x000005F8: sample_indexable(texture2d)(float,float,float,float) r2.xyzw, v2.xyxx, t[r0.y + 0].xyzw, s0
0x00000628: ret 
0x0000062C: label fb5
0x00000638: mov r0.y, this[r0.x + 6].y
0x00000654: mov r0.x, this[r0.x + 6].x
0x00000670: mov r2.xyzw, cb[r0.x + 0][r0.y + 0].xyzw
0x00000690: ret 
0x00000694: label fb6
0x000006A0: add r3.xy, v2.xyxx, v2.xyxx
0x000006BC: mov r3.z, this[6].z
0x000006D0: sample_indexable(texture2d)(float,float,float,float) r0.xyzw, r3.xyxx, t[r3.z + 0].xyzw, s0
0x00000700: ret 
0x00000704: label fb7
0x00000710: mov r3.xy, this[6].yxyy
0x00000724: mov r0.xyzw, cb[r3.y + 0][r3.x + 0].xyzw
0x00000744: ret 

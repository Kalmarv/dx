0x00000000: ps_4_1
0x00000008: dcl_globalFlags refactoringAllowed
0x0000000C: dcl_constantbuffer CB0[17], immediateIndexed
0x0000001C: dcl_constantbuffer CB2[2], immediateIndexed
0x0000002C: dcl_sampler s0, mode_default
0x00000038: dcl_sampler s4, mode_comparison
0x00000044: dcl_resource_texture2d (float,float,float,float) t0
0x00000054: dcl_resource_texture2darray (float,float,float,float) t3
0x00000064: dcl_input_ps linear v1.xy
0x00000070: dcl_output o0.xyzw
0x0000007C: dcl_temps 3
0x00000084: mul r0.xyz, cb0[11].xyzx, cb0[13].xyzx
0x000000A8: mad r0.xyz, cb0[5].zzzz, cb0[6].xyzx, r0.xyzx
0x000000D4: sample_c_lz r0.w, v1.xyxx, t0.xxxx, s4, cb0[6].z
0x00000104: mad r0.xyz, cb0[16].xxxx, r0.wwww, r0.xyzx
0x0000012C: mov r1.xy, v1.xyxx
0x00000140: mov r1.z, l(1.000000)
0x00000154: sample r1.xyzw, r1.xyzx, t3.xyzw, s0
0x00000178: sample r2.xyzw, v1.xyxx, t0.xyzw, s0
0x0000019C: mad r1.xyzw, r2.xyzw, cb2[0].xyzw, r1.xyzw
0x000001C4: add r0.xyz, r0.xyzx, r1.xyzx
0x000001E0: mul r2.xyzw, r0.yyyy, cb0[1].xyzw
0x00000200: mad r2.xyzw, cb0[0].xyzw, r0.xxxx, r2.xyzw
0x00000228: mad r0.xyzw, cb0[2].xyzw, r0.zzzz, r2.xyzw
0x00000250: itof r1.x, cb0[7].x
0x00000268: add r1.x, r1.x, cb0[6].w
0x00000288: utof r1.y, cb2[1].x
0x000002A0: add r1.x, r1.y, r1.x
0x000002BC: add r1.x, r1.x, cb0[8].w
0x000002DC: add r1.x, r1.x, r1.w
0x000002F8: mad o0.xyzw, cb0[3].xyzw, r1.xxxx, r0.xyzw
0x00000320: ret 

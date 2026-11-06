cs_5_1
dcl_globalFlags refactoringAllowed
dcl_constantbuffer CB0[5:5][5], immediateIndexed, space=0
dcl_constantbuffer CB1[0:1][2], dynamicIndexed, space=4
dcl_sampler S0[0:0], mode_default, space=1
dcl_sampler S1[1:1], mode_comparison, space=1
dcl_resource_texture2d (float,float,float,float) T0[0:*], space=1
dcl_resource_texture2d (float,float,float,float) T1[2:2], space=2
dcl_resource_raw T2[3:3], space=2
dcl_resource_structured T3[4:4], 32, space=2
dcl_resource_buffer (uint,uint,uint,uint) T4[5:5], space=2
dcl_uav_typed_texture2d (float,float,float,float) U0[0:0], space=3
dcl_uav_raw U1[1:1], space=3
dcl_uav_structured U2[2:4], 32, space=3
dcl_input vThreadIDInGroupFlattened
dcl_input vThreadID.xy
dcl_temps 4
dcl_tgsm_structured g0, 16, 64
dcl_thread_group 8, 8, 1
ld r0.x, vThreadID.xxxx, T4[5].xyzw
utof r0.yz, vThreadID.xxyx
and r0.w, r0.x, l(0x00000001)
mul r0.yz, r0.yyzy, CB1[r0.w + 0][0].xxyx
sample_l r1.xyzw, r0.yzyy, T0[r0.x + 0].xyzw { nonuniform }, S0[0], l(0x00000000)
sample_c_lz r0.x, r0.yzyy, T1[2].xxxx, S1[1], CB0[5][4].x
udiv null, r0.y, vThreadIDInGroupFlattened.x, CB1[0][1].x
ld_structured r2.xyzw, r0.y, l(0x00000000), T3[4].xyzw
ld_structured r3.xyzw, r0.y, l(0x00000010), T3[4].xyzw
mul r0.xyzw, r0.xxxx, r1.xyzw
mul r1.xyzw, r3.yyyy, CB0[5][1].xyzw
mad r1.xyzw, CB0[5][0].xyzw, r3.xxxx, r1.xyzw
mad r1.xyzw, CB0[5][2].xyzw, r3.zzzz, r1.xyzw
add r1.xyzw, r1.xyzw, CB0[5][3].xyzw
mad r0.xyzw, r0.xyzw, r2.xyzw, r1.xyzw
store_structured g0.xyzw, vThreadIDInGroupFlattened.x, l(0x00000000), r0.xyzw
sync_g_t
iadd r0.x, vThreadIDInGroupFlattened.x, l(0x00000001)
and r0.x, r0.x, l(0x0000003f)
ld_structured r0.xyzw, r0.x, l(0x00000000), g0.xyzw
ishl r1.x, vThreadIDInGroupFlattened.x, l(0x00000002)
ld_raw r1.x, r1.x, T2[3].xxxx
add r0.xyzw, r0.xyzw, r1.xxxx
store_uav_typed U0[0].xyzw, vThreadID.xyyy, r0.xyzw
imm_atomic_iadd r0.x, U1[1], l(0x00000000), l(0x00000001)
udiv null, r0.x, r0.x, l(0x00000003)
store_structured U2[r0.x + 2].xyzw, vThreadIDInGroupFlattened.x, l(0x00000000), r2.xyzw
store_structured U2[r0.x + 2].xyzw, vThreadIDInGroupFlattened.x, l(0x00000010), r3.xyzw
ret 

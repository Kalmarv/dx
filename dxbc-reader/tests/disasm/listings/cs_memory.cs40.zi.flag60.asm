0x00000000: cs_4_0
0x00000008: dcl_globalFlags refactoringAllowed
0x0000000C: dcl_uav_structured u0, 4
0x0000001C: dcl_input vThreadIDInGroupFlattened
0x00000024: dcl_input vThreadID.x
0x0000002C: dcl_temps 1
0x00000034: dcl_tgsm_structured g0, 4, 256
0x00000048: dcl_thread_group 256, 1, 1
//
// Initial variable locations:
//   vThreadID.x <- tid; 
//   vThreadIDInGroupFlattened.x <- flat
//
#line 71 "C:\dx-fixtures\cs_memory.hlsl"
0x00000058: store_structured g0.x, vThreadIDInGroupFlattened.x, l(0), vThreadID.x

#line 72
0x00000074: sync_g_t

#line 73
0x00000078: iadd r0.x, -vThreadIDInGroupFlattened.x, l(255)
0x00000094: ld_structured r0.x, r0.x, l(0), g0.xxxx
0x000000B8: store_structured u0.x, vThreadID.x, l(0), r0.x

#line 74
0x000000D8: ret 

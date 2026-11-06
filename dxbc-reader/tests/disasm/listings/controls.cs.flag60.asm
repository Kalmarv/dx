0x00000000: cs_5_0
0x00000008: dcl_globalFlags refactoringAllowed
0x0000000C: dcl_resource_texture2d (float,float,float,float) t0
0x0000001C: dcl_uav_structured u0, 4
0x0000002C: dcl_input vThreadIDInGroupFlattened
0x00000034: dcl_temps 1
0x0000003C: dcl_tgsm_structured g0, 4, 64
0x00000050: dcl_thread_group 64, 1, 1
0x00000060: ld_structured_indexable [precise(x)](structured_buffer, stride=4)(mixed,mixed,mixed,mixed) r0.x, vThreadIDInGroupFlattened.x, l(0), u0.xxxx
0x00000088: mul [precise(x)] r0.x, r0.x, l(3.000000)
0x000000A4: iadd [precise(y)] r0.y, vThreadIDInGroupFlattened.x, l(1)
0x000000BC: ld_structured_indexable [precise(y)](structured_buffer, stride=4)(mixed,mixed,mixed,mixed) r0.y, r0.y, l(0), u0.xxxx
0x000000E8: add [precise(x)] r0.x, r0.y, r0.x
0x00000104: resinfo_indexable(texture2d)(float,float,float,float)_uint r0.yz, l(0), t0.zxyw
0x00000128: utof r0.yz, r0.yyzy
0x0000013C: add r0.x, r0.y, r0.x
0x00000158: resinfo_indexable(texture2d)(float,float,float,float) r0.yw, l(0), t0.zxwy
0x0000017C: add r0.x, r0.y, r0.x
0x00000198: store_structured g0.x, vThreadIDInGroupFlattened.x, l(0), r0.x
0x000001B8: sync_uglobal
0x000001BC: sync_uglobal_g
0x000001C0: sync_uglobal_g_t
0x000001C4: sync_g
0x000001C8: iadd r0.x, -vThreadIDInGroupFlattened.x, l(63)
0x000001E4: ld_structured r0.x, r0.x, l(0), g0.xxxx
0x00000208: add r0.x, r0.z, r0.x
0x00000224: add r0.x, r0.w, r0.x
0x00000240: store_structured u0.x, vThreadIDInGroupFlattened.x, l(0), r0.x
0x00000260: ret 

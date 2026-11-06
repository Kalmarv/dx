cs_5_0
dcl_globalFlags refactoringAllowed
dcl_resource_texture2d (float,float,float,float) t0
dcl_uav_structured u0, 4
dcl_input vThreadIDInGroupFlattened
dcl_temps 1
dcl_tgsm_structured g0, 4, 64
dcl_thread_group 64, 1, 1
ld_structured_indexable [precise(x)](structured_buffer, stride=4)(mixed,mixed,mixed,mixed) r0.x, vThreadIDInGroupFlattened.x, l(0x00000000), u0.xxxx
mul [precise(x)] r0.x, r0.x, l(0x40400000)
iadd [precise(y)] r0.y, vThreadIDInGroupFlattened.x, l(0x00000001)
ld_structured_indexable [precise(y)](structured_buffer, stride=4)(mixed,mixed,mixed,mixed) r0.y, r0.y, l(0x00000000), u0.xxxx
add [precise(x)] r0.x, r0.y, r0.x
resinfo_indexable(texture2d)(float,float,float,float)_uint r0.yz, l(0x00000000), t0.zxyw
utof r0.yz, r0.yyzy
add r0.x, r0.y, r0.x
resinfo_indexable(texture2d)(float,float,float,float) r0.yw, l(0x00000000), t0.zxwy
add r0.x, r0.y, r0.x
store_structured g0.x, vThreadIDInGroupFlattened.x, l(0x00000000), r0.x
sync_uglobal
sync_uglobal_g
sync_uglobal_g_t
sync_g
iadd r0.x, -vThreadIDInGroupFlattened.x, l(0x0000003f)
ld_structured r0.x, r0.x, l(0x00000000), g0.xxxx
add r0.x, r0.z, r0.x
add r0.x, r0.w, r0.x
store_structured u0.x, vThreadIDInGroupFlattened.x, l(0x00000000), r0.x
ret 

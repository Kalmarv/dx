cs_5_0
dcl_globalFlagsnone
dcl_constantbuffer CB0[1], immediateIndexed
dcl_uav_raw u0
dcl_uav_structured u1, 4
dcl_uav_typed_buffer (float,float,float,float) u2
dcl_input vThreadIDInGroupFlattened
dcl_input vThreadGroupID.xy
dcl_input vThreadIDInGroup.xyz
dcl_input vThreadID.xyz
dcl_temps 2
dcl_tgsm_structured g0, 4, 64
dcl_tgsm_raw g1, 4
dcl_thread_group 8, 4, 2
if_z vThreadIDInGroupFlattened.x
  store_raw g1.x, l(0x00000000), l(0x00000000)
endif 
sync_g_t
imul null, r0.xy, vThreadID.xyxx, l(0x00000064, 0x0000000a, 0x00000000, 0x00000000)
iadd r0.x, r0.y, r0.x
iadd r0.x, r0.x, vThreadID.z
store_structured g0.x, vThreadIDInGroupFlattened.x, l(0x00000000), r0.x
atomic_iadd g1, l(0x00000000), vThreadIDInGroupFlattened.x
sync_g_t
atomic_iadd u1, l(0x00000000, 0x00000000, 0x00000000, 0x00000000), l(0x00000001)
ishl r0.y, vThreadGroupID.y, l(0x00000001)
iadd r0.y, r0.y, vThreadGroupID.x
iadd r0.z, vThreadIDInGroupFlattened.x, l(0x00000001)
ishl r0.w, r0.y, l(0x00000006)
iadd r0.z, r0.w, r0.z
iadd r0.w, -vThreadIDInGroupFlattened.x, l(0x0000003f)
ld_structured r0.w, r0.w, l(0x00000000), g0.xxxx
ld_raw r1.x, l(0x00000000), g1.xxxx
iadd r0.w, r0.w, r1.x
store_structured u1.x, r0.z, l(0x00000000), r0.w
imad r0.z, r0.y, l(0x00000040), vThreadIDInGroupFlattened.x
ishl r0.w, vThreadIDInGroupFlattened.x, l(0x00000002)
imad r0.y, r0.y, l(0x00000100), r0.w
xor r0.x, r0.x, cb0[0].x
store_raw u0.x, r0.y, r0.x
utof r1.xyz, vThreadIDInGroup.xyzx
utof r1.w, vThreadIDInGroupFlattened.x
store_uav_typed u2.xyzw, r0.zzzz, r1.xyzw
ret 

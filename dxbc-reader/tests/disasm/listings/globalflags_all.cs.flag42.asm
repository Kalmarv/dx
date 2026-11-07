cs_5_0
dcl_globalFlags refactoringAllowed | enableDoublePrecisionFloatOps | enableRawAndStructuredBuffers | forceEarlyDepthStencil | skipOptimization | enableMinimumPrecision | enable11_1DoubleExtensions | enable11_1ShaderExtensions | allResourcesBound
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
  store_raw g1.x, l(0), l(0)
endif 
sync_g_t
imul null, r0.xy, vThreadID.xyxx, l(100, 10, 0, 0)
iadd r0.x, r0.y, r0.x
iadd r0.x, r0.x, vThreadID.z
store_structured g0.x, vThreadIDInGroupFlattened.x, l(0), r0.x
atomic_iadd g1, l(0), vThreadIDInGroupFlattened.x
sync_g_t
atomic_iadd u1, l(0, 0, 0, 0), l(1)
ishl r0.y, vThreadGroupID.y, l(1)
iadd r0.y, r0.y, vThreadGroupID.x
iadd r0.z, vThreadIDInGroupFlattened.x, l(1)
ishl r0.w, r0.y, l(6)
iadd r0.z, r0.w, r0.z
iadd r0.w, -vThreadIDInGroupFlattened.x, l(63)
ld_structured r0.w, r0.w, l(0), g0.xxxx
ld_raw r1.x, l(0), g1.xxxx
iadd r0.w, r0.w, r1.x
store_structured u1.x, r0.z, l(0), r0.w
imad r0.z, r0.y, l(64), vThreadIDInGroupFlattened.x
ishl r0.w, vThreadIDInGroupFlattened.x, l(2)
imad r0.y, r0.y, l(256), r0.w
xor r0.x, r0.x, cb0[0].x
store_raw u0.x, r0.y, r0.x
utof r1.xyz, vThreadIDInGroup.xyzx
utof r1.w, vThreadIDInGroupFlattened.x
store_uav_typed u2.xyzw, r0.zzzz, r1.xyzw
ret 

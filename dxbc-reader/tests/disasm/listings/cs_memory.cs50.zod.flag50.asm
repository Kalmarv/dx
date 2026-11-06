cs_5_0
dcl_globalFlags refactoringAllowed | skipOptimization
dcl_resource_structured t0, 16
dcl_resource_raw t1
dcl_uav_raw u0
dcl_uav_structured_opc u1, 16
dcl_uav_structured u2, 4
dcl_uav_structured u3, 4
dcl_uav_typed_texture1d (sint,sint,sint,sint) u4
dcl_uav_typed_texture2darray (float,float,float,float) u5
dcl_uav_typed_texture3d (uint,uint,uint,uint) u6
dcl_uav_typed_buffer (float,float,float,float) u7
dcl_uav_typed_texture1darray (unorm,unorm,unorm,unorm) u8
dcl_uav_structured_opc u9, 4
dcl_input vThreadIDInGroupFlattened
dcl_input vThreadGroupID.xyz
dcl_input vThreadIDInGroup.xy
dcl_input vThreadID.xyz
dcl_temps 3
dcl_tgsm_structured g0, 4, 64
dcl_tgsm_structured g1, 128, 8
dcl_thread_group 8, 8, 1
store_structured g0.x, vThreadIDInGroupFlattened.x, l(0), vThreadID.x
imul null, r0.x, vThreadIDInGroup.x, l(16)
ld_structured_indexable(structured_buffer, stride=16)(mixed,mixed,mixed,mixed) r0.y, vThreadIDInGroupFlattened.x, l(0), t0.xxxx
ld_structured_indexable(structured_buffer, stride=16)(mixed,mixed,mixed,mixed) r0.z, vThreadIDInGroupFlattened.x, l(4), t0.xxxx
ld_structured_indexable(structured_buffer, stride=16)(mixed,mixed,mixed,mixed) r0.w, vThreadIDInGroupFlattened.x, l(8), t0.xxxx
store_structured g1.x, vThreadIDInGroup.y, r0.x, r0.y
iadd r0.y, r0.x, l(4)
store_structured g1.x, vThreadIDInGroup.y, r0.y, r0.z
iadd r0.x, r0.x, l(8)
store_structured g1.x, vThreadIDInGroup.y, r0.x, r0.w
sync_g_t
mov r0.x, l(1)
iadd r0.x, r0.x, vThreadIDInGroupFlattened.x
mov r0.y, l(63)
and r0.x, r0.y, r0.x
ld_structured r0.x, r0.x, l(0), g0.xxxx
mov r0.x, r0.x
atomic_iadd u0, l(0), r0.x
atomic_cmp_store u0, l(4), r0.x, l(1)
atomic_umin u0, l(8), r0.x
ineg r0.y, r0.x
imm_atomic_imin r1.x, u4, vThreadGroupID.x, r0.y
mov r1.x, r1.x
atomic_umax u6, vThreadID.xyzx, r0.x
sync_uglobal
imm_atomic_alloc r2.x, u1
mov r1.y, r2.x
imul null, r0.y, vThreadIDInGroup.y, l(16)
ld_structured r0.z, vThreadIDInGroup.x, r0.y, g1.xxxx
iadd r0.w, r0.y, l(4)
ld_structured r0.w, vThreadIDInGroup.x, r0.w, g1.xxxx
iadd r0.y, r0.y, l(8)
ld_structured r0.y, vThreadIDInGroup.x, r0.y, g1.xxxx
store_structured u1.x, r1.y, l(0), r0.z
store_structured u1.x, r1.y, l(4), r0.w
store_structured u1.x, r1.y, l(8), r0.y
mov r0.y, l(3)
imul null, r0.y, r0.y, vThreadGroupID.y
iadd r0.y, r0.y, vThreadGroupID.x
iadd r0.y, r0.y, vThreadGroupID.z
store_structured u1.x, r1.y, l(12), r0.y
imm_atomic_consume r2.x, u9
store_structured u9.x, vThreadIDInGroupFlattened.x, l(0), r2.x
imm_atomic_consume r2.x, u3
ld_structured_indexable(structured_buffer, stride=4)(mixed,mixed,mixed,mixed) r0.y, r2.x, l(0), u3.xxxx
iadd r0.y, r1.x, r0.y
imm_atomic_alloc r2.x, u2
store_structured u2.x, r2.x, l(0), r0.y
sync_uglobal_g_t
mov r2.zw, l(0,0,0,0)
mov r2.xy, vThreadIDInGroup.xyxx
ld_uav_typed_indexable(texture2darray)(float,float,float,float) r0.yz, r2.xyzw, u5.zxyw
utof r2.xzw, r1.yyyy
utof r2.y, r0.x
add r0.xyzw, r0.yzyy, r2.xyzw
mov r2.xy, vThreadID.xyxx
mov r2.zw, vThreadGroupID.zzzz
store_uav_typed u5.xyzw, r2.xyzw, r0.xyzw
mov r0.x, l(1)
iadd r0.x, r0.x, vThreadIDInGroupFlattened.x
ld_uav_typed_indexable(buffer)(float,float,float,float) r0.xyzw, r0.xxxx, u7.xyzw
itof r2.xyzw, l(2, 2, 2, 2)
mul r0.xyzw, r0.xyzw, r2.xyzw
store_uav_typed u7.xyzw, vThreadIDInGroupFlattened.xxxx, r0.xyzw
itof r0.xyzw, l(1, 0, 0, 1)
store_uav_typed u8.xyzw, vThreadID.xyyy, r0.xyzw
mov r0.x, l(8)
imul null, r0.x, r0.x, vThreadIDInGroupFlattened.x
mov r0.y, l(8)
imul null, r0.y, r0.y, vThreadIDInGroupFlattened.x
ld_raw_indexable(raw_buffer)(mixed,mixed,mixed,mixed) r0.yz, r0.y, t1.xxyx
iadd r0.yz, r1.xxyx, r0.yyzy
store_raw u0.xy, r0.x, r0.yzyy
sync_g
sync_uglobal_g
sync_uglobal_t
bufinfo_indexable(structured_buffer, stride=16)(mixed,mixed,mixed,mixed) r0.x, t0.xyzw
mov r0.x, r0.x
mov r0.y, l(16)
imul null, r0.x, r0.y, r0.x
store_raw u0.x, l(512), r0.x
ret 

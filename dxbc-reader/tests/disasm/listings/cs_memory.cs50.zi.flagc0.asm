cs_5_0
dcl_globalFlags refactoringAllowed
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
dcl_temps 4
dcl_tgsm_structured g0, 4, 64
dcl_tgsm_structured g1, 128, 8
dcl_thread_group 8, 8, 1
//
// Initial variable locations:
//   vThreadID.x <- tid.x; vThreadID.y <- tid.y; vThreadID.z <- tid.z; 
//   vThreadGroupID.x <- gid.x; vThreadGroupID.y <- gid.y; vThreadGroupID.z <- gid.z; 
//   vThreadIDInGroup.x <- lid.x; vThreadIDInGroup.y <- lid.y; vThreadIDInGroup.z <- lid.z; 
//   vThreadIDInGroupFlattened.x <- flat
//
#line 30 "C:\dx-fixtures\cs_memory.hlsl"
store_structured g0.x, vThreadIDInGroupFlattened.x, l(0x00000000), vThreadID.x

#line 31
ld_structured_indexable(structured_buffer, stride=16)(mixed,mixed,mixed,mixed) r0.xyz, vThreadIDInGroupFlattened.x, l(0x00000000), t0.xyzx

#line 50
ishl r1.xy, vThreadIDInGroup.xyxx, l(0x00000004, 0x00000004, 0x00000000, 0x00000000)

#line 31
store_structured g1.xyz, vThreadIDInGroup.y, r1.x, r0.xyzx

#line 32
sync_g_t

#line 33
iadd r0.x, vThreadIDInGroupFlattened.x, l(0x00000001)
and r0.y, r0.x, l(0x0000003f)
ld_structured r0.y, r0.y, l(0x00000000), g0.xxxx  // r0.y <- v

#line 43
atomic_iadd u0, l(0x00000000), r0.y

#line 44
atomic_cmp_store u0, l(0x00000004), r0.y, l(0x00000001)

#line 45
atomic_umin u0, l(0x00000008), r0.y

#line 46
ineg r0.z, r0.y
imm_atomic_imin r2.x, u4, vThreadGroupID.x, r0.z  // r2.x <- old

#line 47
atomic_umax u6, vThreadID.xyzx, r0.y

#line 56
utof r3.y, r0.y

#line 48
sync_uglobal

#line 49
imm_atomic_alloc r2.y, u1  // r2.y <- c

#line 50
ld_structured r1.x, vThreadIDInGroup.x, r1.y, g1.xxxx
imad r0.yz, vThreadIDInGroup.yyyy, l(0x00000000, 0x00000010, 0x00000010, 0x00000000), l(0x00000000, 0x00000004, 0x00000008, 0x00000000)
ld_structured r1.y, vThreadIDInGroup.x, r0.y, g1.xxxx
ld_structured r1.z, vThreadIDInGroup.x, r0.z, g1.xxxx

#line 51
imad r0.y, vThreadGroupID.y, l(0x00000003), vThreadGroupID.x
iadd r1.w, r0.y, vThreadGroupID.z

#line 50
store_structured u1.xyzw, r2.y, l(0x00000000), r1.xyzw

#line 53
imm_atomic_consume r1.x, u9
store_structured u9.x, vThreadIDInGroupFlattened.x, l(0x00000000), r1.x

#line 54
imm_atomic_consume r1.x, u3
ld_structured_indexable(structured_buffer, stride=4)(mixed,mixed,mixed,mixed) r0.y, r1.x, l(0x00000000), u3.xxxx
iadd r0.y, r2.x, r0.y
imm_atomic_alloc r1.x, u2
store_structured u2.x, r1.x, l(0x00000000), r0.y

#line 55
sync_uglobal_g_t

#line 56
mov r1.xy, vThreadIDInGroup.xyxx
mov r1.zw, l(0x00000000,0x00000000,0x00000000,0x00000000)
ld_uav_typed_indexable(texture2darray)(float,float,float,float) r0.yz, r1.xyzw, u5.zxyw
utof r3.xzw, r2.yyyy
add r1.xyzw, r0.yzyy, r3.xyzw
mov r3.xy, vThreadID.xyxx
mov r3.zw, vThreadGroupID.zzzz
store_uav_typed u5.xyzw, r3.xyzw, r1.xyzw

#line 57
ld_uav_typed_indexable(buffer)(float,float,float,float) r0.xyzw, r0.xxxx, u7.xyzw
add r0.xyzw, r0.xyzw, r0.xyzw
store_uav_typed u7.xyzw, vThreadIDInGroupFlattened.xxxx, r0.xyzw

#line 58
store_uav_typed u8.xyzw, vThreadID.xyyy, l(0x3f800000,0x00000000,0x00000000,0x3f800000)

#line 59
ishl r0.x, vThreadIDInGroupFlattened.x, l(0x00000003)
ld_raw_indexable(raw_buffer)(mixed,mixed,mixed,mixed) r0.yz, r0.x, t1.xxyx
iadd r0.yz, r2.xxyx, r0.yyzy
store_raw u0.xy, r0.x, r0.yzyy

#line 60
sync_g

#line 61
sync_uglobal_g

#line 62
sync_uglobal_t

#line 64
bufinfo_indexable(structured_buffer, stride=16)(mixed,mixed,mixed,mixed) r0.x, t0.xyzw  // r0.x <- count

#line 65
ishl r0.x, r0.x, l(0x00000004)
store_raw u0.x, l(0x00000200), r0.x

#line 66
ret 

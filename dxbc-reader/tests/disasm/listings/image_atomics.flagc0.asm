cs_5_0
dcl_globalFlags refactoringAllowed
dcl_uav_typed_texture2d (uint,uint,uint,uint) u0
dcl_uav_typed_texture2d (sint,sint,sint,sint) u1
dcl_input vThreadID.xy
dcl_temps 2
dcl_thread_group 8, 8, 1
iadd r0.xy, vThreadID.xxxx, l(0x00000001, 0xfffffffc, 0x00000000, 0x00000000)
and r0.zw, vThreadID.xxxy, l(0x00000000, 0x00000000, 0x00000003, 0x00000003)
atomic_iadd u0, r0.zwzz, r0.x
atomic_imax u1, r0.zwzz, r0.y
iadd r0.xyzw, r0.zwzw, l(0x00000000, 0x00000004, 0x00000004, 0x00000000)
imad r1.x, vThreadID.x, l(0x0000000a), vThreadID.y
atomic_umax u0, r0.xyxx, r1.x
atomic_umin u0, r0.zwzz, r1.x
ret 

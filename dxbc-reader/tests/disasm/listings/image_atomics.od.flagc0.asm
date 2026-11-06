cs_5_0
dcl_globalFlags refactoringAllowed | skipOptimization
dcl_uav_typed_texture2d (uint,uint,uint,uint) u0
dcl_uav_typed_texture2d (sint,sint,sint,sint) u1
dcl_input vThreadID.xy
dcl_temps 2
dcl_thread_group 8, 8, 1
mov r0.x, l(0x00000004)
udiv null, r0.x, vThreadID.x, r0.x
mov r0.z, l(0x00000004)
udiv null, r0.y, vThreadID.y, r0.z
mov r0.z, l(0x00000001)
iadd r0.z, r0.z, vThreadID.x
atomic_iadd u0, r0.xyxx, r0.z
mov r0.zw, l(0x00000000,0x00000000,0x00000000,0x00000004)
iadd r0.zw, r0.zzzw, r0.xxxy
mov r1.x, l(0x0000000a)
imul null, r1.x, r1.x, vThreadID.x
iadd r1.x, r1.x, vThreadID.y
atomic_umax u0, r0.zwzz, r1.x
mov r0.zw, l(0x00000000,0x00000000,0x00000004,0x00000000)
iadd r0.zw, r0.zzzw, r0.xxxy
mov r1.x, l(0x0000000a)
imul null, r1.x, r1.x, vThreadID.x
iadd r1.x, r1.x, vThreadID.y
atomic_umin u0, r0.zwzz, r1.x
mov r0.z, vThreadID.x
ineg r0.w, l(0x00000004)
iadd r0.z, r0.w, r0.z
atomic_imax u1, r0.xyxx, r0.z
ret 

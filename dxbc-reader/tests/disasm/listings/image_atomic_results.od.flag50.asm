cs_5_0
dcl_globalFlags refactoringAllowed | skipOptimization
dcl_uav_typed_texture2d (uint,uint,uint,uint) u0
dcl_uav_typed_texture2d (uint,uint,uint,uint) u1
dcl_input vThreadID.x
dcl_temps 2
dcl_thread_group 4, 1, 1
mov r0.xy, l(0,0,0,0)
mov r0.z, l(1)
iadd r0.z, r0.z, vThreadID.x
imm_atomic_iadd r0.x, u0, r0.xyxx, r0.z
mov r0.x, r0.x
mov r1.yzw, l(0,0,0,0)
mov r1.x, vThreadID.x
store_uav_typed u1.xyzw, r1.xyzw, r0.xxxx
mov r0.xy, l(1,0,0,0)
mov r0.z, l(10)
iadd r0.z, r0.z, vThreadID.x
imm_atomic_exch r0.x, u0, r0.xyxx, r0.z
mov r0.x, r0.x
mov r1.yzw, l(0,1,1,1)
mov r1.x, vThreadID.x
store_uav_typed u1.xyzw, r1.xyzw, r0.xxxx
mov r0.xy, l(2,0,0,0)
mov r0.z, l(3)
imul null, r0.z, r0.z, vThreadID.x
imm_atomic_umax r0.x, u0, r0.xyxx, r0.z
mov r0.x, r0.x
mov r1.yzw, l(0,2,2,2)
mov r1.x, vThreadID.x
store_uav_typed u1.xyzw, r1.xyzw, r0.xxxx
ret 

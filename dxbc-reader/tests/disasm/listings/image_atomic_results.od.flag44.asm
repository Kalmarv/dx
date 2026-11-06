      cs_5_0
      dcl_globalFlags refactoringAllowed | skipOptimization
      dcl_uav_typed_texture2d (uint,uint,uint,uint) u0
      dcl_uav_typed_texture2d (uint,uint,uint,uint) u1
      dcl_input vThreadID.x
      dcl_temps 2
      dcl_thread_group 4, 1, 1
   0: mov r0.xy, l(0,0,0,0)
   1: mov r0.z, l(1)
   2: iadd r0.z, r0.z, vThreadID.x
   3: imm_atomic_iadd r0.x, u0, r0.xyxx, r0.z
   4: mov r0.x, r0.x
   5: mov r1.yzw, l(0,0,0,0)
   6: mov r1.x, vThreadID.x
   7: store_uav_typed u1.xyzw, r1.xyzw, r0.xxxx
   8: mov r0.xy, l(1,0,0,0)
   9: mov r0.z, l(10)
  10: iadd r0.z, r0.z, vThreadID.x
  11: imm_atomic_exch r0.x, u0, r0.xyxx, r0.z
  12: mov r0.x, r0.x
  13: mov r1.yzw, l(0,1,1,1)
  14: mov r1.x, vThreadID.x
  15: store_uav_typed u1.xyzw, r1.xyzw, r0.xxxx
  16: mov r0.xy, l(2,0,0,0)
  17: mov r0.z, l(3)
  18: imul null, r0.z, r0.z, vThreadID.x
  19: imm_atomic_umax r0.x, u0, r0.xyxx, r0.z
  20: mov r0.x, r0.x
  21: mov r1.yzw, l(0,2,2,2)
  22: mov r1.x, vThreadID.x
  23: store_uav_typed u1.xyzw, r1.xyzw, r0.xxxx
  24: ret 

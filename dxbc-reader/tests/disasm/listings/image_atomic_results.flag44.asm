      cs_5_0
      dcl_globalFlags refactoringAllowed
      dcl_uav_typed_texture2d (uint,uint,uint,uint) u0
      dcl_uav_typed_texture2d (uint,uint,uint,uint) u1
      dcl_input vThreadID.x
      dcl_temps 3
      dcl_thread_group 4, 1, 1
   0: iadd r0.xy, vThreadID.xxxx, l(1, 10, 0, 0)
   1: imm_atomic_iadd r1.x, u0, l(0, 0, 0, 0), r0.x
   2: imm_atomic_exch r0.x, u0, l(1, 0, 0, 0), r0.y
   3: mov r2.x, vThreadID.x
   4: mov r2.yzw, l(0,0,0,0)
   5: store_uav_typed u1.xyzw, r2.xyzw, r1.xxxx
   6: mov r1.x, vThreadID.x
   7: mov r1.yzw, l(0,1,1,1)
   8: store_uav_typed u1.xyzw, r1.xyzw, r0.xxxx
   9: imul null, r0.x, vThreadID.x, l(3)
  10: imm_atomic_umax r0.x, u0, l(2, 0, 0, 0), r0.x
  11: mov r1.x, vThreadID.x
  12: mov r1.yzw, l(0,2,2,2)
  13: store_uav_typed u1.xyzw, r1.xyzw, r0.xxxx
  14: ret 

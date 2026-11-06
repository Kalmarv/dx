      cs_5_0
      dcl_globalFlags refactoringAllowed
      dcl_uav_typed_texture2d (uint,uint,uint,uint) u0
      dcl_uav_typed_texture2d (sint,sint,sint,sint) u1
      dcl_input vThreadID.xy
      dcl_temps 2
      dcl_thread_group 8, 8, 1
   0: iadd r0.xy, vThreadID.xxxx, l(1, -4, 0, 0)
   1: and r0.zw, vThreadID.xxxy, l(0, 0, 3, 3)
   2: atomic_iadd u0, r0.zwzz, r0.x
   3: atomic_imax u1, r0.zwzz, r0.y
   4: iadd r0.xyzw, r0.zwzw, l(0, 4, 4, 0)
   5: imad r1.x, vThreadID.x, l(10), vThreadID.y
   6: atomic_umax u0, r0.xyxx, r1.x
   7: atomic_umin u0, r0.zwzz, r1.x
   8: ret 

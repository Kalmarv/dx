      0x00000000: cs_5_0
      0x00000008: dcl_globalFlags refactoringAllowed
      0x0000000C: dcl_uav_typed_texture2d (uint,uint,uint,uint) u0
      0x0000001C: dcl_uav_typed_texture2d (sint,sint,sint,sint) u1
      0x0000002C: dcl_input vThreadID.xy
      0x00000034: dcl_temps 2
      0x0000003C: dcl_thread_group 8, 8, 1
   0  0x0000004C: iadd r0.xy, vThreadID.xxxx, l(0x00000001, 0xfffffffc, 0x00000000, 0x00000000)
   1  0x00000070: and r0.zw, vThreadID.xxxy, l(0x00000000, 0x00000000, 0x00000003, 0x00000003)
   2  0x00000094: atomic_iadd u0, r0.zwzz, r0.x
   3  0x000000B0: atomic_imax u1, r0.zwzz, r0.y
   4  0x000000CC: iadd r0.xyzw, r0.zwzw, l(0x00000000, 0x00000004, 0x00000004, 0x00000000)
   5  0x000000F4: imad r1.x, vThreadID.x, l(0x0000000a), vThreadID.y
   6  0x00000110: atomic_umax u0, r0.xyxx, r1.x
   7  0x0000012C: atomic_umin u0, r0.zwzz, r1.x
   8  0x00000148: ret 

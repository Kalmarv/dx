      0x00000000: cs_5_0
      0x00000008: dcl_globalFlags refactoringAllowed | skipOptimization
      0x0000000C: dcl_uav_typed_texture2d (uint,uint,uint,uint) u0
      0x0000001C: dcl_uav_typed_texture2d (sint,sint,sint,sint) u1
      0x0000002C: dcl_input vThreadID.xy
      0x00000034: dcl_temps 2
      0x0000003C: dcl_thread_group 8, 8, 1
   0  0x0000004C: mov r0.x, l(0x00000004)
   1  0x00000060: udiv null, r0.x, vThreadID.x, r0.x
   2  0x0000007C: mov r0.z, l(0x00000004)
   3  0x00000090: udiv null, r0.y, vThreadID.y, r0.z
   4  0x000000AC: mov r0.z, l(0x00000001)
   5  0x000000C0: iadd r0.z, r0.z, vThreadID.x
   6  0x000000D8: atomic_iadd u0, r0.xyxx, r0.z
   7  0x000000F4: mov r0.zw, l(0x00000000,0x00000000,0x00000000,0x00000004)
   8  0x00000114: iadd r0.zw, r0.zzzw, r0.xxxy
   9  0x00000130: mov r1.x, l(0x0000000a)
  10  0x00000144: imul null, r1.x, r1.x, vThreadID.x
  11  0x00000160: iadd r1.x, r1.x, vThreadID.y
  12  0x00000178: atomic_umax u0, r0.zwzz, r1.x
  13  0x00000194: mov r0.zw, l(0x00000000,0x00000000,0x00000004,0x00000000)
  14  0x000001B4: iadd r0.zw, r0.zzzw, r0.xxxy
  15  0x000001D0: mov r1.x, l(0x0000000a)
  16  0x000001E4: imul null, r1.x, r1.x, vThreadID.x
  17  0x00000200: iadd r1.x, r1.x, vThreadID.y
  18  0x00000218: atomic_umin u0, r0.zwzz, r1.x
  19  0x00000234: mov r0.z, vThreadID.x
  20  0x00000244: ineg r0.w, l(0x00000004)
  21  0x00000258: iadd r0.z, r0.w, r0.z
  22  0x00000274: atomic_imax u1, r0.xyxx, r0.z
  23  0x00000290: ret 

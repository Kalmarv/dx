      0x00000000: cs_5_0
      0x00000008: dcl_globalFlags refactoringAllowed
      0x0000000C: dcl_uav_typed_texture2d (uint,uint,uint,uint) u0
      0x0000001C: dcl_uav_typed_texture2d (uint,uint,uint,uint) u1
      0x0000002C: dcl_input vThreadID.x
      0x00000034: dcl_temps 3
      0x0000003C: dcl_thread_group 4, 1, 1
   0  0x0000004C: iadd r0.xy, vThreadID.xxxx, l(0x00000001, 0x0000000a, 0x00000000, 0x00000000)
   1  0x00000070: imm_atomic_iadd r1.x, u0, l(0x00000000, 0x00000000, 0x00000000, 0x00000000), r0.x
   2  0x000000A0: imm_atomic_exch r0.x, u0, l(0x00000001, 0x00000000, 0x00000000, 0x00000000), r0.y
   3  0x000000D0: mov r2.x, vThreadID.x
   4  0x000000E0: mov r2.yzw, l(0x00000000,0x00000000,0x00000000,0x00000000)
   5  0x00000100: store_uav_typed u1.xyzw, r2.xyzw, r1.xxxx
   6  0x0000011C: mov r1.x, vThreadID.x
   7  0x0000012C: mov r1.yzw, l(0x00000000,0x00000001,0x00000001,0x00000001)
   8  0x0000014C: store_uav_typed u1.xyzw, r1.xyzw, r0.xxxx
   9  0x00000168: imul null, r0.x, vThreadID.x, l(0x00000003)
  10  0x00000184: imm_atomic_umax r0.x, u0, l(0x00000002, 0x00000000, 0x00000000, 0x00000000), r0.x
  11  0x000001B4: mov r1.x, vThreadID.x
  12  0x000001C4: mov r1.yzw, l(0x00000000,0x00000002,0x00000002,0x00000002)
  13  0x000001E4: store_uav_typed u1.xyzw, r1.xyzw, r0.xxxx
  14  0x00000200: ret 

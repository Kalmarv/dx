0x00000000: cs_5_0
0x00000008: dcl_globalFlags refactoringAllowed | skipOptimization
0x0000000C: dcl_uav_typed_texture2d (uint,uint,uint,uint) u0
0x0000001C: dcl_uav_typed_texture2d (uint,uint,uint,uint) u1
0x0000002C: dcl_input vThreadID.x
0x00000034: dcl_temps 2
0x0000003C: dcl_thread_group 4, 1, 1
0x0000004C: mov r0.xy, l(0,0,0,0)
0x0000006C: mov r0.z, l(1)
0x00000080: iadd r0.z, r0.z, vThreadID.x
0x00000098: imm_atomic_iadd r0.x, u0, r0.xyxx, r0.z
0x000000BC: mov r0.x, r0.x
0x000000D0: mov r1.yzw, l(0,0,0,0)
0x000000F0: mov r1.x, vThreadID.x
0x00000100: store_uav_typed u1.xyzw, r1.xyzw, r0.xxxx
0x0000011C: mov r0.xy, l(1,0,0,0)
0x0000013C: mov r0.z, l(10)
0x00000150: iadd r0.z, r0.z, vThreadID.x
0x00000168: imm_atomic_exch r0.x, u0, r0.xyxx, r0.z
0x0000018C: mov r0.x, r0.x
0x000001A0: mov r1.yzw, l(0,1,1,1)
0x000001C0: mov r1.x, vThreadID.x
0x000001D0: store_uav_typed u1.xyzw, r1.xyzw, r0.xxxx
0x000001EC: mov r0.xy, l(2,0,0,0)
0x0000020C: mov r0.z, l(3)
0x00000220: imul null, r0.z, r0.z, vThreadID.x
0x0000023C: imm_atomic_umax r0.x, u0, r0.xyxx, r0.z
0x00000260: mov r0.x, r0.x
0x00000274: mov r1.yzw, l(0,2,2,2)
0x00000294: mov r1.x, vThreadID.x
0x000002A4: store_uav_typed u1.xyzw, r1.xyzw, r0.xxxx
0x000002C0: ret 

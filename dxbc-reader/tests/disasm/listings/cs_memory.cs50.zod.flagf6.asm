      0x00000000: cs_5_0
      0x00000008: dcl_globalFlags refactoringAllowed | skipOptimization
      0x0000000C: dcl_resource_structured t0, 16
      0x0000001C: dcl_resource_raw t1
      0x00000028: dcl_uav_raw u0
      0x00000034: dcl_uav_structured_opc u1, 16
      0x00000044: dcl_uav_structured u2, 4
      0x00000054: dcl_uav_structured u3, 4
      0x00000064: dcl_uav_typed_texture1d (sint,sint,sint,sint) u4
      0x00000074: dcl_uav_typed_texture2darray (float,float,float,float) u5
      0x00000084: dcl_uav_typed_texture3d (uint,uint,uint,uint) u6
      0x00000094: dcl_uav_typed_buffer (float,float,float,float) u7
      0x000000A4: dcl_uav_typed_texture1darray (unorm,unorm,unorm,unorm) u8
      0x000000B4: dcl_uav_structured_opc u9, 4
      0x000000C4: dcl_input vThreadIDInGroupFlattened
      0x000000CC: dcl_input vThreadGroupID.xyz
      0x000000D4: dcl_input vThreadIDInGroup.xy
      0x000000DC: dcl_input vThreadID.xyz
      0x000000E4: dcl_temps 3
      0x000000EC: dcl_tgsm_structured g0, 4, 64
      0x00000100: dcl_tgsm_structured g1, 128, 8
      0x00000114: dcl_thread_group 8, 8, 1
   0  0x00000124: store_structured g0.x, vThreadIDInGroupFlattened.x, l(0x00000000), vThreadID.x
   1  0x00000140: imul null, r0.x, vThreadIDInGroup.x, l(0x00000010)
   2  0x0000015C: ld_structured_indexable(structured_buffer, stride=16)(mixed,mixed,mixed,mixed) r0.y, vThreadIDInGroupFlattened.x, l(0x00000000), t0.xxxx
   3  0x00000184: ld_structured_indexable(structured_buffer, stride=16)(mixed,mixed,mixed,mixed) r0.z, vThreadIDInGroupFlattened.x, l(0x00000004), t0.xxxx
   4  0x000001AC: ld_structured_indexable(structured_buffer, stride=16)(mixed,mixed,mixed,mixed) r0.w, vThreadIDInGroupFlattened.x, l(0x00000008), t0.xxxx
   5  0x000001D4: store_structured g1.x, vThreadIDInGroup.y, r0.x, r0.y
   6  0x000001F4: iadd r0.y, r0.x, l(0x00000004)
   7  0x00000210: store_structured g1.x, vThreadIDInGroup.y, r0.y, r0.z
   8  0x00000230: iadd r0.x, r0.x, l(0x00000008)
   9  0x0000024C: store_structured g1.x, vThreadIDInGroup.y, r0.x, r0.w
  10  0x0000026C: sync_g_t
  11  0x00000270: mov r0.x, l(0x00000001)
  12  0x00000284: iadd r0.x, r0.x, vThreadIDInGroupFlattened.x
  13  0x0000029C: mov r0.y, l(0x0000003f)
  14  0x000002B0: and r0.x, r0.y, r0.x
  15  0x000002CC: ld_structured r0.x, r0.x, l(0x00000000), g0.xxxx
  16  0x000002F0: mov r0.x, r0.x
  17  0x00000304: atomic_iadd u0, l(0x00000000), r0.x
  18  0x00000320: atomic_cmp_store u0, l(0x00000004), r0.x, l(0x00000001)
  19  0x00000344: atomic_umin u0, l(0x00000008), r0.x
  20  0x00000360: ineg r0.y, r0.x
  21  0x00000374: imm_atomic_imin r1.x, u4, vThreadGroupID.x, r0.y
  22  0x00000394: mov r1.x, r1.x
  23  0x000003A8: atomic_umax u6, vThreadID.xyzx, r0.x
  24  0x000003C0: sync_uglobal
  25  0x000003C4: imm_atomic_alloc r2.x, u1
  26  0x000003D8: mov r1.y, r2.x
  27  0x000003EC: imul null, r0.y, vThreadIDInGroup.y, l(0x00000010)
  28  0x00000408: ld_structured r0.z, vThreadIDInGroup.x, r0.y, g1.xxxx
  29  0x00000428: iadd r0.w, r0.y, l(0x00000004)
  30  0x00000444: ld_structured r0.w, vThreadIDInGroup.x, r0.w, g1.xxxx
  31  0x00000464: iadd r0.y, r0.y, l(0x00000008)
  32  0x00000480: ld_structured r0.y, vThreadIDInGroup.x, r0.y, g1.xxxx
  33  0x000004A0: store_structured u1.x, r1.y, l(0x00000000), r0.z
  34  0x000004C4: store_structured u1.x, r1.y, l(0x00000004), r0.w
  35  0x000004E8: store_structured u1.x, r1.y, l(0x00000008), r0.y
  36  0x0000050C: mov r0.y, l(0x00000003)
  37  0x00000520: imul null, r0.y, r0.y, vThreadGroupID.y
  38  0x0000053C: iadd r0.y, r0.y, vThreadGroupID.x
  39  0x00000554: iadd r0.y, r0.y, vThreadGroupID.z
  40  0x0000056C: store_structured u1.x, r1.y, l(0x0000000c), r0.y
  41  0x00000590: imm_atomic_consume r2.x, u9
  42  0x000005A4: store_structured u9.x, vThreadIDInGroupFlattened.x, l(0x00000000), r2.x
  43  0x000005C4: imm_atomic_consume r2.x, u3
  44  0x000005D8: ld_structured_indexable(structured_buffer, stride=4)(mixed,mixed,mixed,mixed) r0.y, r2.x, l(0x00000000), u3.xxxx
  45  0x00000604: iadd r0.y, r1.x, r0.y
  46  0x00000620: imm_atomic_alloc r2.x, u2
  47  0x00000634: store_structured u2.x, r2.x, l(0x00000000), r0.y
  48  0x00000658: sync_uglobal_g_t
  49  0x0000065C: mov r2.zw, l(0x00000000,0x00000000,0x00000000,0x00000000)
  50  0x0000067C: mov r2.xy, vThreadIDInGroup.xyxx
  51  0x0000068C: ld_uav_typed_indexable(texture2darray)(float,float,float,float) r0.yz, r2.xyzw, u5.zxyw
  52  0x000006B0: utof r2.xzw, r1.yyyy
  53  0x000006C4: utof r2.y, r0.x
  54  0x000006D8: add r0.xyzw, r0.yzyy, r2.xyzw
  55  0x000006F4: mov r2.xy, vThreadID.xyxx
  56  0x00000704: mov r2.zw, vThreadGroupID.zzzz
  57  0x00000714: store_uav_typed u5.xyzw, r2.xyzw, r0.xyzw
  58  0x00000730: mov r0.x, l(0x00000001)
  59  0x00000744: iadd r0.x, r0.x, vThreadIDInGroupFlattened.x
  60  0x0000075C: ld_uav_typed_indexable(buffer)(float,float,float,float) r0.xyzw, r0.xxxx, u7.xyzw
  61  0x00000780: itof r2.xyzw, l(0x00000002, 0x00000002, 0x00000002, 0x00000002)
  62  0x000007A0: mul r0.xyzw, r0.xyzw, r2.xyzw
  63  0x000007BC: store_uav_typed u7.xyzw, vThreadIDInGroupFlattened.xxxx, r0.xyzw
  64  0x000007D4: itof r0.xyzw, l(0x00000001, 0x00000000, 0x00000000, 0x00000001)
  65  0x000007F4: store_uav_typed u8.xyzw, vThreadID.xyyy, r0.xyzw
  66  0x0000080C: mov r0.x, l(0x00000008)
  67  0x00000820: imul null, r0.x, r0.x, vThreadIDInGroupFlattened.x
  68  0x0000083C: mov r0.y, l(0x00000008)
  69  0x00000850: imul null, r0.y, r0.y, vThreadIDInGroupFlattened.x
  70  0x0000086C: ld_raw_indexable(raw_buffer)(mixed,mixed,mixed,mixed) r0.yz, r0.y, t1.xxyx
  71  0x00000890: iadd r0.yz, r1.xxyx, r0.yyzy
  72  0x000008AC: store_raw u0.xy, r0.x, r0.yzyy
  73  0x000008C8: sync_g
  74  0x000008CC: sync_uglobal_g
  75  0x000008D0: sync_uglobal_t
  76  0x000008D4: bufinfo_indexable(structured_buffer, stride=16)(mixed,mixed,mixed,mixed) r0.x, t0.xyzw
  77  0x000008F0: mov r0.x, r0.x
  78  0x00000904: mov r0.y, l(0x00000010)
  79  0x00000918: imul null, r0.x, r0.y, r0.x
  80  0x00000938: store_raw u0.x, l(0x00000200), r0.x
  81  0x00000954: ret 

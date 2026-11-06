      0x00000000: cs_5_0
      0x00000008: dcl_globalFlagsnone
      0x0000000C: dcl_constantbuffer CB0[1], immediateIndexed
      0x0000001C: dcl_uav_raw u0
      0x00000028: dcl_uav_structured u1, 4
      0x00000038: dcl_uav_typed_buffer (float,float,float,float) u2
      0x00000048: dcl_input vThreadIDInGroupFlattened
      0x00000050: dcl_input vThreadGroupID.xy
      0x00000058: dcl_input vThreadIDInGroup.xyz
      0x00000060: dcl_input vThreadID.xyz
      0x00000068: dcl_temps 2
      0x00000070: dcl_tgsm_structured g0, 4, 64
      0x00000084: dcl_tgsm_raw g1, 4
      0x00000094: dcl_thread_group 8, 4, 2
   0  0x000000A4: if_z vThreadIDInGroupFlattened.x
   1  0x000000AC:   store_raw g1.x, l(0x00000000), l(0x00000000)
   2  0x000000C8: endif 
   3  0x000000CC: sync_g_t
   4  0x000000D0: imul null, r0.xy, vThreadID.xyxx, l(0x00000064, 0x0000000a, 0x00000000, 0x00000000)
   5  0x000000F8: iadd r0.x, r0.y, r0.x
   6  0x00000114: iadd r0.x, r0.x, vThreadID.z
   7  0x0000012C: store_structured g0.x, vThreadIDInGroupFlattened.x, l(0x00000000), r0.x
   8  0x0000014C: atomic_iadd g1, l(0x00000000), vThreadIDInGroupFlattened.x
   9  0x00000164: sync_g_t
  10  0x00000168: atomic_iadd u1, l(0x00000000, 0x00000000, 0x00000000, 0x00000000), l(0x00000001)
  11  0x00000190: ishl r0.y, vThreadGroupID.y, l(0x00000001)
  12  0x000001A8: iadd r0.y, r0.y, vThreadGroupID.x
  13  0x000001C0: iadd r0.z, vThreadIDInGroupFlattened.x, l(0x00000001)
  14  0x000001D8: ishl r0.w, r0.y, l(0x00000006)
  15  0x000001F4: iadd r0.z, r0.w, r0.z
  16  0x00000210: iadd r0.w, -vThreadIDInGroupFlattened.x, l(0x0000003f)
  17  0x0000022C: ld_structured r0.w, r0.w, l(0x00000000), g0.xxxx
  18  0x00000250: ld_raw r1.x, l(0x00000000), g1.xxxx
  19  0x0000026C: iadd r0.w, r0.w, r1.x
  20  0x00000288: store_structured u1.x, r0.z, l(0x00000000), r0.w
  21  0x000002AC: imad r0.z, r0.y, l(0x00000040), vThreadIDInGroupFlattened.x
  22  0x000002CC: ishl r0.w, vThreadIDInGroupFlattened.x, l(0x00000002)
  23  0x000002E4: imad r0.y, r0.y, l(0x00000100), r0.w
  24  0x00000308: xor r0.x, r0.x, cb0[0].x
  25  0x00000328: store_raw u0.x, r0.y, r0.x
  26  0x00000344: utof r1.xyz, vThreadIDInGroup.xyzx
  27  0x00000354: utof r1.w, vThreadIDInGroupFlattened.x
  28  0x00000364: store_uav_typed u2.xyzw, r0.zzzz, r1.xyzw
  29  0x00000380: ret 

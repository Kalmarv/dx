      0x00000000: ps_5_0
      0x00000008: dcl_globalFlags refactoringAllowed | enableMinimumPrecision
      0x0000000C: dcl_sampler s0, mode_default
      0x00000018: dcl_sampler s1, mode_comparison
      0x00000024: dcl_resource_structured t0, 4
      0x00000034: dcl_resource_raw t1
      0x00000040: dcl_resource_texture2d (float,float,float,float) t2
      0x00000050: dcl_resource_texture2d (float,float,float,float) t3
      0x00000060: dcl_uav_raw u1
      0x0000006C: dcl_input_ps linear v0.xy {min16f}
      0x0000007C: dcl_input_ps linear v0.z {min16f}
      0x0000008C: dcl_input_ps constant v1.x {min16u}
      0x0000009C: dcl_output o0.xyzw {min16f}
      0x000000AC: dcl_temps 5
   0  0x000000B4: mov r0.x, v1.x {min16u as def32}
   1  0x000000CC: ishl r1.x {min16u}, v1.x {min16u}, l(0x00000002)
   2  0x000000F0: imm_atomic_iadd r0.x, u1, r1.x {min16u}, r0.x
   3  0x00000118: ld_raw_indexable(raw_buffer)(mixed,mixed,mixed,mixed) r0.y, r1.x {min16u}, t1.xxxx
   4  0x00000140: utof r2.x {min16f}, r0.y
   5  0x00000158: utof r0.x, r0.x
   6  0x0000016C: ld_structured_indexable(structured_buffer, stride=4)(mixed,mixed,mixed,mixed) r1.x {min16u}, v1.x {min16u}, l(0x00000000), t0.xxxx
   7  0x000001A0: utof r2.y {min16f}, r1.x {min16u}
   8  0x000001BC: lod r2.z {min16f}, v0.xyxx {min16f}, t2.x, s0
   9  0x000001E8: sample_indexable(texture2d)(float,float,float,float) r1.xyzw {min16f}, v0.xyxx {min16f}, t2.xyzw, s0
  10  0x0000021C: mad r1.xyzw {min16f}, r1.xyzw {min16f}, r2.zzzz {min16f}, r2.yyyy {min16f}
  11  0x00000250: ld_structured_indexable(structured_buffer, stride=4)(mixed,mixed,mixed,mixed) r3.x {min16u}, l(0x00000003), l(0x00000000), t0.xxxx
  12  0x00000280: utof r2.y {min16f}, r3.x {min16u}
  13  0x0000029C: add r1.xyzw {min16f}, r1.xyzw {min16f}, r2.yyyy {min16f}
  14  0x000002C4: add r1.xyzw {min16f}, r2.xxxx {min16f}, r1.xyzw {min16f}
  15  0x000002EC: lod r0.y, v0.xyxx {min16f}, t3.x, s0
  16  0x00000314: sample_c_indexable(texture2d)(float,float,float,float) r2.x {min16f}, v0.xyxx {min16f}, t3.xxxx, s1, v0.z {min16f}
  17  0x00000354: add r0.y, r0.y, r2.x {min16f as def32}
  18  0x00000374: sample_c_lz_indexable(texture2d)(float,float,float,float) r2.x {min16f}, v0.xyxx {min16f}, t3.xxxx, s1, v0.z {min16f}
  19  0x000003B4: add r0.y, r0.y, r2.x {min16f as def32}
  20  0x000003D4: gather4_c_indexable(texture2d)(float,float,float,float) r2.xyzw {min16f}, v0.xyxx {min16f}, t3.xyzw, s1.x, v0.z {min16f}
  21  0x00000414: add r2.xyzw, r0.yyyy, r2.xyzw {min16f as def32}
  22  0x00000434: mov r3.xz {min16u}, v1.xxxx {min16u}
  23  0x00000450: mov r3.yw {min16u}, l(0x00000000,0x00000001,0x00000000,0x00000002) {def32 as min16u}
  24  0x00000474: gather4_po_c_indexable(texture2d)(float,float,float,float) r4.xyzw {min16f}, v0.xyxx {min16f}, r3.xyxx {min16u}, t3.xyzw, s1.x, v0.z {min16f}
  25  0x000004C0: gather4_po_indexable(texture2d)(float,float,float,float) r3.xyzw, v0.xyxx {min16f}, r3.zwzz {min16u}, t3.xyzw, s0.x
  26  0x000004FC: add r2.xyzw, r2.xyzw, r4.xyzw {min16f as def32}
  27  0x0000051C: add r2.xyzw, r3.xyzw, r2.xyzw
  28  0x00000538: add r0.xyzw, r0.xxxx, r2.xyzw
  29  0x00000554: add o0.xyzw {min16f}, r0.xyzw {def32 as min16f}, r1.xyzw {min16f}
  30  0x00000578: ret 

      0x00000000: ps_5_0
      0x00000008: dcl_globalFlags refactoringAllowed
      0x0000000C: dcl_resource_raw t0
      0x00000018: dcl_resource_structured t1, 16
      0x00000028: dcl_resource_texture2d (float,float,float,float) t2
      0x00000038: dcl_resource_texture2dms(4) (float,float,float,float) t3
      0x00000048: dcl_uav_raw u1
      0x00000054: dcl_uav_structured u2, 16
      0x00000064: dcl_input_ps linear v1.xyzw
      0x00000070: dcl_output o0.xyzw
      0x0000007C: dcl_temps 4
   0  0x00000084: ld_raw_indexable(raw_buffer)(mixed,mixed,mixed,mixed) r0.x, l(0x3f800000), t0.xxxx
   1  0x000000A8: ld_structured_indexable(structured_buffer, stride=16)(mixed,mixed,mixed,mixed) r1.xyzw, l(0x3f800000), l(0x00000000), t1.xyzw
   2  0x000000D4: add r0.xyzw, r0.xxxx, r1.xyzw
   3  0x000000F0: ld_raw_indexable(raw_buffer)(mixed,mixed,mixed,mixed) r1.x, l(0x40000000), t0.xxxx
   4  0x00000114: ld_structured_s_indexable(structured_buffer, stride=16)(mixed,mixed,mixed,mixed) r2.xyzw, r3.x, l(0x40400000), l(0x00000000), t1.xyzw
   5  0x00000148: add r1.xyzw, r1.xxxx, r2.xyzw
   6  0x00000164: check_access_fully_mapped r2.x, r3.x
   7  0x00000178: movc r2.w, r2.x, l(0x3f800000), l(0x00000000)
   8  0x0000019C: add r0.xyzw, r0.xyzw, r1.xyzw
   9  0x000001B8: ld_raw_indexable(raw_buffer)(mixed,mixed,mixed,mixed) r1.x, l(0x3f800000), u1.xxxx
  10  0x000001DC: ld_structured_indexable(structured_buffer, stride=16)(mixed,mixed,mixed,mixed) r3.xyzw, l(0x3f800000), l(0x00000000), u2.xyzw
  11  0x00000208: add r1.xyzw, r1.xxxx, r3.xyzw
  12  0x00000224: add r0.xyzw, r0.xyzw, r1.xyzw
  13  0x00000240: resinfo_indexable(texture2d)(float,float,float,float)_uint r1.xyz, l(0x3f800000), t2.xywz
  14  0x00000264: utof r2.xyz, r1.xyzx
  15  0x00000278: add r0.xyzw, r2.xyzw, r0.xyzw
  16  0x00000294: samplepos r1.xy, t3.xyxx, l(0x3f800000)
  17  0x000002B4: add r0.xy, r0.xyxx, r1.xyxx
  18  0x000002D0: eval_sample_index r1.xyzw, v1.xyzw, l(0x3f800000)
  19  0x000002EC: add o0.xyzw, r0.xyzw, r1.xyzw
  20  0x00000308: ret 

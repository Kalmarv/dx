      0x00000000: ps_5_0
      0x00000008: dcl_globalFlags refactoringAllowed
      0x0000000C: dcl_constantbuffer CB0[3], immediateIndexed
      0x0000001C: dcl_sampler s0, mode_default
      0x00000028: dcl_sampler s1, mode_comparison
      0x00000034: dcl_resource_texture2d (float,float,float,float) t0
      0x00000044: dcl_resource_texture2dms(0) (float,float,float,float) t1
      0x00000054: dcl_resource_raw t2
      0x00000060: dcl_resource_structured t3, 4
      0x00000070: dcl_uav_typed_texture2d (float,float,float,float) u1
      0x00000080: dcl_input_ps linear v0.xy
      0x0000008C: dcl_output o0.xyzw
      0x00000098: dcl_temps 15
   0  0x000000A0: sample_cl_s_indexable(texture2d)(float,float,float,float) r0.xyzw, r1.x, l(0x3e800000, 0x3f000000, 0x00000000, 0x00000000), t0.xyzw, s0, l(0x3fc00000)
   1  0x000000EC: check_access_fully_mapped r1.x, r1.x
   2  0x00000100: sample_b_cl_s_indexable(texture2d)(float,float,float,float) r2.xyzw, r3.x, l(0x3e800000, 0x3f400000, 0x00000000, 0x00000000), t0.xyzw, s0, l(0x3f000000), l(0x40200000)
   3  0x00000154: check_access_fully_mapped r1.y, r3.x
   4  0x00000168: add r0.xyzw, r0.xyzw, r2.xyzw
   5  0x00000184: and r1.x, r1.y, r1.x
   6  0x000001A0: sample_d_cl_s_indexable(texture2d)(float,float,float,float) r2.xyzw, r3.x, l(0x3e000000, 0x3f000000, 0x00000000, 0x00000000), t0.xyzw, s0, l(0x3f000000, 0x3f800000, 0x00000000, 0x00000000), l(0x3f800000, 0x40000000, 0x00000000, 0x00000000), l(0x40600000)
   7  0x00000214: check_access_fully_mapped r1.y, r3.x
   8  0x00000228: add r0.xyzw, r0.xyzw, r2.xyzw
   9  0x00000244: and r1.x, r1.y, r1.x
  10  0x00000260: sample_l_s_indexable(texture2d)(float,float,float,float) r2.xyzw, r3.x, l(0x3ec00000, 0x3f000000, 0x00000000, 0x00000000), t0.xyzw, s0, l(0x40000000)
  11  0x000002AC: check_access_fully_mapped r1.y, r3.x
  12  0x000002C0: and r1.x, r1.y, r1.x
  13  0x000002DC: sample_c_cl_s_indexable(texture2d)(float,float,float,float) r3.x, r4.x, l(0x3f200000, 0x3f000000, 0x00000000, 0x00000000), t0.xxxx, s1, l(0x3f000000), l(0x3fa00000)
  14  0x00000330: check_access_fully_mapped r1.y, r4.x
  15  0x00000344: and r1.x, r1.y, r1.x
  16  0x00000360: sample_c_lz_s_indexable(texture2d)(float,float,float,float) r4.x, r5.x, l(0x3f600000, 0x3f000000, 0x00000000, 0x00000000), t0.xxxx, s1, l(0x3f400000)
  17  0x000003AC: check_access_fully_mapped r1.y, r5.x
  18  0x000003C0: and r1.x, r1.y, r1.x
  19  0x000003DC: gather4_s_indexable(texture2d)(float,float,float,float) r5.xyzw, r6.x, l(0x3e800000, 0x3e800000, 0x00000000, 0x00000000), t0.xyzw, s0.x
  20  0x0000041C: check_access_fully_mapped r1.y, r6.x
  21  0x00000430: and r1.x, r1.y, r1.x
  22  0x0000044C: gather4_c_s_indexable(texture2d)(float,float,float,float) r6.xyzw, r7.x, l(0x3e800000, 0x3e000000, 0x00000000, 0x00000000), t0.xyzw, s1.x, l(0x3f000000)
  23  0x00000494: check_access_fully_mapped r1.y, r7.x
  24  0x000004A8: and r1.x, r1.y, r1.x
  25  0x000004C4: gather4_po_s_indexable(texture2d)(float,float,float,float) r7.xyzw, r8.x, l(0x3f000000, 0x3e800000, 0x00000000, 0x00000000), cb0[0].yzyy, t0.xyzw, s0.x
  26  0x00000510: check_access_fully_mapped r1.y, r8.x
  27  0x00000524: and r1.x, r1.y, r1.x
  28  0x00000540: gather4_po_c_s_indexable(texture2d)(float,float,float,float) r8.xyzw, r9.x, l(0x3f000000, 0x3e000000, 0x00000000, 0x00000000), cb0[0].yzyy, t0.xyzw, s1.x, l(0x3f000000)
  29  0x00000594: check_access_fully_mapped r1.y, r9.x
  30  0x000005A8: and r1.x, r1.y, r1.x
  31  0x000005C4: ld_s_indexable(texture2d)(float,float,float,float) r9.xyzw, r10.x, l(0x00000003, 0x00000004, 0x00000000, 0x00000000), t0.xyzw
  32  0x000005FC: check_access_fully_mapped r1.y, r10.x
  33  0x00000610: and r1.x, r1.y, r1.x
  34  0x0000062C: ldms_s_indexable(texture2dms)(float,float,float,float) r10.xyzw, r11.x, l(0x00000005, 0x00000006, 0x00000000, 0x00000000), t1.xyzw, l(0x00000001)
  35  0x0000066C: check_access_fully_mapped r1.y, r11.x
  36  0x00000680: and r1.x, r1.y, r1.x
  37  0x0000069C: ld_raw_s_indexable(raw_buffer)(mixed,mixed,mixed,mixed) r11.x, r12.x, l(0x00000010), t2.xxxx
  38  0x000006C8: check_access_fully_mapped r1.y, r12.x
  39  0x000006DC: utof r1.z, r11.x
  40  0x000006F0: and r1.x, r1.y, r1.x
  41  0x0000070C: ld_structured_s_indexable(structured_buffer, stride=4)(mixed,mixed,mixed,mixed) r11.x, r12.x, l(0x00000007), l(0x00000000), t3.xxxx
  42  0x00000740: check_access_fully_mapped r1.y, r12.x
  43  0x00000754: and r1.x, r1.y, r1.x
  44  0x00000770: ld_uav_typed_s_indexable(texture2d)(float,float,float,float) r12.xyzw, r13.x, l(0x00000008, 0x00000009, 0x00000009, 0x00000009), u1.xyzw
  45  0x000007A8: check_access_fully_mapped r1.y, r13.x
  46  0x000007BC: and r1.x, r1.y, r1.x
  47  0x000007D8: sample_d_cl_s_aoffimmi_indexable(1,-1,0)(texture2d)(float,float,float,float) r13.xyzw, r14.x, v0.xyxx, t0.xyzw, s0, cb0[2].xyxx, cb0[2].zwzz, cb0[2].y
  48  0x00000834: check_access_fully_mapped r1.y, r14.x
  49  0x00000848: add r0.xyzw, r0.xyzw, r13.xyzw
  50  0x00000864: add r0.xyzw, r2.xyzw, r0.xyzw
  51  0x00000880: add r0.xyzw, r3.xxxx, r0.xyzw
  52  0x0000089C: add r0.xyzw, r4.xxxx, r0.xyzw
  53  0x000008B8: add r0.xyzw, r5.xyzw, r0.xyzw
  54  0x000008D4: add r0.xyzw, r6.xyzw, r0.xyzw
  55  0x000008F0: add r0.xyzw, r7.xyzw, r0.xyzw
  56  0x0000090C: add r0.xyzw, r8.xyzw, r0.xyzw
  57  0x00000928: add r0.xyzw, r9.xyzw, r0.xyzw
  58  0x00000944: add r0.xyzw, r10.xyzw, r0.xyzw
  59  0x00000960: add r0.xyzw, r1.zzzz, r0.xyzw
  60  0x0000097C: add r0.xyzw, r11.xxxx, r0.xyzw
  61  0x00000998: add r0.xyzw, r12.xyzw, r0.xyzw
  62  0x000009B4: and r1.x, r1.y, r1.x
  63  0x000009D0: movc r1.x, r1.x, l(0x3f800000), l(0x00000000)
  64  0x000009F4: gather4_po_indexable(texture2d)(float,float,float,float) r2.xyzw, l(0x3e800000, 0x3f000000, 0x00000000, 0x00000000), cb0[0].yzyy, t0.xyzw, s0.x
  65  0x00000A38: gather4_po_c_indexable(texture2d)(float,float,float,float) r3.xyzw, v0.xyxx, cb0[0].yzyy, t0.xyzw, s1.x, l(0x3f000000)
  66  0x00000A78: add r2.xyzw, r2.xyzw, r3.xyzw
  67  0x00000A94: gather4_po_c_indexable(texture2d)(float,float,float,float) r3.xyzw, v0.xyxx, l(0xfffffff5, 0x00000001, 0x00000000, 0x00000000), t0.xyzw, s1.x, cb0[1].z
  68  0x00000AE0: add r2.xyzw, r2.xyzw, r3.xyzw
  69  0x00000AFC: gather4_po_indexable(texture2d)(float,float,float,float) r3.xyzw, v0.xyxx, l(0x00000009, 0x00000008, 0x00000000, 0x00000000), t0.xyzw, s0.x
  70  0x00000B3C: add r2.xyzw, r2.xyzw, r3.xyzw
  71  0x00000B58: sample_cl_s_aoffimmi_indexable(1,2,0)(texture2d)(float,float,float,float) r3.xyzw, null, v0.xyxx, t0.xyzw, s0, l(0x3e800000)
  72  0x00000B94: add r2.xyzw, r2.xyzw, r3.xyzw
  73  0x00000BB0: add r0.xyzw, r0.xyzw, r2.xyzw
  74  0x00000BCC: add o0.xyzw, r1.xxxx, r0.xyzw
  75  0x00000BE8: ret 

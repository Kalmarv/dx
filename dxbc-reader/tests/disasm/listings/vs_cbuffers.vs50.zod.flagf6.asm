      0x00000000: vs_5_0
      0x00000008: dcl_globalFlags refactoringAllowed | enableDoublePrecisionFloatOps | skipOptimization | enableMinimumPrecision
      0x0000000C: dcl_immediateConstantBuffer { { 0xffffffff, 0x00000000, 0x00000000, 0x00000000},
                              { 0x00000000, 0xffffffff, 0x00000000, 0x00000000},
                              { 0x00000000, 0x00000000, 0xffffffff, 0x00000000},
                              { 0x00000000, 0x00000000, 0x00000000, 0xffffffff} }
      0x00000054: dcl_constantbuffer CB0[23], dynamicIndexed
      0x00000064: dcl_constantbuffer CB3[129], dynamicIndexed
      0x00000074: dcl_resource_texture2d (float,float,float,float) t0
      0x00000084: dcl_resource_buffer (uint,uint,uint,uint) t1
      0x00000094: dcl_resource_buffer (mixed,mixed,mixed,mixed) t2
      0x000000A4: dcl_input v0.xyz
      0x000000B0: dcl_input v1.xyz
      0x000000BC: dcl_input v2.xy
      0x000000C8: dcl_input v3.xyz
      0x000000D4: dcl_input_sgv v4.x, vertex_id
      0x000000E4: dcl_input_sgv v5.x, instance_id
      0x000000F4: dcl_output_siv o0.xyzw, position
      0x00000104: dcl_output o1.xyz
      0x00000110: dcl_output o2.xy
      0x0000011C: dcl_output o3.xyzw
      0x00000128: dcl_output_siv o4.x, clip_distance
      0x00000138: dcl_output o5.x
      0x00000144: dcl_temps 7
   0  0x0000014C: mov r0.xyz, v0.xyzx
   1  0x00000160: mov r0.w, l(0x00000000)
   2  0x00000174: mov r1.xyz, r0.xyzx
   3  0x00000188: mov r1.w, r0.w
   4  0x0000019C: loop 
   5  0x000001A0:   mov r2.x, l(0x00000002)
   6  0x000001B4:   ult r2.x, r1.w, r2.x
   7  0x000001D0:   breakc_z r2.x
   8  0x000001DC:   and r2.xyz, v3.xyzx, icb[r1.w + 0].xyzx
   9  0x000001FC:   mov r2.w, l(0x00000000)
  10  0x00000210:   or r2.xy, r2.ywyy, r2.xzxx
  11  0x0000022C:   or r2.x, r2.y, r2.x
  12  0x00000248:   imul null, r2.x, r2.x, l(0x00000004)
  13  0x00000268:   mov r3.xyzw, cb3[r2.x + 0].xyzw
  14  0x00000284:   mov r4.xyzw, cb3[r2.x + 1].xyzw
  15  0x000002A4:   mov r5.xyzw, cb3[r2.x + 2].xyzw
  16  0x000002C4:   mov r2.x, cb3[r2.x + 3].x
  17  0x000002E4:   itof r6.w, l(0x00000001)
  18  0x000002F8:   mov r6.xyz, v0.xyzx
  19  0x0000030C:   dp4 r3.x, r3.xyzw, r6.xyzw
  20  0x00000328:   dp4 r3.y, r4.xyzw, r6.xyzw
  21  0x00000344:   dp4 r3.z, r5.xyzw, r6.xyzw
  22  0x00000360:   mul r2.xyz, r2.xxxx, r3.xyzx
  23  0x0000037C:   add r1.xyz, r1.xyzx, r2.xyzx
  24  0x00000398:   iadd r1.w, r1.w, l(0x00000001)
  25  0x000003B4: endloop 
  26  0x000003B8: mov r0.x, l(0x0000000f)
  27  0x000003CC: and r0.x, r0.x, v4.x
  28  0x000003E8: mov r1.w, l(0x00000004)
  29  0x000003FC: ushr r0.y, v4.x, r1.w
  30  0x00000418: mov r0.zw, l(0x00000000,0x00000000,0x00000000,0x00000000)
  31  0x00000438: ld_indexable(texture2d)(float,float,float,float) r0.x, r0.xyzw, t0.xyzw
  32  0x0000045C: add r0.x, r0.x, r1.y
  33  0x00000478: itof r0.y, l(0x00000001)
  34  0x0000048C: mul r2.xyzw, r1.xxxx, cb0[4].xyzw
  35  0x000004AC: mul r3.xyzw, r0.xxxx, cb0[5].xyzw
  36  0x000004CC: add r2.xyzw, r2.xyzw, r3.xyzw
  37  0x000004E8: mul r1.xyzw, r1.zzzz, cb0[6].xyzw
  38  0x00000508: add r1.xyzw, r1.xyzw, r2.xyzw
  39  0x00000524: mul r0.xyzw, r0.yyyy, cb0[7].xyzw
  40  0x00000544: add r0.xyzw, r0.xyzw, r1.xyzw
  41  0x00000560: dp4 r1.x, r0.xyzw, cb0[0].xyzw
  42  0x00000580: dp4 r1.y, r0.xyzw, cb0[1].xyzw
  43  0x000005A0: dp4 r1.z, r0.xyzw, cb0[2].xyzw
  44  0x000005C0: dp4 r1.w, r0.xyzw, cb0[3].xyzw
  45  0x000005E0: mul r2.xyz, cb0[8].wwww, cb0[8].xyzx
  46  0x00000604: add r2.xyz, r2.xyzx, v1.xyzx
  47  0x00000620: dp3 r0.w, r2.xyzx, r2.xyzx
  48  0x0000063C: rsq r0.w, r0.w
  49  0x00000650: mul r2.xyz, r0.wwww, r2.xyzx
  50  0x0000066C: add r3.xy, v2.xyxx, cb0[9].xyxx
  51  0x0000068C: itof r4.xyzw, l(0x00000000, 0x00000000, 0x00000000, 0x00000000)
  52  0x000006AC: mov r0.w, l(0x00000001)
  53  0x000006C0: and r0.w, r0.w, cb0[9].z
  54  0x000006E0: dp3 r2.w, v1.xyzx, cb0[11].xyzx
  55  0x00000700: max r2.w, r2.w, l(0x00000000)
  56  0x0000071C: min r2.w, r2.w, l(0x3f800000)
  57  0x00000738: mul r5.xyzw, r2.wwww, cb0[r0.w + 12].xyzw
  58  0x00000760: add r4.xyzw, r4.xyzw, r5.xyzw
  59  0x0000077C: mov r0.w, l(0x00000001)
  60  0x00000790: and r0.w, r0.w, cb0[9].z
  61  0x000007B0: dp3 r2.w, v1.xyzx, cb0[14].xyzx
  62  0x000007D0: max r2.w, r2.w, l(0x00000000)
  63  0x000007EC: min r2.w, r2.w, l(0x3f800000)
  64  0x00000808: mul r5.xyzw, r2.wwww, cb0[r0.w + 15].xyzw
  65  0x00000830: add r4.xyzw, r4.xyzw, r5.xyzw
  66  0x0000084C: mov r0.w, l(0x00000001)
  67  0x00000860: and r0.w, r0.w, cb0[9].z
  68  0x00000880: dp3 r2.w, v1.xyzx, cb0[17].xyzx
  69  0x000008A0: max r2.w, r2.w, l(0x00000000)
  70  0x000008BC: min r2.w, r2.w, l(0x3f800000)
  71  0x000008D8: mul r5.xyzw, r2.wwww, cb0[r0.w + 18].xyzw
  72  0x00000900: add r4.xyzw, r4.xyzw, r5.xyzw
  73  0x0000091C: mov r0.w, l(0x00000001)
  74  0x00000930: and r0.w, r0.w, cb0[9].z
  75  0x00000950: dp3 r2.w, v1.xyzx, cb0[20].xyzx
  76  0x00000970: max r2.w, r2.w, l(0x00000000)
  77  0x0000098C: min r2.w, r2.w, l(0x3f800000)
  78  0x000009A8: mul r5.xyzw, r2.wwww, cb0[r0.w + 21].xyzw
  79  0x000009D0: add r4.xyzw, r4.xyzw, r5.xyzw
  80  0x000009EC: ine r0.w, l(0x00000000, 0x00000000, 0x00000000, 0x00000000), cb0[10].x
  81  0x00000A18: mov r2.w, l(0x00000007)
  82  0x00000A2C: and r2.w, r2.w, v5.x
  83  0x00000A48: itof r5.xyzw, l(0x00000001, 0x00000001, 0x00000001, 0x00000001)
  84  0x00000A68: iadd r2.w, r2.w, l(0x00000000)
  85  0x00000A84: ld_indexable(buffer)(mixed,mixed,mixed,mixed) r6.xyzw, r2.wwww, t2.xyzw
  86  0x00000AA8: movc r5.xyzw, r0.wwww, r6.xyzw, r5.xyzw
  87  0x00000ACC: mul r4.xyzw, r4.xyzw, r5.xyzw
  88  0x00000AE8: dtof r0.w, cb3[127].zwzw
  89  0x00000B00: mov r2.w, cb3[128].x {min16f as def32}
  90  0x00000B1C: mul r0.w, r0.w, r2.w
  91  0x00000B38: mul r4.xyzw, r0.wwww, r4.xyzw
  92  0x00000B54: ld_indexable(buffer)(uint,uint,uint,uint) r5.xyz, v5.xxxx, t1.xyzw
  93  0x00000B78: utof r5.xyz, r5.xyzx
  94  0x00000B8C: dp3 r0.x, r0.xyzx, r5.xyzx
  95  0x00000BA8: xor r0.y, v4.x, v5.x
  96  0x00000BC4: mov o0.xyzw, r1.xyzw
  97  0x00000BD8: mov o3.xyzw, r4.xyzw
  98  0x00000BEC: mov o1.xyz, r2.xyzx
  99  0x00000C00: mov o2.xy, r3.xyxx
 100  0x00000C14: mov o4.x, r0.x
 101  0x00000C28: mov o5.x, r0.y
 102  0x00000C3C: ret 

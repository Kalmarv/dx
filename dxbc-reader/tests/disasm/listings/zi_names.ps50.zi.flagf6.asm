      0x00000000: ps_5_0
      0x00000008: dcl_globalFlags refactoringAllowed
      0x0000000C: dcl_constantbuffer CB0[2], immediateIndexed
      0x0000001C: dcl_resource_texture2d (float,float,float,float) t0
      0x0000002C: dcl_resource_structured t2, 80
      0x0000003C: dcl_input_ps linear v0.xy
      0x00000048: dcl_input_ps constant v1.x
      0x00000054: dcl_input_ps constant v1.y
      0x00000060: dcl_output o0.xyzw
      0x0000006C: dcl_temps 3
      0x00000074: dcl_indexableTemp x0[4], 4
      0x00000084: dcl_indexableTemp x1[3], 4
   0  0x00000094: mov x0[0].x, cb0[0].x
   1  0x000000B0: mov x0[1].x, cb0[0].y
   2  0x000000CC: mov x0[2].x, cb0[0].z
   3  0x000000E8: mov x0[3].x, cb0[0].w
   4  0x00000104: mov x1[0].y, cb0[0].y
   5  0x00000120: mov x1[1].y, cb0[0].w
   6  0x0000013C: mov x1[2].y, v0.y
   7  0x00000154: add r0.x, cb0[1].y, cb0[1].y
   8  0x00000178: ld_structured_indexable(structured_buffer, stride=80)(mixed,mixed,mixed,mixed) r0.y, v1.x, l(0x0000003c), t2.xxxx
   9  0x000001A4: and r0.z, v1.x, l(0x00000003)
  10  0x000001C0: mov r0.z, x0[r0.z + 0].x
  11  0x000001DC: udiv null, r0.w, v1.x, l(0x00000003)
  12  0x000001FC: mov r0.w, x1[r0.w + 0].y
  13  0x00000218: add r0.z, r0.w, r0.z
  14  0x00000234: mad r0.z, cb0[1].y, l(0x40000000), r0.z
  15  0x0000025C: utof r0.w, cb0[1].x
  16  0x00000274: add r0.z, r0.w, r0.z
  17  0x00000290: add r0.z, r0.z, cb0[0].x
  18  0x000002B0: add r0.z, r0.z, cb0[1].y
  19  0x000002D0: add r0.z, r0.z, cb0[0].z
  20  0x000002F0: add r0.z, r0.z, cb0[0].w
  21  0x00000310: add r0.z, r0.z, l(0x41080000)
  22  0x0000032C: switch v1.y
  23  0x00000338:   case l(0x00000001)
  24  0x00000344:   call label0
  25  0x00000350:   break 
  26  0x00000354:   case l(0x00000002)
  27  0x00000360:   call label1
  28  0x0000036C:   break 
  29  0x00000370:   default 
  30  0x00000374:   call label2
  31  0x00000380:   break 
  32  0x00000384: endswitch 
  33  0x00000388: mul r0.x, r0.x, r0.z
  34  0x000003A4: lt r1.x, l(0x3f800000), r0.x
  35  0x000003C0: sqrt r1.y, r0.x
  36  0x000003D4: movc r0.x, r1.x, r1.y, r0.x
  37  0x000003F8: add r0.x, r0.y, r0.x
  38  0x00000414: add r0.x, r0.w, r0.x
  39  0x00000430: add r0.x, r0.x, r0.z
  40  0x0000044C: mov r1.x, v1.x
  41  0x00000460: mov r1.yzw, l(0x00000000,0x00000000,0x00000000,0x00000000)
  42  0x00000480: ld_indexable(texture2d)(float,float,float,float) r1.xyzw, r1.xyzw, t0.xyzw
  43  0x000004A4: ld_indexable(texture2d)(float,float,float,float) r2.xyzw, l(0x00000000, 0x00000000, 0x00000000, 0x00000000), t0.xyzw
  44  0x000004D4: mad r0.xyzw, r1.xyzw, r0.xxxx, r2.xyzw
  45  0x000004F8: add o0.xyzw, r0.xyzw, l(0x41f00000, 0x42200000, 0x42480000, 0x42700000)
  46  0x00000520: ret 
  47  0x00000524: label label0
  48  0x00000530: mov r0.w, l(0x40a00000)
  49  0x00000544: ret 
  50  0x00000548: label label1
  51  0x00000554: mov r0.w, v0.x
  52  0x00000568: ret 
  53  0x0000056C: label label2
  54  0x00000578: mov r0.w, l(0x40400000)
  55  0x0000058C: ret 

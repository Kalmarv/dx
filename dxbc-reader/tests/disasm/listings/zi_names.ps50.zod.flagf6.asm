      0x00000000: ps_5_0
      0x00000008: dcl_globalFlags refactoringAllowed | skipOptimization | enableMinimumPrecision
      0x0000000C: dcl_constantbuffer CB0[2], immediateIndexed
      0x0000001C: dcl_resource_texture2d (float,float,float,float) t0
      0x0000002C: dcl_resource_structured t2, 80
      0x0000003C: dcl_input_ps linear v0.xy
      0x00000048: dcl_input_ps constant v1.x
      0x00000054: dcl_input_ps constant v1.y
      0x00000060: dcl_output o0.xyzw
      0x0000006C: dcl_temps 4
      0x00000074: dcl_indexableTemp x0[4], 4
      0x00000084: dcl_indexableTemp x1[3], 4
   0  0x00000094: mov r0.xy, l(0x40880000,0x40000000,0x00000000,0x00000000)
   1  0x000000B4: mov r0.z, cb0[1].x
   2  0x000000CC: nop 
   3  0x000000D0: mov r1.x, cb0[0].x
   4  0x000000E8: mov r1.y, cb0[1].y
   5  0x00000100: mov r1.z, cb0[0].z
   6  0x00000118: mov r2.x {min16f}, cb0[0].w {def32 as min16f}
   7  0x00000134: itof r3.xyzw, l(0x0000001e, 0x00000028, 0x00000032, 0x0000003c)
   8  0x00000154: mov x0[0].x, cb0[0].x
   9  0x00000170: mov x0[1].x, cb0[0].y
  10  0x0000018C: mov x0[2].x, cb0[0].z
  11  0x000001A8: mov x0[3].x, cb0[0].w
  12  0x000001C4: mov x1[0].y, cb0[0].y
  13  0x000001E0: mov x1[1].y, cb0[0].w
  14  0x000001FC: mov x1[2].y, v0.y
  15  0x00000214: itof r1.w, l(0x00000002)
  16  0x00000228: mul r1.w, r1.w, cb0[1].y
  17  0x00000248: ld_structured_indexable(structured_buffer, stride=80)(mixed,mixed,mixed,mixed) r2.y, v1.x, l(0x0000003c), t2.xxxx
  18  0x00000274: mov r2.z, l(0x00000004)
  19  0x00000288: udiv null, r2.z, v1.x, r2.z
  20  0x000002A8: mov r2.z, x0[r2.z + 0].x
  21  0x000002C4: mov r2.w, l(0x00000003)
  22  0x000002D8: udiv null, r2.w, v1.x, r2.w
  23  0x000002F8: mov r2.w, x1[r2.w + 0].y
  24  0x00000314: add r2.z, r2.w, r2.z
  25  0x00000330: add r2.z, r1.w, r2.z
  26  0x0000034C: utof r2.w, r0.z
  27  0x00000360: add r2.z, r2.w, r2.z
  28  0x0000037C: add r1.x, r1.x, r2.z
  29  0x00000398: add r1.x, r1.y, r1.x
  30  0x000003B4: add r1.x, r1.z, r1.x
  31  0x000003D0: mov r2.x, r2.x {min16f as def32}
  32  0x000003E8: add r1.x, r1.x, r2.x
  33  0x00000404: nop 
  34  0x00000408: nop 
  35  0x0000040C: mul r1.y, r0.y, r0.x
  36  0x00000428: add r1.x, r1.y, r1.x
  37  0x00000444: mov r1.y, v1.y
  38  0x00000458: switch r1.y
  39  0x00000464:   case l(0x00000001)
  40  0x00000470:   call label0
  41  0x0000047C:   break 
  42  0x00000480:   case l(0x00000002)
  43  0x0000048C:   call label1
  44  0x00000498:   break 
  45  0x0000049C:   default 
  46  0x000004A0:   call label2
  47  0x000004AC:   break 
  48  0x000004B0: endswitch 
  49  0x000004B4: nop 
  50  0x000004B8: mov r1.x, r1.x
  51  0x000004CC: mov r1.w, r1.w
  52  0x000004E0: mul r1.z, r1.w, r1.x
  53  0x000004FC: itof r1.w, l(0x00000001)
  54  0x00000510: lt r1.w, r1.w, r1.z
  55  0x0000052C: sqrt r2.x, r1.z
  56  0x00000540: movc r1.z, r1.w, r2.x, r1.z
  57  0x00000564: add r1.z, r2.y, r1.z
  58  0x00000580: add r1.y, r1.y, r1.z
  59  0x0000059C: add r1.x, r1.y, r1.x
  60  0x000005B8: mov r0.x, v1.x
  61  0x000005CC: mov r0.yzw, l(0x00000000,0x00000000,0x00000000,0x00000000)
  62  0x000005EC: ld_indexable(texture2d)(float,float,float,float) r0.xyzw, r0.xyzw, t0.xyzw
  63  0x00000610: mul r0.xyzw, r1.xxxx, r0.xyzw
  64  0x0000062C: ld_indexable(texture2d)(float,float,float,float) r1.xyzw, l(0x00000000, 0x00000000, 0x00000000, 0x00000000), t0.xyzw
  65  0x0000065C: add r0.xyzw, r0.xyzw, r1.xyzw
  66  0x00000678: add o0.xyzw, r3.xyzw, r0.xyzw
  67  0x00000694: ret 
  68  0x00000698: label label0
  69  0x000006A4: mov r1.y, l(0x40a00000)
  70  0x000006B8: ret 
  71  0x000006BC: label label1
  72  0x000006C8: mov r1.y, v0.x
  73  0x000006DC: ret 
  74  0x000006E0: label label2
  75  0x000006EC: mov r1.y, l(0x40400000)
  76  0x00000700: ret 

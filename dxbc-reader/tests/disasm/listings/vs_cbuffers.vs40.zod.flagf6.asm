      0x00000000: vs_4_0
      0x00000008: dcl_immediateConstantBuffer { { 0xffffffff, 0x00000000, 0x00000000, 0x00000000},
                              { 0x00000000, 0xffffffff, 0x00000000, 0x00000000},
                              { 0x00000000, 0x00000000, 0xffffffff, 0x00000000},
                              { 0x00000000, 0x00000000, 0x00000000, 0xffffffff} }
      0x00000050: dcl_constantbuffer CB0[23], dynamicIndexed
      0x00000060: dcl_constantbuffer CB3[128], dynamicIndexed
      0x00000070: dcl_resource_texture2d (float,float,float,float) t0
      0x00000080: dcl_resource_buffer (uint,uint,uint,uint) t1
      0x00000090: dcl_resource_buffer (mixed,mixed,mixed,mixed) t2
      0x000000A0: dcl_input v0.xyz
      0x000000AC: dcl_input v1.xyz
      0x000000B8: dcl_input v2.xy
      0x000000C4: dcl_input v3.xyz
      0x000000D0: dcl_input_sgv v4.x, vertex_id
      0x000000E0: dcl_input_sgv v5.x, instance_id
      0x000000F0: dcl_output_siv o0.xyzw, position
      0x00000100: dcl_output o1.xyz
      0x0000010C: dcl_output o2.xy
      0x00000118: dcl_output o3.xyzw
      0x00000124: dcl_output_siv o4.x, clip_distance
      0x00000134: dcl_output o5.x
      0x00000140: dcl_temps 7
   0  0x00000148: mov r0.xyz, v0.xyzx
   1  0x0000015C: mov r0.w, l(0x00000000)
   2  0x00000170: mov r1.xyz, r0.xyzx
   3  0x00000184: mov r1.w, r0.w
   4  0x00000198: loop 
   5  0x0000019C:   mov r2.x, l(0x00000002)
   6  0x000001B0:   ult r2.x, r1.w, r2.x
   7  0x000001CC:   breakc_z r2.x
   8  0x000001D8:   and r2.xyz, v3.xyzx, icb[r1.w + 0].xyzx
   9  0x000001F8:   mov r2.w, l(0x00000000)
  10  0x0000020C:   or r2.xy, r2.ywyy, r2.xzxx
  11  0x00000228:   or r2.x, r2.y, r2.x
  12  0x00000244:   imul null, r2.x, r2.x, l(0x00000004)
  13  0x00000264:   mov r3.xyzw, cb3[r2.x + 0].xyzw
  14  0x00000280:   mov r4.xyzw, cb3[r2.x + 1].xyzw
  15  0x000002A0:   mov r5.xyzw, cb3[r2.x + 2].xyzw
  16  0x000002C0:   mov r2.x, cb3[r2.x + 3].x
  17  0x000002E0:   itof r6.w, l(0x00000001)
  18  0x000002F4:   mov r6.xyz, v0.xyzx
  19  0x00000308:   dp4 r3.x, r3.xyzw, r6.xyzw
  20  0x00000324:   dp4 r3.y, r4.xyzw, r6.xyzw
  21  0x00000340:   dp4 r3.z, r5.xyzw, r6.xyzw
  22  0x0000035C:   mul r2.xyz, r2.xxxx, r3.xyzx
  23  0x00000378:   add r1.xyz, r1.xyzx, r2.xyzx
  24  0x00000394:   iadd r1.w, r1.w, l(0x00000001)
  25  0x000003B0: endloop 
  26  0x000003B4: mov r0.x, l(0x0000000f)
  27  0x000003C8: and r0.x, r0.x, v4.x
  28  0x000003E4: mov r1.w, l(0x00000004)
  29  0x000003F8: ushr r0.y, v4.x, r1.w
  30  0x00000414: mov r0.zw, l(0x00000000,0x00000000,0x00000000,0x00000000)
  31  0x00000434: ld r0.xyzw, r0.xyzw, t0.xyzw
  32  0x00000450: add r0.x, r0.x, r1.y
  33  0x0000046C: itof r0.y, l(0x00000001)
  34  0x00000480: mul r2.xyzw, r1.xxxx, cb0[4].xyzw
  35  0x000004A0: mul r3.xyzw, r0.xxxx, cb0[5].xyzw
  36  0x000004C0: add r2.xyzw, r2.xyzw, r3.xyzw
  37  0x000004DC: mul r1.xyzw, r1.zzzz, cb0[6].xyzw
  38  0x000004FC: add r1.xyzw, r1.xyzw, r2.xyzw
  39  0x00000518: mul r0.xyzw, r0.yyyy, cb0[7].xyzw
  40  0x00000538: add r0.xyzw, r0.xyzw, r1.xyzw
  41  0x00000554: dp4 r1.x, r0.xyzw, cb0[0].xyzw
  42  0x00000574: dp4 r1.y, r0.xyzw, cb0[1].xyzw
  43  0x00000594: dp4 r1.z, r0.xyzw, cb0[2].xyzw
  44  0x000005B4: dp4 r1.w, r0.xyzw, cb0[3].xyzw
  45  0x000005D4: mul r2.xyz, cb0[8].wwww, cb0[8].xyzx
  46  0x000005F8: add r2.xyz, r2.xyzx, v1.xyzx
  47  0x00000614: dp3 r0.w, r2.xyzx, r2.xyzx
  48  0x00000630: rsq r0.w, r0.w
  49  0x00000644: mul r2.xyz, r0.wwww, r2.xyzx
  50  0x00000660: add r3.xy, v2.xyxx, cb0[9].xyxx
  51  0x00000680: itof r4.xyzw, l(0x00000000, 0x00000000, 0x00000000, 0x00000000)
  52  0x000006A0: mov r0.w, l(0x00000001)
  53  0x000006B4: and r0.w, r0.w, cb0[9].z
  54  0x000006D4: dp3 r2.w, v1.xyzx, cb0[11].xyzx
  55  0x000006F4: max r2.w, r2.w, l(0x00000000)
  56  0x00000710: min r2.w, r2.w, l(0x3f800000)
  57  0x0000072C: mul r5.xyzw, r2.wwww, cb0[r0.w + 12].xyzw
  58  0x00000754: add r4.xyzw, r4.xyzw, r5.xyzw
  59  0x00000770: mov r0.w, l(0x00000001)
  60  0x00000784: and r0.w, r0.w, cb0[9].z
  61  0x000007A4: dp3 r2.w, v1.xyzx, cb0[14].xyzx
  62  0x000007C4: max r2.w, r2.w, l(0x00000000)
  63  0x000007E0: min r2.w, r2.w, l(0x3f800000)
  64  0x000007FC: mul r5.xyzw, r2.wwww, cb0[r0.w + 15].xyzw
  65  0x00000824: add r4.xyzw, r4.xyzw, r5.xyzw
  66  0x00000840: mov r0.w, l(0x00000001)
  67  0x00000854: and r0.w, r0.w, cb0[9].z
  68  0x00000874: dp3 r2.w, v1.xyzx, cb0[17].xyzx
  69  0x00000894: max r2.w, r2.w, l(0x00000000)
  70  0x000008B0: min r2.w, r2.w, l(0x3f800000)
  71  0x000008CC: mul r5.xyzw, r2.wwww, cb0[r0.w + 18].xyzw
  72  0x000008F4: add r4.xyzw, r4.xyzw, r5.xyzw
  73  0x00000910: mov r0.w, l(0x00000001)
  74  0x00000924: and r0.w, r0.w, cb0[9].z
  75  0x00000944: dp3 r2.w, v1.xyzx, cb0[20].xyzx
  76  0x00000964: max r2.w, r2.w, l(0x00000000)
  77  0x00000980: min r2.w, r2.w, l(0x3f800000)
  78  0x0000099C: mul r5.xyzw, r2.wwww, cb0[r0.w + 21].xyzw
  79  0x000009C4: add r4.xyzw, r4.xyzw, r5.xyzw
  80  0x000009E0: ine r0.w, l(0x00000000, 0x00000000, 0x00000000, 0x00000000), cb0[10].x
  81  0x00000A0C: mov r2.w, l(0x00000007)
  82  0x00000A20: and r2.w, r2.w, v5.x
  83  0x00000A3C: itof r5.xyzw, l(0x00000001, 0x00000001, 0x00000001, 0x00000001)
  84  0x00000A5C: iadd r2.w, r2.w, l(0x00000000)
  85  0x00000A78: ld r6.xyzw, r2.wwww, t2.xyzw
  86  0x00000A94: movc r5.xyzw, r0.wwww, r6.xyzw, r5.xyzw
  87  0x00000AB8: mul r4.xyzw, r4.xyzw, r5.xyzw
  88  0x00000AD4: ld r5.xyzw, v5.xxxx, t1.xyzw
  89  0x00000AF0: utof r5.xyz, r5.xyzx
  90  0x00000B04: dp3 r0.x, r0.xyzx, r5.xyzx
  91  0x00000B20: xor r0.y, v4.x, v5.x
  92  0x00000B3C: mov o0.xyzw, r1.xyzw
  93  0x00000B50: mov o3.xyzw, r4.xyzw
  94  0x00000B64: mov o1.xyz, r2.xyzx
  95  0x00000B78: mov o2.xy, r3.xyxx
  96  0x00000B8C: mov o4.x, r0.x
  97  0x00000BA0: mov o5.x, r0.y
  98  0x00000BB4: ret 

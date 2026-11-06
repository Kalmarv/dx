      0x00000000: ps_5_0
      0x00000008: dcl_globalFlags refactoringAllowed | skipOptimization
      0x0000000C: dcl_constantbuffer CB0[10], dynamicIndexed
      0x0000001C: dcl_sampler s0, mode_default
      0x00000028: dcl_resource_texture2d (float,float,float,float) t0
      0x00000038: dcl_input_ps linear v0.xyz
      0x00000044: dcl_input_ps linear v1.xy
      0x00000050: dcl_output o0.xyzw
      0x0000005C: dcl_temps 8
   0  0x00000064: nop 
   1  0x00000068: mov r0.xyz, v0.xyzx
   2  0x0000007C: itof r1.xyz, l(0x00000000, 0x00000000, 0x00000000, 0x00000000)
   3  0x0000009C: itof r0.w, l(0x00000000)
   4  0x000000B0: mov r1.w, l(0x00000000)
   5  0x000000C4: mov r2.xyz, r1.xyzx
   6  0x000000D8: mov r2.w, r0.w
   7  0x000000EC: mov r3.x, r1.w
   8  0x00000100: loop 
   9  0x00000104:   ilt r3.y, r3.x, cb0[9].y
  10  0x00000124:   breakc_z r3.y
  11  0x00000130:   nop 
  12  0x00000134:   mov r3.yzw, r0.xxyz
  13  0x00000148:   mov r4.x, r3.x
  14  0x0000015C:   nop 
  15  0x00000160:   mov r3.yzw, r3.yyzw
  16  0x00000174:   mov r4.yzw, cb0[r4.x + 1].xxyz
  17  0x00000194:   dp3 r4.y, r3.yzwy, r4.yzwy
  18  0x000001B0:   itof r4.z, l(0x00000000)
  19  0x000001C4:   lt r4.z, r4.z, r4.y
  20  0x000001E0:   mul r4.w, r4.y, cb0[9].x
  21  0x00000200:   mov r4.y, -r4.y
  22  0x00000218:   movc r4.y, r4.z, r4.w, r4.y
  23  0x0000023C:   mov r4.y, r4.y
  24  0x00000250:   lt r4.z, l(0x3e800000), r4.y
  25  0x0000026C:   if_nz r4.z
  26  0x00000278:     mul r5.xyz, r4.yyyy, cb0[r4.x + 1].xyzx
  27  0x000002A0:   else 
  28  0x000002A4:     itof r4.x, l(0x00000001)
  29  0x000002B8:     mov r4.z, -r4.y
  30  0x000002D0:     add r4.x, r4.z, r4.x
  31  0x000002EC:     mul r5.xyz, r3.yzwy, r4.xxxx
  32  0x00000308:   endif 
  33  0x0000030C:   nop 
  34  0x00000310:   mov r5.xyz, r5.xyzx
  35  0x00000324:   mov r3.yzw, r3.yyzw
  36  0x00000338:   dp3 r3.y, r5.xyzx, r3.yzwy
  37  0x00000354:   itof r3.z, l(0x00000000)
  38  0x00000368:   lt r3.z, r3.z, r3.y
  39  0x00000384:   mul r3.w, r3.y, cb0[9].x
  40  0x000003A4:   mov r3.y, -r3.y
  41  0x000003BC:   movc r3.y, r3.z, r3.w, r3.y
  42  0x000003E0:   add r5.w, r3.y, r4.y
  43  0x000003FC:   mov r5.xyz, r5.xyzx
  44  0x00000410:   mov r5.w, r5.w
  45  0x00000424:   mov r5.xyzw, r5.xyzw
  46  0x00000438:   mul r3.yzw, r5.wwww, r5.xxyz
  47  0x00000454:   add r2.xyz, r2.xyzx, r3.yzwy
  48  0x00000470:   add r2.w, r2.w, r5.w
  49  0x0000048C:   iadd r3.x, r3.x, l(0x00000001)
  50  0x000004A8: endloop 
  51  0x000004AC: sample_indexable(texture2d)(float,float,float,float) r0.xyzw, v1.xyxx, t0.xyzw, s0
  52  0x000004D8: max r1.x, r2.w, l(0x3a83126f)
  53  0x000004F4: div r1.xyz, r2.xyzx, r1.xxxx
  54  0x00000510: itof r1.w, l(0x00000001)
  55  0x00000524: mul r0.xyzw, r0.xyzw, r1.xyzw
  56  0x00000540: mov r0.xyzw, r0.xyzw
  57  0x00000554: nop 
  58  0x00000558: mov r1.xyz, v0.xyzx
  59  0x0000056C: mov r0.xyz, r0.xyzx
  60  0x00000580: dp3 r1.x, r1.xyzx, r0.xyzx
  61  0x0000059C: itof r1.y, l(0x00000000)
  62  0x000005B0: lt r1.y, r1.y, r1.x
  63  0x000005CC: mul r1.z, r1.x, cb0[9].x
  64  0x000005EC: mov r1.x, -r1.x
  65  0x00000604: movc r1.x, r1.y, r1.z, r1.x
  66  0x00000628: mov r1.x, r1.x
  67  0x0000063C: nop 
  68  0x00000640: mov r1.yzw, -v0.xxyz
  69  0x00000658: mul r2.xy, r1.xxxx, v1.xyxx
  70  0x00000674: itof r3.xyz, l(0x00000000, 0x00000000, 0x00000000, 0x00000000)
  71  0x00000694: itof r2.z, l(0x00000000)
  72  0x000006A8: mov r2.w, l(0x00000000)
  73  0x000006BC: mov r4.xyz, r3.xyzx
  74  0x000006D0: mov r3.w, r2.z
  75  0x000006E4: mov r4.w, r2.w
  76  0x000006F8: loop 
  77  0x000006FC:   ilt r5.x, r4.w, cb0[9].y
  78  0x0000071C:   breakc_z r5.x
  79  0x00000728:   nop 
  80  0x0000072C:   mov r5.xyz, r1.yzwy
  81  0x00000740:   mov r5.w, r4.w
  82  0x00000754:   nop 
  83  0x00000758:   mov r5.xyz, r5.xyzx
  84  0x0000076C:   mov r6.xyz, cb0[r5.w + 1].xyzx
  85  0x0000078C:   dp3 r6.x, r5.xyzx, r6.xyzx
  86  0x000007A8:   itof r6.y, l(0x00000000)
  87  0x000007BC:   lt r6.y, r6.y, r6.x
  88  0x000007D8:   mul r6.z, r6.x, cb0[9].x
  89  0x000007F8:   mov r6.x, -r6.x
  90  0x00000810:   movc r6.x, r6.y, r6.z, r6.x
  91  0x00000834:   mov r6.x, r6.x
  92  0x00000848:   lt r6.y, l(0x3e800000), r6.x
  93  0x00000864:   if_nz r6.y
  94  0x00000870:     mul r7.xyz, r6.xxxx, cb0[r5.w + 1].xyzx
  95  0x00000898:   else 
  96  0x0000089C:     itof r5.w, l(0x00000001)
  97  0x000008B0:     mov r6.y, -r6.x
  98  0x000008C8:     add r5.w, r5.w, r6.y
  99  0x000008E4:     mul r7.xyz, r5.wwww, r5.xyzx
 100  0x00000900:   endif 
 101  0x00000904:   nop 
 102  0x00000908:   mov r7.xyz, r7.xyzx
 103  0x0000091C:   mov r5.xyz, r5.xyzx
 104  0x00000930:   dp3 r5.x, r7.xyzx, r5.xyzx
 105  0x0000094C:   itof r5.y, l(0x00000000)
 106  0x00000960:   lt r5.y, r5.y, r5.x
 107  0x0000097C:   mul r5.z, r5.x, cb0[9].x
 108  0x0000099C:   mov r5.x, -r5.x
 109  0x000009B4:   movc r5.x, r5.y, r5.z, r5.x
 110  0x000009D8:   add r7.w, r5.x, r6.x
 111  0x000009F4:   mov r7.xyz, r7.xyzx
 112  0x00000A08:   mov r7.w, r7.w
 113  0x00000A1C:   mov r7.xyzw, r7.xyzw
 114  0x00000A30:   mul r5.xyz, r7.wwww, r7.xyzx
 115  0x00000A4C:   add r4.xyz, r4.xyzx, r5.xyzx
 116  0x00000A68:   add r3.w, r3.w, r7.w
 117  0x00000A84:   iadd r4.w, r4.w, l(0x00000001)
 118  0x00000AA0: endloop 
 119  0x00000AA4: sample_indexable(texture2d)(float,float,float,float) r2.xyzw, r2.xyxx, t0.xyzw, s0
 120  0x00000AD0: max r1.y, r3.w, l(0x3a83126f)
 121  0x00000AEC: div r3.xyz, r4.xyzx, r1.yyyy
 122  0x00000B08: itof r3.w, l(0x00000001)
 123  0x00000B1C: mul r2.xyzw, r2.xyzw, r3.xyzw
 124  0x00000B38: mov r2.xyzw, r2.xyzw
 125  0x00000B4C: mul r0.xyzw, r0.xyzw, cb0[0].xyzw
 126  0x00000B6C: mul r1.xyzw, r1.xxxx, r2.xyzw
 127  0x00000B88: add o0.xyzw, r0.xyzw, r1.xyzw
 128  0x00000BA4: ret 

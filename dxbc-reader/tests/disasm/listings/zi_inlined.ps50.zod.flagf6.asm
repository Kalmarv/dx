      0x00000000: ps_5_0
      0x00000008: dcl_globalFlags refactoringAllowed | skipOptimization
      0x0000000C: dcl_constantbuffer CB0[6], immediateIndexed
      0x0000001C: dcl_sampler s0, mode_default
      0x00000028: dcl_resource_texture2d (float,float,float,float) t0
      0x00000038: dcl_input_ps linear v1.xy
      0x00000044: dcl_input_ps linear v2.xyz
      0x00000050: dcl_output o0.xyzw
      0x0000005C: dcl_temps 4
   0  0x00000064: nop 
   1  0x00000068: mov r0.xyz, v2.xyzx
   2  0x0000007C: sample_indexable(texture2d)(float,float,float,float) r1.xyzw, v1.xyxx, t0.xyzw, s0
   3  0x000000A8: nop 
   4  0x000000AC: mov r0.xyz, r0.xyzx
   5  0x000000C0: mov r0.w, cb0[5].x
   6  0x000000D8: mul r0.xyz, r0.wwww, r0.xyzx
   7  0x000000F4: mul r2.xyz, r0.xyzx, l(0x3f000000, 0x3f000000, 0x3f000000, 0x00000000)
   8  0x0000011C: frc r2.xyz, r2.xyzx
   9  0x00000130: add r0.xyz, r0.xzyx, r2.xzyx
  10  0x0000014C: mov r0.xyz, r0.xyzx
  11  0x00000160: mov r0.xyz, r0.xyzx
  12  0x00000174: lt r0.w, r1.w, l(0x3f000000)
  13  0x00000190: if_nz r0.w
  14  0x0000019C:   mov r0.xy, r0.yxyy
  15  0x000001B0: endif 
  16  0x000001B4: mul r1.xyz, r0.xzyx, r1.xyzx
  17  0x000001D0: mul r0.xyzw, r1.xyzw, cb0[4].xyzw
  18  0x000001F0: mov r0.xyzw, r0.xyzw
  19  0x00000204: nop 
  20  0x00000208: itof r1.xy, l(0x00000002, 0x00000002, 0x00000000, 0x00000000)
  21  0x00000228: mul r1.xy, r1.xyxx, v1.xyxx
  22  0x00000244: mov r2.xyz, -v2.xyzx
  23  0x0000025C: sample_indexable(texture2d)(float,float,float,float) r1.xyzw, r1.xyxx, t0.xyzw, s0
  24  0x00000288: nop 
  25  0x0000028C: mov r2.xyz, r2.xyzx
  26  0x000002A0: mov r2.w, cb0[5].x
  27  0x000002B8: mul r2.xyz, r2.wwww, r2.xyzx
  28  0x000002D4: mul r3.xyz, r2.xyzx, l(0x3f000000, 0x3f000000, 0x3f000000, 0x00000000)
  29  0x000002FC: frc r3.xyz, r3.xyzx
  30  0x00000310: add r2.xyz, r2.xzyx, r3.xzyx
  31  0x0000032C: mov r2.xyz, r2.xyzx
  32  0x00000340: mov r2.xyz, r2.xyzx
  33  0x00000354: lt r2.w, r1.w, l(0x3f000000)
  34  0x00000370: if_nz r2.w
  35  0x0000037C:   mov r2.xy, r2.yxyy
  36  0x00000390: endif 
  37  0x00000394: mul r1.xyz, r1.xyzx, r2.xzyx
  38  0x000003B0: mul r1.xyzw, r1.xyzw, cb0[4].xyzw
  39  0x000003D0: mov r1.xyzw, r1.xyzw
  40  0x000003E4: mov r2.xyzw, -r0.xyzw
  41  0x000003FC: add r1.xyzw, r1.xyzw, r2.xyzw
  42  0x00000418: mul r1.xyzw, r1.xyzw, cb0[5].xxxx
  43  0x00000438: add o0.xyzw, r0.xyzw, r1.xyzw
  44  0x00000454: ret 

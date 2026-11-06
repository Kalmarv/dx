      0x00000000: ps_5_0
      0x00000008: dcl_globalFlags refactoringAllowed
      0x0000000C: dcl_constantbuffer CB0[6], immediateIndexed
      0x0000001C: dcl_sampler s0, mode_default
      0x00000028: dcl_resource_texture2d (float,float,float,float) t0
      0x00000038: dcl_input_ps linear v1.xy
      0x00000044: dcl_input_ps linear v2.xyz
      0x00000050: dcl_output o0.xyzw
      0x0000005C: dcl_temps 3
   0  0x00000064: mul r0.xyz, v2.xyzx, cb0[5].xxxx
   1  0x00000084: mul r0.xyz, r0.xyzx, l(0x3f000000, 0x3f000000, 0x3f000000, 0x00000000)
   2  0x000000AC: frc r0.xyz, r0.xyzx
   3  0x000000C0: mad r0.xyz, v2.xyzx, cb0[5].xxxx, r0.xyzx
   4  0x000000E8: sample_indexable(texture2d)(float,float,float,float) r1.xyzw, v1.xyxx, t0.xyzw, s0
   5  0x00000114: lt r0.w, r1.w, l(0x3f000000)
   6  0x00000130: movc r0.xz, r0.wwww, r0.zzxz, r0.xxzx
   7  0x00000154: mul r1.xyz, r0.xyzx, r1.xyzx
   8  0x00000170: mul r0.xyzw, r1.xyzw, cb0[4].xyzw
   9  0x00000190: mul r1.xyz, -v2.xyzx, cb0[5].xxxx
  10  0x000001B4: mul r1.xyz, r1.xyzx, l(0x3f000000, 0x3f000000, 0x3f000000, 0x00000000)
  11  0x000001DC: frc r1.xyz, r1.xyzx
  12  0x000001F0: mad r1.xyz, -v2.xyzx, cb0[5].xxxx, r1.xyzx
  13  0x0000021C: add r2.xy, v1.xyxx, v1.xyxx
  14  0x00000238: sample_indexable(texture2d)(float,float,float,float) r2.xyzw, r2.xyxx, t0.xyzw, s0
  15  0x00000264: lt r1.w, r2.w, l(0x3f000000)
  16  0x00000280: movc r1.xz, r1.wwww, r1.zzxz, r1.xxzx
  17  0x000002A4: mul r2.xyz, r1.xyzx, r2.xyzx
  18  0x000002C0: mad r1.xyzw, r2.xyzw, cb0[4].xyzw, -r0.xyzw
  19  0x000002EC: mad o0.xyzw, cb0[5].xxxx, r1.xyzw, r0.xyzw
  20  0x00000314: ret 

      0x00000000: ps_4_0
      0x00000008: dcl_constantbuffer CB1[3], immediateIndexed
      0x00000018: dcl_constantbuffer CB2[3], immediateIndexed
      0x00000028: dcl_sampler s0, mode_default
      0x00000034: dcl_sampler s2, mode_default
      0x00000040: dcl_resource_texture2d (float,float,float,float) t1
      0x00000050: dcl_resource_texturecube (float,float,float,float) t3
      0x00000060: dcl_input_ps linear v0.xy
      0x0000006C: dcl_output o0.xyzw
      0x00000078: dcl_temps 4
   0  0x00000080: sample r0.xyzw, v0.xyxx, t1.xyzw, s2
   1  0x000000A4: itof r1.xyzw, cb1[0].xxxx
   2  0x000000BC: mul r0.xyzw, r0.xyzw, r1.xyzw
   3  0x000000D8: sample r1.xyzw, v0.xyyx, t3.xyzw, s0
   4  0x000000FC: utof r2.xyzw, cb1[1].yyyy
   5  0x00000114: mul r1.xyzw, r1.xyzw, r2.xyzw
   6  0x00000130: add r0.xyzw, r0.xyzw, r1.xyzw
   7  0x0000014C: ine r1.x, l(0x00000000, 0x00000000, 0x00000000, 0x00000000), cb1[2].x
   8  0x00000178: mul r2.xyzw, r0.xyzw, cb1[2].yyyy
   9  0x00000198: add r2.xyzw, r2.xyzw, cb2[2].xyzw
  10  0x000001B8: mov r3.xyzw, -cb2[0].xyzw
  11  0x000001D4: add r0.xyzw, r0.xyzw, r3.xyzw
  12  0x000001F0: movc o0.xyzw, r1.xxxx, r2.xyzw, r0.xyzw
  13  0x00000214: ret 

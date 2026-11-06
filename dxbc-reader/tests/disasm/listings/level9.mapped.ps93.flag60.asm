0x00000000: ps_4_0
0x00000008: dcl_constantbuffer CB1[3], immediateIndexed
0x00000018: dcl_constantbuffer CB2[3], immediateIndexed
0x00000028: dcl_sampler s0, mode_default
0x00000034: dcl_sampler s2, mode_default
0x00000040: dcl_resource_texture2d (float,float,float,float) t1
0x00000050: dcl_resource_texturecube (float,float,float,float) t3
0x00000060: dcl_input_ps linear v0.xy
0x0000006C: dcl_output o0.xyzw
0x00000078: dcl_temps 3
0x00000080: sample r0.xyzw, v0.xyyx, t3.xyzw, s0
0x000000A4: utof r1.x, cb1[1].y
0x000000BC: mul r0.xyzw, r0.xyzw, r1.xxxx
0x000000D8: sample r1.xyzw, v0.xyxx, t1.xyzw, s2
0x000000FC: itof r2.x, cb1[0].x
0x00000114: mad r0.xyzw, r1.xyzw, r2.xxxx, r0.xyzw
0x00000138: mad r1.xyzw, r0.xyzw, cb1[2].yyyy, cb2[2].xyzw
0x00000164: add r0.xyzw, r0.xyzw, -cb2[0].xyzw
0x00000188: movc o0.xyzw, cb1[2].xxxx, r1.xyzw, r0.xyzw
0x000001B0: ret 

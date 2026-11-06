      0x00000000: ps_4_0
      0x00000008: dcl_constantbuffer CB0[5], immediateIndexed
      0x00000018: dcl_sampler s0, mode_default
      0x00000024: dcl_sampler s1, mode_default
      0x00000030: dcl_resource_texture2d (float,float,float,float) t0
      0x00000040: dcl_resource_texture2d (float,float,float,float) t1
      0x00000050: dcl_input_ps linear v0.xy
      0x0000005C: dcl_input_ps linear v1.xyzw
      0x00000068: dcl_output o0.xyzw
      0x00000074: dcl_temps 2
   0  0x0000007C: sample r0.xyzw, v0.xyxx, t0.xyzw, s0
   1  0x000000A0: mad r0.xyzw, r0.xyzw, v1.xyzw, cb0[2].xyzw
   2  0x000000C8: lt r1.x, r0.w, cb0[4].x
   3  0x000000E8: discard_nz r1.x
   4  0x000000F4: mul r1.xy, v0.xyxx, cb0[0].xyxx
   5  0x00000114: sample r1.xyzw, r1.xyxx, t1.xyzw, s1
   6  0x00000138: add r1.xyzw, -r0.xyzw, r1.xyzw
   7  0x00000158: mad r0.xyzw, cb0[3].xxxx, r1.xyzw, r0.xyzw
   8  0x00000180: mad o0.xyzw, cb0[1].xyzw, cb0[0].xyzw, r0.xyzw
   9  0x000001AC: ret 

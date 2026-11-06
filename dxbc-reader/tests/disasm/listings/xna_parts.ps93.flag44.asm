      ps_4_0
      dcl_constantbuffer CB1[3], immediateIndexed
      dcl_constantbuffer CB2[3], immediateIndexed
      dcl_sampler s0, mode_default
      dcl_sampler s2, mode_default
      dcl_resource_texture2d (float,float,float,float) t1
      dcl_resource_texturecube (float,float,float,float) t3
      dcl_input_ps linear v0.xy
      dcl_output o0.xyzw
      dcl_temps 3
   0: sample r0.xyzw, v0.xyyx, t3.xyzw, s0
   1: utof r1.x, cb1[1].y
   2: mul r0.xyzw, r0.xyzw, r1.xxxx
   3: sample r1.xyzw, v0.xyxx, t1.xyzw, s2
   4: itof r2.x, cb1[0].x
   5: mad r0.xyzw, r1.xyzw, r2.xxxx, r0.xyzw
   6: mad r1.xyzw, r0.xyzw, cb1[2].yyyy, cb2[2].xyzw
   7: add r0.xyzw, r0.xyzw, -cb2[0].xyzw
   8: movc o0.xyzw, cb1[2].xxxx, r1.xyzw, r0.xyzw
   9: ret 

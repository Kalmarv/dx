      ps_4_0
      dcl_constantbuffer CB0[5], immediateIndexed
      dcl_sampler s0, mode_default
      dcl_sampler s1, mode_default
      dcl_resource_texture2d (float,float,float,float) t0
      dcl_resource_texture2d (float,float,float,float) t1
      dcl_input_ps linear v0.xy
      dcl_input_ps linear v1.xyzw
      dcl_output o0.xyzw
      dcl_temps 2
   0: sample r0.xyzw, v0.xyxx, t0.xyzw, s0
   1: mad r0.xyzw, r0.xyzw, v1.xyzw, cb0[2].xyzw
   2: lt r1.x, r0.w, cb0[4].x
   3: discard_nz r1.x
   4: mul r1.xy, v0.xyxx, cb0[0].xyxx
   5: sample r1.xyzw, r1.xyxx, t1.xyzw, s1
   6: add r1.xyzw, -r0.xyzw, r1.xyzw
   7: mad r0.xyzw, cb0[3].xxxx, r1.xyzw, r0.xyzw
   8: mad o0.xyzw, cb0[1].xyzw, cb0[0].xyzw, r0.xyzw
   9: ret 

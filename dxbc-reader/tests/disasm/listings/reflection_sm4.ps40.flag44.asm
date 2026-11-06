      ps_4_0
      dcl_constantbuffer CB0[17], immediateIndexed
      dcl_constantbuffer CB2[2], immediateIndexed
      dcl_sampler s0, mode_default
      dcl_sampler s4, mode_comparison
      dcl_resource_texture2d (float,float,float,float) t0
      dcl_resource_texture2darray (float,float,float,float) t3
      dcl_input_ps linear v1.xy
      dcl_output o0.xyzw
      dcl_temps 3
   0: mul r0.xyz, cb0[11].xyzx, cb0[13].xyzx
   1: mad r0.xyz, cb0[5].zzzz, cb0[6].xyzx, r0.xyzx
   2: sample_c_lz r0.w, v1.xyxx, t0.xxxx, s4, cb0[6].z
   3: mad r0.xyz, cb0[16].xxxx, r0.wwww, r0.xyzx
   4: mov r1.xy, v1.xyxx
   5: mov r1.z, l(1.000000)
   6: sample r1.xyzw, r1.xyzx, t3.xyzw, s0
   7: sample r2.xyzw, v1.xyxx, t0.xyzw, s0
   8: mad r1.xyzw, r2.xyzw, cb2[0].xyzw, r1.xyzw
   9: add r0.xyz, r0.xyzx, r1.xyzx
  10: mul r2.xyzw, r0.yyyy, cb0[1].xyzw
  11: mad r2.xyzw, cb0[0].xyzw, r0.xxxx, r2.xyzw
  12: mad r0.xyzw, cb0[2].xyzw, r0.zzzz, r2.xyzw
  13: itof r1.x, cb0[7].x
  14: add r1.x, r1.x, cb0[6].w
  15: utof r1.y, cb2[1].x
  16: add r1.x, r1.y, r1.x
  17: add r1.x, r1.x, cb0[8].w
  18: add r1.x, r1.x, r1.w
  19: mad o0.xyzw, cb0[3].xyzw, r1.xxxx, r0.xyzw
  20: ret 

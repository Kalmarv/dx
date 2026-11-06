      ps_5_0
      dcl_globalFlags refactoringAllowed | enableDoublePrecisionFloatOps | forceEarlyDepthStencil | enableMinimumPrecision | enable11_1DoubleExtensions
      dcl_constantbuffer CB0[3], immediateIndexed
      dcl_uav_typed_texture2d (float,float,float,float) u2
      dcl_uav_structured u3, 4
      dcl_uav_raw_glc u4
      dcl_input_ps_siv linear noperspective v0.xyz, position
      dcl_input_ps linear v1.xyzw
      dcl_input_ps linear sample v2.xy
      dcl_input_ps linear noperspective centroid v3.xyz
      dcl_input_ps linear noperspective sample v4.x
      dcl_input_ps linear v5.xy {min16f}
      dcl_input_ps_sgv constant v6.x, sampleIndex
      dcl_input vCoverage
      dcl_output o0.xyzw
      dcl_output o1.xyzw {min16f}
      dcl_output oMask
      dcl_output oDepthGE
      dcl_temps 4
      dcl_indexableTemp x0[5], 4
   0: mov x0[0].xyzw, l(0,0,0,0)
   1: mov x0[1].xyzw, v1.xyzw
   2: add r0.xyzw, v1.xyzw, v1.xyzw
   3: mov x0[2].xyzw, r0.xyzw
   4: mul r0.xyzw, v1.xyzw, l(3.000000, 3.000000, 3.000000, 3.000000)
   5: mov x0[3].xyzw, r0.xyzw
   6: mul r0.xyzw, v1.xyzw, l(4.000000, 4.000000, 4.000000, 4.000000)
   7: mov x0[4].xyzw, r0.xyzw
   8: mov r0.x, cb0[2].x
   9: mov r0.y, l(0)
  10: imm_atomic_iadd r0.x, u3, r0.xyxx, l(1)
  11: udiv null, r0.y, cb0[2].x, l(5)
  12: mov r1.xyzw, x0[r0.y + 0].xyzw
  13: eval_sample_index r2.xyzw, v1.xyzw, v6.x
  14: eval_centroid r3.xyzw, v1.xyzw
  15: add r2.xyzw, r2.xyzw, r3.xyzw
  16: eval_snapped r3.xyzw, v1.xyzw, l(1, -1, 0, 0)
  17: add r2.xyzw, r2.xyzw, r3.xyzw
  18: add r1.xyzw, r1.xyzw, r2.xyzw
  19: samplepos r0.yz, rasterizer.xxyx, v6.x
  20: sampleinfo r2.xy, rasterizer.x
  21: mad r0.yz, r0.yyzy, r2.xxyx, v2.xxyx
  22: add r0.yz, r0.yyzy, r1.xxyx
  23: ftod r2.xy, r0.y
  24: dmul r2.xy, r2.xyxy, cb0[1].xyxy
  25: dadd r2.xy, r2.xyxy, cb0[1].zwzw
  26: dfma r2.xy, r2.xyxy, cb0[1].zwzw, cb0[1].xyxy
  27: dmin r2.zw, r2.xyxy, cb0[1].xyxy
  28: dtof r0.w, r2.zwzw
  29: deq r2.z, r2.xyxy, cb0[1].zwzw
  30: ddiv r2.xy, r2.xyxy, cb0[1].zwzw
  31: dtof r2.x, r2.xyxy
  32: add r1.x, r0.y, r2.x
  33: and r0.y, r2.z, l(0x3f800000)
  34: add r0.y, r0.y, r0.w
  35: add r1.y, r0.y, r0.z
  36: ftou r2.xyzw, v0.xyyy
  37: store_uav_typed u2.xyzw, r2.xyzw, r1.xyzw
  38: ishl r0.y, cb0[2].x, l(2)
  39: atomic_umax u4, r0.y, r0.x
  40: store_raw u4.xyz, l(16), r1.xyzx
  41: add r0.xyzw, r1.xyzw, v3.xyzx
  42: add o0.xyzw, r0.xyzw, v4.xxxx
  43: mad o1.xyzw {min16f}, v5.xyxy {min16f}, cb0[0].xyxy {def32 as min16f}, l(1.500000, 1.500000, 1.500000, 1.500000) {def32 as min16f}
  44: add oDepthGE, v0.z, l(0.010000)
  45: and oMask, vCoverage.x, l(5)
  46: ret 

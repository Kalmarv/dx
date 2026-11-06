      ps_5_0
      dcl_globalFlags refactoringAllowed | enableDoublePrecisionFloatOps | skipOptimization | enableMinimumPrecision | enable11_1DoubleExtensions
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
//
// Initial variable locations:
//   v0.x <- p.pos.x; v0.y <- p.pos.y; v0.z <- p.pos.z; v0.w <- p.pos.w; 
//   v1.x <- p.a.x; v1.y <- p.a.y; v1.z <- p.a.z; v1.w <- p.a.w; 
//   v2.x <- p.s.x; v2.y <- p.s.y; 
//   v3.x <- p.nc.x; v3.y <- p.nc.y; v3.z <- p.nc.z; 
//   v4.x <- p.ns; 
//   v5.x <- p.h.x; v5.y <- p.h.y; 
//   v6.x <- p.index; 
//   vCoverage.x <- p.coverage; 
//   oMask <- <main return value>.mask; 
//   oDepthGE <- <main return value>.d; 
//   o1.x <- <main return value>.h.x; o1.y <- <main return value>.h.y; o1.z <- <main return value>.h.z; o1.w <- <main return value>.h.w; 
//   o0.x <- <main return value>.c.x; o0.y <- <main return value>.c.y; o0.z <- <main return value>.c.z; o0.w <- <main return value>.c.w; 
//   x0 <- arr
//
#line 28 "C:\dx-fixtures\ps_sm5.hlsl"
   0: mov r0.x, l(0)  // r0.x <- i
   1: itof r1.xyzw, r0.xxxx
   2: mul r1.xyzw, r1.xyzw, v1.xyzw
   3: mov x0[0].xyzw, r1.xyzw
   4: iadd r0.x, r0.x, l(1)
   5: itof r1.xyzw, r0.xxxx
   6: mul r1.xyzw, r1.xyzw, v1.xyzw
   7: mov x0[1].xyzw, r1.xyzw
   8: iadd r0.x, r0.x, l(1)
   9: itof r1.xyzw, r0.xxxx
  10: mul r1.xyzw, r1.xyzw, v1.xyzw
  11: mov x0[2].xyzw, r1.xyzw
  12: iadd r0.x, r0.x, l(1)
  13: itof r1.xyzw, r0.xxxx
  14: mul r1.xyzw, r1.xyzw, v1.xyzw
  15: mov x0[3].xyzw, r1.xyzw
  16: iadd r0.x, r0.x, l(1)
  17: itof r0.xyzw, r0.xxxx
  18: mul r0.xyzw, r0.xyzw, v1.xyzw
  19: mov x0[4].xyzw, r0.xyzw

#line 29
  20: mov r0.x, l(5)
  21: udiv null, r0.x, cb0[2].x, r0.x
  22: mov r0.xyzw, x0[r0.x + 0].xyzw  // r0.x <- c.x; r0.y <- c.y; r0.z <- c.z; r0.w <- c.w

#line 30
  23: eval_sample_index r1.xyzw, v1.xyzw, v6.x
  24: eval_centroid r2.xyzw, v1.xyzw
  25: add r1.xyzw, r1.xyzw, r2.xyzw
  26: eval_snapped r2.xyzw, v1.xyzw, l(1, -1, 0, 0)
  27: add r1.xyzw, r1.xyzw, r2.xyzw
  28: add r0.xyzw, r0.xyzw, r1.xyzw

#line 31
  29: mov r1.x, v6.x
  30: samplepos r1.xy, rasterizer.xyxx, r1.x
  31: sampleinfo_uint r1.z, rasterizer.x
  32: utof r1.zw, r1.zzzz
  33: mul r1.xy, r1.zwzz, r1.xyxx
  34: add r1.xy, r1.xyxx, v2.xyxx
  35: add r1.xy, r0.xyxx, r1.xyxx  // r1.x <- c.x; r1.y <- c.y

#line 32
  36: ftod r1.zw, r1.x
  37: dmul r1.zw, r1.zwzw, cb0[1].xyxy
  38: dadd r1.zw, r1.zwzw, cb0[1].zwzw
  39: dmov r1.zw, r1.zwzw  // r1.z <- d

#line 33
  40: dfma r1.zw, r1.zwzw, cb0[1].zwzw, cb0[1].xyxy
  41: dmov r1.zw, r1.zwzw  // r1.z <- d

#line 34
  42: ddiv r2.xy, r1.zwzw, cb0[1].zwzw
  43: dtof r2.x, r2.xyxy
  44: add r0.x, r1.x, r2.x  // r0.x <- c.x

#line 35
  45: dmin r2.xy, r1.zwzw, cb0[1].xyxy
  46: dtof r1.x, r2.xyxy
  47: deq r1.z, r1.zwzw, cb0[1].zwzw
  48: and r1.z, r1.z, l(0x3f800000)
  49: add r1.x, r1.z, r1.x
  50: add r0.y, r1.x, r1.y  // r0.y <- c.y

#line 36
  51: mov r1.xyzw {min16f}, cb0[0].xyxy {def32 as min16f}
  52: mul r1.xyzw {min16f}, r1.xyzw {min16f}, v5.xyxy {min16f}
  53: mov r3.x {min16f}, l(1.500000) {def32 as min16f}
  54: add r1.xyzw {min16f}, r1.xyzw {min16f}, r3.xxxx {min16f}  // r1.z <- h.x; r1.w <- h.y

#line 38
  55: mov r2.x, cb0[2].x
  56: mov r2.y, l(0)
  57: imm_atomic_iadd r2.x, u3, r2.xyxx, l(1)
  58: mov r2.x, r2.x  // r2.x <- old

#line 39
  59: ftou r3.xyzw, v0.xyyy
  60: store_uav_typed u2.xyzw, r3.xyzw, r0.xyzw

#line 40
  61: mov r2.y, l(4)
  62: imul null, r2.y, r2.y, cb0[2].x
  63: atomic_umax u4, r2.y, r2.x

#line 41
  64: store_raw u4.xyz, l(16), r0.xyzx

#line 42
  65: add r0.xyzw, r0.xyzw, v3.xyzx
  66: add r0.xyzw, r0.xyzw, v4.xxxx  // r0.x <- o.c.x; r0.y <- o.c.y; r0.z <- o.c.z; r0.w <- o.c.w

#line 43
  67: mov r1.xyzw {min16f}, r1.xyzw {min16f}  // r1.x <- o.h.x; r1.y <- o.h.y; r1.z <- o.h.z; r1.w <- o.h.w

#line 44
  68: add r2.x, v0.z, l(0.010000)  // r2.x <- o.d

#line 45
  69: mov r2.y, l(5)
  70: and r2.y, r2.y, vCoverage.x  // r2.y <- o.mask

#line 46
  71: mov o0.xyzw, r0.xyzw
  72: mov o1.xyzw {min16f}, r1.xyzw {min16f}
  73: mov oDepthGE, r2.x
  74: mov oMask, r2.y
  75: ret 

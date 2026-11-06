0x00000000: ps_5_0
0x00000008: dcl_globalFlags refactoringAllowed | enableDoublePrecisionFloatOps | forceEarlyDepthStencil | skipOptimization | enableMinimumPrecision | enable11_1DoubleExtensions
0x0000000C: dcl_constantbuffer CB0[3], immediateIndexed
0x0000001C: dcl_uav_typed_texture2d (float,float,float,float) u2
0x0000002C: dcl_uav_structured u3, 4
0x0000003C: dcl_uav_raw_glc u4
0x00000048: dcl_input_ps_siv linear noperspective v0.xyz, position
0x00000058: dcl_input_ps linear v1.xyzw
0x00000064: dcl_input_ps linear sample v2.xy
0x00000070: dcl_input_ps linear noperspective centroid v3.xyz
0x0000007C: dcl_input_ps linear noperspective sample v4.x
0x00000088: dcl_input_ps linear v5.xy {min16f}
0x00000098: dcl_input_ps_sgv constant v6.x, sampleIndex
0x000000A8: dcl_input vCoverage
0x000000B0: dcl_output o0.xyzw
0x000000BC: dcl_output o1.xyzw {min16f}
0x000000CC: dcl_output oMask
0x000000D4: dcl_output oDepthGE
0x000000DC: dcl_temps 4
0x000000E4: dcl_indexableTemp x0[5], 4
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
#line 32 "C:\dx-fixtures\ps_sm5.hlsl"
0x000000F4: mov r0.x, l(0)  // r0.x <- i
0x00000108: itof r1.xyzw, r0.xxxx
0x0000011C: mul r1.xyzw, r1.xyzw, v1.xyzw
0x00000138: mov x0[0].xyzw, r1.xyzw
0x00000150: iadd r0.x, r0.x, l(1)
0x0000016C: itof r1.xyzw, r0.xxxx
0x00000180: mul r1.xyzw, r1.xyzw, v1.xyzw
0x0000019C: mov x0[1].xyzw, r1.xyzw
0x000001B4: iadd r0.x, r0.x, l(1)
0x000001D0: itof r1.xyzw, r0.xxxx
0x000001E4: mul r1.xyzw, r1.xyzw, v1.xyzw
0x00000200: mov x0[2].xyzw, r1.xyzw
0x00000218: iadd r0.x, r0.x, l(1)
0x00000234: itof r1.xyzw, r0.xxxx
0x00000248: mul r1.xyzw, r1.xyzw, v1.xyzw
0x00000264: mov x0[3].xyzw, r1.xyzw
0x0000027C: iadd r0.x, r0.x, l(1)
0x00000298: itof r0.xyzw, r0.xxxx
0x000002AC: mul r0.xyzw, r0.xyzw, v1.xyzw
0x000002C8: mov x0[4].xyzw, r0.xyzw

#line 33
0x000002E0: mov r0.x, l(5)
0x000002F4: udiv null, r0.x, cb0[2].x, r0.x
0x00000318: mov r0.xyzw, x0[r0.x + 0].xyzw  // r0.x <- c.x; r0.y <- c.y; r0.z <- c.z; r0.w <- c.w

#line 34
0x00000334: eval_sample_index r1.xyzw, v1.xyzw, v6.x
0x00000350: eval_centroid r2.xyzw, v1.xyzw
0x00000364: add r1.xyzw, r1.xyzw, r2.xyzw
0x00000380: eval_snapped r2.xyzw, v1.xyzw, l(1, -1, 0, 0)
0x000003A8: add r1.xyzw, r1.xyzw, r2.xyzw
0x000003C4: add r0.xyzw, r0.xyzw, r1.xyzw

#line 35
0x000003E0: mov r1.x, v6.x
0x000003F4: samplepos r1.xy, rasterizer.xyxx, r1.x
0x0000040C: sampleinfo_uint r1.z, rasterizer.x
0x0000041C: utof r1.zw, r1.zzzz
0x00000430: mul r1.xy, r1.zwzz, r1.xyxx
0x0000044C: add r1.xy, r1.xyxx, v2.xyxx
0x00000468: add r1.xy, r0.xyxx, r1.xyxx  // r1.x <- c.x; r1.y <- c.y

#line 36
0x00000484: ftod r1.zw, r1.x
0x00000498: dmul r1.zw, r1.zwzw, cb0[1].xyxy
0x000004B8: dadd r1.zw, r1.zwzw, cb0[1].zwzw
0x000004D8: dmov r1.zw, r1.zwzw  // r1.z <- d

#line 37
0x000004EC: dfma r1.zw, r1.zwzw, cb0[1].zwzw, cb0[1].xyxy
0x00000518: dmov r1.zw, r1.zwzw  // r1.z <- d

#line 38
0x0000052C: ddiv r2.xy, r1.zwzw, cb0[1].zwzw
0x0000054C: dtof r2.x, r2.xyxy
0x00000560: add r0.x, r1.x, r2.x  // r0.x <- c.x

#line 39
0x0000057C: dmin r2.xy, r1.zwzw, cb0[1].xyxy
0x0000059C: dtof r1.x, r2.xyxy
0x000005B0: deq r1.z, r1.zwzw, cb0[1].zwzw
0x000005D0: and r1.z, r1.z, l(0x3f800000)
0x000005EC: add r1.x, r1.z, r1.x
0x00000608: add r0.y, r1.x, r1.y  // r0.y <- c.y

#line 40
0x00000624: mov r1.xyzw {min16f}, cb0[0].xyxy {def32 as min16f}
0x00000640: mul r1.xyzw {min16f}, r1.xyzw {min16f}, v5.xyxy {min16f}
0x00000668: mov r3.x {min16f}, l(1.500000) {def32 as min16f}
0x00000680: add r1.xyzw {min16f}, r1.xyzw {min16f}, r3.xxxx {min16f}  // r1.z <- h.x; r1.w <- h.y

#line 42
0x000006A8: mov r2.x, cb0[2].x
0x000006C0: mov r2.y, l(0)
0x000006D4: imm_atomic_iadd r2.x, u3, r2.xyxx, l(1)
0x000006F8: mov r2.x, r2.x  // r2.x <- old

#line 43
0x0000070C: ftou r3.xyzw, v0.xyyy
0x00000720: store_uav_typed u2.xyzw, r3.xyzw, r0.xyzw

#line 44
0x0000073C: mov r2.y, l(4)
0x00000750: imul null, r2.y, r2.y, cb0[2].x
0x00000774: atomic_umax u4, r2.y, r2.x

#line 45
0x00000790: store_raw u4.xyz, l(16), r0.xyzx

#line 46
0x000007AC: add r0.xyzw, r0.xyzw, v3.xyzx
0x000007C8: add r0.xyzw, r0.xyzw, v4.xxxx  // r0.x <- o.c.x; r0.y <- o.c.y; r0.z <- o.c.z; r0.w <- o.c.w

#line 47
0x000007E4: mov r1.xyzw {min16f}, r1.xyzw {min16f}  // r1.x <- o.h.x; r1.y <- o.h.y; r1.z <- o.h.z; r1.w <- o.h.w

#line 48
0x00000800: add r2.x, v0.z, l(0.010000)  // r2.x <- o.d

#line 49
0x0000081C: mov r2.y, l(5)
0x00000830: and r2.y, r2.y, vCoverage.x  // r2.y <- o.mask

#line 50
0x00000848: mov o0.xyzw, r0.xyzw
0x0000085C: mov o1.xyzw {min16f}, r1.xyzw {min16f}
0x00000878: mov oDepthGE, r2.x
0x00000888: mov oMask, r2.y
0x00000898: ret 

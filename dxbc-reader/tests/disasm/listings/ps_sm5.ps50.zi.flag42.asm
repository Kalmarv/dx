ps_5_0
dcl_globalFlags refactoringAllowed | enableDoublePrecisionFloatOps | enableMinimumPrecision | enable11_1DoubleExtensions
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
#line 32 "C:\dx-fixtures\ps_sm5.hlsl"
mov x0[0].xyzw, l(0,0,0,0)
mov x0[1].xyzw, v1.xyzw
add r0.xyzw, v1.xyzw, v1.xyzw
mov x0[2].xyzw, r0.xyzw
mul r0.xyzw, v1.xyzw, l(3.000000, 3.000000, 3.000000, 3.000000)
mov x0[3].xyzw, r0.xyzw
mul r0.xyzw, v1.xyzw, l(4.000000, 4.000000, 4.000000, 4.000000)
mov x0[4].xyzw, r0.xyzw

#line 42
mov r0.x, cb0[2].x
mov r0.y, l(0)
imm_atomic_iadd r0.x, u3, r0.xyxx, l(1)  // r0.x <- old

#line 33
udiv null, r0.y, cb0[2].x, l(5)
mov r1.xyzw, x0[r0.y + 0].xyzw  // r1.x <- c.x; r1.y <- c.y; r1.z <- c.z; r1.w <- c.w

#line 34
eval_sample_index r2.xyzw, v1.xyzw, v6.x
eval_centroid r3.xyzw, v1.xyzw
add r2.xyzw, r2.xyzw, r3.xyzw
eval_snapped r3.xyzw, v1.xyzw, l(1, -1, 0, 0)
add r2.xyzw, r2.xyzw, r3.xyzw
add r1.xyzw, r1.xyzw, r2.xyzw

#line 35
samplepos r0.yz, rasterizer.xxyx, v6.x
sampleinfo r2.xy, rasterizer.x
mad r0.yz, r0.yyzy, r2.xxyx, v2.xxyx
add r0.yz, r0.yyzy, r1.xxyx  // r0.y <- c.x; r0.z <- c.y

#line 36
ftod r2.xy, r0.y
dmul r2.xy, r2.xyxy, cb0[1].xyxy
dadd r2.xy, r2.xyxy, cb0[1].zwzw  // r2.x <- d

#line 37
dfma r2.xy, r2.xyxy, cb0[1].zwzw, cb0[1].xyxy

#line 39
dmin r2.zw, r2.xyxy, cb0[1].xyxy
dtof r0.w, r2.zwzw
deq r2.z, r2.xyxy, cb0[1].zwzw

#line 38
ddiv r2.xy, r2.xyxy, cb0[1].zwzw
dtof r2.x, r2.xyxy
add r1.x, r0.y, r2.x  // r1.x <- c.x

#line 39
and r0.y, r2.z, l(0x3f800000)
add r0.y, r0.y, r0.w
add r1.y, r0.y, r0.z  // r1.y <- c.y

#line 43
ftou r2.xyzw, v0.xyyy
store_uav_typed u2.xyzw, r2.xyzw, r1.xyzw

#line 44
ishl r0.y, cb0[2].x, l(2)
atomic_umax u4, r0.y, r0.x

#line 45
store_raw u4.xyz, l(16), r1.xyzx

#line 46
add r0.xyzw, r1.xyzw, v3.xyzx
add o0.xyzw, r0.xyzw, v4.xxxx

#line 40
mad o1.xyzw {min16f}, v5.xyxy {min16f}, cb0[0].xyxy {def32 as min16f}, l(1.500000, 1.500000, 1.500000, 1.500000) {def32 as min16f}

#line 48
add oDepthGE, v0.z, l(0.010000)

#line 49
and oMask, vCoverage.x, l(5)

#line 50
ret 

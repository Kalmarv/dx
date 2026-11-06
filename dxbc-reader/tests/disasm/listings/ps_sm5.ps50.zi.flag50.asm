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
mov x0[0].xyzw, l(0,0,0,0)
mov x0[1].xyzw, v1.xyzw
add r0.xyzw, v1.xyzw, v1.xyzw
mov x0[2].xyzw, r0.xyzw
mul r0.xyzw, v1.xyzw, l(3.000000, 3.000000, 3.000000, 3.000000)
mov x0[3].xyzw, r0.xyzw
mul r0.xyzw, v1.xyzw, l(4.000000, 4.000000, 4.000000, 4.000000)
mov x0[4].xyzw, r0.xyzw
mov r0.x, cb0[2].x
mov r0.y, l(0)
imm_atomic_iadd r0.x, u3, r0.xyxx, l(1)
udiv null, r0.y, cb0[2].x, l(5)
mov r1.xyzw, x0[r0.y + 0].xyzw
eval_sample_index r2.xyzw, v1.xyzw, v6.x
eval_centroid r3.xyzw, v1.xyzw
add r2.xyzw, r2.xyzw, r3.xyzw
eval_snapped r3.xyzw, v1.xyzw, l(1, -1, 0, 0)
add r2.xyzw, r2.xyzw, r3.xyzw
add r1.xyzw, r1.xyzw, r2.xyzw
samplepos r0.yz, rasterizer.xxyx, v6.x
sampleinfo r2.xy, rasterizer.x
mad r0.yz, r0.yyzy, r2.xxyx, v2.xxyx
add r0.yz, r0.yyzy, r1.xxyx
ftod r2.xy, r0.y
dmul r2.xy, r2.xyxy, cb0[1].xyxy
dadd r2.xy, r2.xyxy, cb0[1].zwzw
dfma r2.xy, r2.xyxy, cb0[1].zwzw, cb0[1].xyxy
dmin r2.zw, r2.xyxy, cb0[1].xyxy
dtof r0.w, r2.zwzw
deq r2.z, r2.xyxy, cb0[1].zwzw
ddiv r2.xy, r2.xyxy, cb0[1].zwzw
dtof r2.x, r2.xyxy
add r1.x, r0.y, r2.x
and r0.y, r2.z, l(0x3f800000)
add r0.y, r0.y, r0.w
add r1.y, r0.y, r0.z
ftou r2.xyzw, v0.xyyy
store_uav_typed u2.xyzw, r2.xyzw, r1.xyzw
ishl r0.y, cb0[2].x, l(2)
atomic_umax u4, r0.y, r0.x
store_raw u4.xyz, l(16), r1.xyzx
add r0.xyzw, r1.xyzw, v3.xyzx
add o0.xyzw, r0.xyzw, v4.xxxx
mad o1.xyzw {min16f}, v5.xyxy {min16f}, cb0[0].xyxy {def32 as min16f}, l(1.500000, 1.500000, 1.500000, 1.500000) {def32 as min16f}
add oDepthGE, v0.z, l(0.010000)
and oMask, vCoverage.x, l(5)
ret 

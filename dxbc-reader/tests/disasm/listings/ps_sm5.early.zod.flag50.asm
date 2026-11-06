ps_5_0
dcl_globalFlags refactoringAllowed | enableDoublePrecisionFloatOps | forceEarlyDepthStencil | skipOptimization | enableMinimumPrecision | enable11_1DoubleExtensions
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
mov r0.x, l(0)
itof r1.xyzw, r0.xxxx
mul r1.xyzw, r1.xyzw, v1.xyzw
mov x0[0].xyzw, r1.xyzw
iadd r0.x, r0.x, l(1)
itof r1.xyzw, r0.xxxx
mul r1.xyzw, r1.xyzw, v1.xyzw
mov x0[1].xyzw, r1.xyzw
iadd r0.x, r0.x, l(1)
itof r1.xyzw, r0.xxxx
mul r1.xyzw, r1.xyzw, v1.xyzw
mov x0[2].xyzw, r1.xyzw
iadd r0.x, r0.x, l(1)
itof r1.xyzw, r0.xxxx
mul r1.xyzw, r1.xyzw, v1.xyzw
mov x0[3].xyzw, r1.xyzw
iadd r0.x, r0.x, l(1)
itof r0.xyzw, r0.xxxx
mul r0.xyzw, r0.xyzw, v1.xyzw
mov x0[4].xyzw, r0.xyzw
mov r0.x, l(5)
udiv null, r0.x, cb0[2].x, r0.x
mov r0.xyzw, x0[r0.x + 0].xyzw
eval_sample_index r1.xyzw, v1.xyzw, v6.x
eval_centroid r2.xyzw, v1.xyzw
add r1.xyzw, r1.xyzw, r2.xyzw
eval_snapped r2.xyzw, v1.xyzw, l(1, -1, 0, 0)
add r1.xyzw, r1.xyzw, r2.xyzw
add r0.xyzw, r0.xyzw, r1.xyzw
mov r1.x, v6.x
samplepos r1.xy, rasterizer.xyxx, r1.x
sampleinfo_uint r1.z, rasterizer.x
utof r1.zw, r1.zzzz
mul r1.xy, r1.zwzz, r1.xyxx
add r1.xy, r1.xyxx, v2.xyxx
add r1.xy, r0.xyxx, r1.xyxx
ftod r1.zw, r1.x
dmul r1.zw, r1.zwzw, cb0[1].xyxy
dadd r1.zw, r1.zwzw, cb0[1].zwzw
dmov r1.zw, r1.zwzw
dfma r1.zw, r1.zwzw, cb0[1].zwzw, cb0[1].xyxy
dmov r1.zw, r1.zwzw
ddiv r2.xy, r1.zwzw, cb0[1].zwzw
dtof r2.x, r2.xyxy
add r0.x, r1.x, r2.x
dmin r2.xy, r1.zwzw, cb0[1].xyxy
dtof r1.x, r2.xyxy
deq r1.z, r1.zwzw, cb0[1].zwzw
and r1.z, r1.z, l(0x3f800000)
add r1.x, r1.z, r1.x
add r0.y, r1.x, r1.y
mov r1.xyzw {min16f}, cb0[0].xyxy {def32 as min16f}
mul r1.xyzw {min16f}, r1.xyzw {min16f}, v5.xyxy {min16f}
mov r3.x {min16f}, l(1.500000) {def32 as min16f}
add r1.xyzw {min16f}, r1.xyzw {min16f}, r3.xxxx {min16f}
mov r2.x, cb0[2].x
mov r2.y, l(0)
imm_atomic_iadd r2.x, u3, r2.xyxx, l(1)
mov r2.x, r2.x
ftou r3.xyzw, v0.xyyy
store_uav_typed u2.xyzw, r3.xyzw, r0.xyzw
mov r2.y, l(4)
imul null, r2.y, r2.y, cb0[2].x
atomic_umax u4, r2.y, r2.x
store_raw u4.xyz, l(16), r0.xyzx
add r0.xyzw, r0.xyzw, v3.xyzx
add r0.xyzw, r0.xyzw, v4.xxxx
mov r1.xyzw {min16f}, r1.xyzw {min16f}
add r2.x, v0.z, l(0.010000)
mov r2.y, l(5)
and r2.y, r2.y, vCoverage.x
mov o0.xyzw, r0.xyzw
mov o1.xyzw {min16f}, r1.xyzw {min16f}
mov oDepthGE, r2.x
mov oMask, r2.y
ret 

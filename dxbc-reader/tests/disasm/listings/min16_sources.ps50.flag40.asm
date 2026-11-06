ps_5_0
dcl_globalFlags refactoringAllowed | enableMinimumPrecision
dcl_constantbuffer CB0[3], immediateIndexed
dcl_sampler s0, mode_default
dcl_resource_texture2d (float,float,float,float) t0
dcl_input_ps linear v0.xyzw
dcl_input_ps constant v1.yzw
dcl_input_ps constant v2.xyzw {min16u}
dcl_output o0.xyzw {min16f}
dcl_temps 4
firstbit_shi r0.x, v2.x {min16u as def32}
ieq r0.y, r0.x, l(-1)
iadd r0.x, -r0.x, l(31)
movc r0.x, r0.y, l(-1), r0.x
ushr r1.x {min16u}, v2.x {min16u}, v1.y
ishl r1.y {min16u}, v2.x {min16u}, v2.y {min16u}
iadd r1.x {min16u}, r1.y {min16u}, r1.x {min16u}
countbits r0.y, r1.x {min16u as def32}
imul null, r1.x {min16u}, r1.x {min16u as def32}, v2.x {min16u as def32}
udiv r1.x {min16u}, null, r1.x {min16u}, v1.z {def32 as min16u}
utof r2.x {min16f}, r1.x {min16u}
bfrev r0.z, v2.x {min16u as def32}
iadd r0.y, r0.y, r0.z
iadd r0.x, r0.x, r0.y
utof r2.y {min16f}, r0.x
sample_indexable(texture2d)(float,float,float,float) r0.xyzw {min16f}, v0.xyxx, t0.xyzw, s0
gather4_indexable(texture2d)(float,float,float,float) r1.xyzw {min16f}, v0.zwzz, t0.xyzw, s0.x
mad r0.xyzw {min16f}, r0.xyzw {min16f}, r1.xyzw {min16f}, r2.yyyy {min16f}
add r0.xyzw {min16f}, r2.xxxx {min16f}, r0.xyzw {min16f}
f16tof32 r3.x, v1.w
add r0.xyzw {min16f}, r0.xyzw {min16f}, r3.xxxx {def32 as min16f}
f32tof16 r3.x, v0.x
iadd r3.x, r3.x, v2.z {min16u as def32}
ubfe r3.x, l(5), l(3), r3.x
imad r3.x, v2.w {min16u as def32}, cb0[2].y, r3.x
utof r2.x {min16f}, r3.x
add r0.x {min16f}, r0.x {min16f}, r2.x {min16f}
dp3 o0.y {min16f}, r0.xyzx {min16f}, v0.xyzx {def32 as min16f}
mov o0.x {min16f}, r0.x {min16f}
sqrt r2.x {min16f}, |r0.z {min16f}|
max r2.y {min16f}, r0.w {min16f}, cb0[0].x {def32 as min16f}
min o0.w {min16f}, r2.y {min16f}, cb0[0].y {def32 as min16f}
rcp r2.y {min16f}, cb0[0].w {def32 as min16f}
add o0.z {min16f}, r2.y {min16f}, r2.x {min16f}
ret 

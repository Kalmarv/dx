ps_5_0
dcl_globalFlags refactoringAllowed | enableMinimumPrecision
dcl_sampler s0, mode_default
dcl_sampler s1, mode_comparison
dcl_resource_structured t0, 4
dcl_resource_raw t1
dcl_resource_texture2d (float,float,float,float) t2
dcl_resource_texture2d (float,float,float,float) t3
dcl_uav_raw u1
dcl_input_ps linear v0.xy {min16f}
dcl_input_ps linear v0.z {min16f}
dcl_input_ps constant v1.x {min16u}
dcl_output o0.xyzw {min16f}
dcl_temps 5
mov r0.x, v1.x {min16u as def32}
ishl r1.x {min16u}, v1.x {min16u}, l(0x00000002)
imm_atomic_iadd r0.x, u1, r1.x {min16u}, r0.x
ld_raw_indexable(raw_buffer)(mixed,mixed,mixed,mixed) r0.y, r1.x {min16u}, t1.xxxx
utof r2.x {min16f}, r0.y
utof r0.x, r0.x
ld_structured_indexable(structured_buffer, stride=4)(mixed,mixed,mixed,mixed) r1.x {min16u}, v1.x {min16u}, l(0x00000000), t0.xxxx
utof r2.y {min16f}, r1.x {min16u}
lod r2.z {min16f}, v0.xyxx {min16f}, t2.x, s0
sample_indexable(texture2d)(float,float,float,float) r1.xyzw {min16f}, v0.xyxx {min16f}, t2.xyzw, s0
mad r1.xyzw {min16f}, r1.xyzw {min16f}, r2.zzzz {min16f}, r2.yyyy {min16f}
ld_structured_indexable(structured_buffer, stride=4)(mixed,mixed,mixed,mixed) r3.x {min16u}, l(0x00000003), l(0x00000000), t0.xxxx
utof r2.y {min16f}, r3.x {min16u}
add r1.xyzw {min16f}, r1.xyzw {min16f}, r2.yyyy {min16f}
add r1.xyzw {min16f}, r2.xxxx {min16f}, r1.xyzw {min16f}
lod r0.y, v0.xyxx {min16f}, t3.x, s0
sample_c_indexable(texture2d)(float,float,float,float) r2.x {min16f}, v0.xyxx {min16f}, t3.xxxx, s1, v0.z {min16f}
add r0.y, r0.y, r2.x {min16f as def32}
sample_c_lz_indexable(texture2d)(float,float,float,float) r2.x {min16f}, v0.xyxx {min16f}, t3.xxxx, s1, v0.z {min16f}
add r0.y, r0.y, r2.x {min16f as def32}
gather4_c_indexable(texture2d)(float,float,float,float) r2.xyzw {min16f}, v0.xyxx {min16f}, t3.xyzw, s1.x, v0.z {min16f}
add r2.xyzw, r0.yyyy, r2.xyzw {min16f as def32}
mov r3.xz {min16u}, v1.xxxx {min16u}
mov r3.yw {min16u}, l(0x00000000,0x00000001,0x00000000,0x00000002) {def32 as min16u}
gather4_po_c_indexable(texture2d)(float,float,float,float) r4.xyzw {min16f}, v0.xyxx {min16f}, r3.xyxx {min16u}, t3.xyzw, s1.x, v0.z {min16f}
gather4_po_indexable(texture2d)(float,float,float,float) r3.xyzw, v0.xyxx {min16f}, r3.zwzz {min16u}, t3.xyzw, s0.x
add r2.xyzw, r2.xyzw, r4.xyzw {min16f as def32}
add r2.xyzw, r3.xyzw, r2.xyzw
add r0.xyzw, r0.xxxx, r2.xyzw
add o0.xyzw {min16f}, r0.xyzw {def32 as min16f}, r1.xyzw {min16f}
ret 

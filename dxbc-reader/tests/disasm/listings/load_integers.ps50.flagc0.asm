ps_5_0
dcl_globalFlags refactoringAllowed
dcl_resource_raw t0
dcl_resource_structured t1, 16
dcl_resource_texture2d (float,float,float,float) t2
dcl_resource_texture2dms(4) (float,float,float,float) t3
dcl_uav_raw u1
dcl_uav_structured u2, 16
dcl_input_ps linear v1.xyzw
dcl_output o0.xyzw
dcl_temps 4
ld_raw_indexable(raw_buffer)(mixed,mixed,mixed,mixed) r0.x, l(0x3f800000), t0.xxxx
ld_structured_indexable(structured_buffer, stride=16)(mixed,mixed,mixed,mixed) r1.xyzw, l(0x3f800000), l(0x00000000), t1.xyzw
add r0.xyzw, r0.xxxx, r1.xyzw
ld_raw_indexable(raw_buffer)(mixed,mixed,mixed,mixed) r1.x, l(0x40000000), t0.xxxx
ld_structured_s_indexable(structured_buffer, stride=16)(mixed,mixed,mixed,mixed) r2.xyzw, r3.x, l(0x40400000), l(0x00000000), t1.xyzw
add r1.xyzw, r1.xxxx, r2.xyzw
check_access_fully_mapped r2.x, r3.x
movc r2.w, r2.x, l(0x3f800000), l(0x00000000)
add r0.xyzw, r0.xyzw, r1.xyzw
ld_raw_indexable(raw_buffer)(mixed,mixed,mixed,mixed) r1.x, l(0x3f800000), u1.xxxx
ld_structured_indexable(structured_buffer, stride=16)(mixed,mixed,mixed,mixed) r3.xyzw, l(0x3f800000), l(0x00000000), u2.xyzw
add r1.xyzw, r1.xxxx, r3.xyzw
add r0.xyzw, r0.xyzw, r1.xyzw
resinfo_indexable(texture2d)(float,float,float,float)_uint r1.xyz, l(0x3f800000), t2.xywz
utof r2.xyz, r1.xyzx
add r0.xyzw, r2.xyzw, r0.xyzw
samplepos r1.xy, t3.xyxx, l(0x3f800000)
add r0.xy, r0.xyxx, r1.xyxx
eval_sample_index r1.xyzw, v1.xyzw, l(0x3f800000)
add o0.xyzw, r0.xyzw, r1.xyzw
ret 

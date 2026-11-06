vs_5_0
dcl_globalFlags refactoringAllowed
dcl_constantbuffer CB2[5], immediateIndexed
dcl_constantbuffer CB0[6], immediateIndexed
dcl_constantbuffer CB1[3], immediateIndexed
dcl_resource_structured t0, 36
dcl_input v0.xyzw
dcl_input v1.xyz
dcl_output o0.xyz
dcl_output_siv o1.xyzw, position
dcl_output o2.xy
dcl_output_siv o3.xyz, clip_distance
dcl_temps 3
mov o0.xyz, v1.xyzx
mul r0.xyzw, v0.xyzw, cb0[0].xxxx
mul r0.xyzw, r0.xyzw, cb0[3].wwww
mul r0.xyzw, r0.xyzw, cb0[4].xxxx
mul r0.xyzw, r0.xyzw, cb0[5].xyzw
ld_structured_indexable(structured_buffer, stride=36)(mixed,mixed,mixed,mixed) r1.x, l(0x00000000), l(0x00000010), t0.xxxx
mul r0.xyzw, r0.xyzw, r1.xxxx
dp4 r1.x, v0.xyzw, cb2[0].xyzw
dp4 r1.y, v0.xyzw, cb2[1].xyzw
dp4 r1.z, v0.xyzw, cb2[2].xyzw
mov r1.w, cb2[3].x
mul r1.xyzw, r1.xyzw, cb2[4].yyyy
ld_structured_indexable(structured_buffer, stride=36)(mixed,mixed,mixed,mixed) r2.x, l(0x00000001), l(0x00000020), t0.xxxx
itof r2.x, r2.x
mad r0.xyzw, r0.xyzw, r2.xxxx, r1.xyzw
mov o1.xyzw, r0.xyzw
mov o2.xy, cb2[3].xyxx
dp4 o3.x, r0.xyzw, cb1[0].xyzw
dp4 o3.y, r0.xyzw, cb1[1].xyzw
dp4 o3.z, r0.xyzw, cb1[2].xyzw
ret 

0x00000000: vs_5_0
0x00000008: dcl_globalFlags refactoringAllowed
0x0000000C: dcl_constantbuffer CB2[5], immediateIndexed
0x0000001C: dcl_constantbuffer CB0[6], immediateIndexed
0x0000002C: dcl_constantbuffer CB1[3], immediateIndexed
0x0000003C: dcl_resource_structured t0, 36
0x0000004C: dcl_input v0.xyzw
0x00000058: dcl_input v1.xyz
0x00000064: dcl_output o0.xyz
0x00000070: dcl_output_siv o1.xyzw, position
0x00000080: dcl_output o2.xy
0x0000008C: dcl_output_siv o3.xyz, clip_distance
0x0000009C: dcl_temps 3
0x000000A4: mov o0.xyz, v1.xyzx
0x000000B8: mul r0.xyzw, v0.xyzw, cb0[0].xxxx
0x000000D8: mul r0.xyzw, r0.xyzw, cb0[3].wwww
0x000000F8: mul r0.xyzw, r0.xyzw, cb0[4].xxxx
0x00000118: mul r0.xyzw, r0.xyzw, cb0[5].xyzw
0x00000138: ld_structured_indexable(structured_buffer, stride=36)(mixed,mixed,mixed,mixed) r1.x, l(0), l(16), t0.xxxx
0x00000164: mul r0.xyzw, r0.xyzw, r1.xxxx
0x00000180: dp4 r1.x, v0.xyzw, cb2[0].xyzw
0x000001A0: dp4 r1.y, v0.xyzw, cb2[1].xyzw
0x000001C0: dp4 r1.z, v0.xyzw, cb2[2].xyzw
0x000001E0: mov r1.w, cb2[3].x
0x000001F8: mul r1.xyzw, r1.xyzw, cb2[4].yyyy
0x00000218: ld_structured_indexable(structured_buffer, stride=36)(mixed,mixed,mixed,mixed) r2.x, l(1), l(32), t0.xxxx
0x00000244: itof r2.x, r2.x
0x00000258: mad r0.xyzw, r0.xyzw, r2.xxxx, r1.xyzw
0x0000027C: mov o1.xyzw, r0.xyzw
0x00000290: mov o2.xy, cb2[3].xyxx
0x000002A8: dp4 o3.x, r0.xyzw, cb1[0].xyzw
0x000002C8: dp4 o3.y, r0.xyzw, cb1[1].xyzw
0x000002E8: dp4 o3.z, r0.xyzw, cb1[2].xyzw
0x00000308: ret 

0x00000000: ps_5_0
0x00000008: dcl_globalFlags refactoringAllowed
0x0000000C: dcl_constantbuffer CB0[1], immediateIndexed
0x0000001C: dcl_resource_structured t3, 96
0x0000002C: dcl_resource_structured t4, 4
0x0000003C: dcl_resource_structured t5, 12
0x0000004C: dcl_output o0.xyzw
0x00000058: dcl_temps 1
0x00000060: ld_structured_indexable(structured_buffer, stride=4)(mixed,mixed,mixed,mixed) r0.x, cb0[0].x, l(0), t4.xxxx
0x00000090: ld_structured_indexable(structured_buffer, stride=96)(mixed,mixed,mixed,mixed) r0.y, r0.x, l(0), t3.xxxx
0x000000BC: ld_structured_indexable(structured_buffer, stride=96)(mixed,mixed,mixed,mixed) r0.z, r0.x, l(12), t3.xxxx
0x000000E8: add o0.x, r0.z, r0.y
0x00000104: ld_structured_indexable(structured_buffer, stride=12)(mixed,mixed,mixed,mixed) r0.y, cb0[0].x, l(8), t5.xxxx
0x00000134: utof r0.y, r0.y
0x00000148: ld_structured_indexable(structured_buffer, stride=96)(mixed,mixed,mixed,mixed) r0.z, r0.x, l(92), t3.xxxx
0x00000174: add o0.w, r0.y, r0.z
0x00000190: ld_structured_indexable(structured_buffer, stride=96)(mixed,mixed,mixed,mixed) o0.y, r0.x, l(36), t3.xxxx
0x000001BC: ld_structured_indexable(structured_buffer, stride=96)(mixed,mixed,mixed,mixed) o0.z, r0.x, l(60), t3.xxxx
0x000001E8: ret 

ps_5_0
dcl_globalFlags refactoringAllowed
dcl_constantbuffer CB0[1], immediateIndexed
dcl_resource_structured t3, 96
dcl_resource_structured t4, 4
dcl_resource_structured t5, 12
dcl_output o0.xyzw
dcl_temps 1
ld_structured_indexable(structured_buffer, stride=4)(mixed,mixed,mixed,mixed) r0.x, cb0[0].x, l(0x00000000), t4.xxxx
ld_structured_indexable(structured_buffer, stride=96)(mixed,mixed,mixed,mixed) r0.y, r0.x, l(0x00000000), t3.xxxx
ld_structured_indexable(structured_buffer, stride=96)(mixed,mixed,mixed,mixed) r0.z, r0.x, l(0x0000000c), t3.xxxx
add o0.x, r0.z, r0.y
ld_structured_indexable(structured_buffer, stride=12)(mixed,mixed,mixed,mixed) r0.y, cb0[0].x, l(0x00000008), t5.xxxx
utof r0.y, r0.y
ld_structured_indexable(structured_buffer, stride=96)(mixed,mixed,mixed,mixed) r0.z, r0.x, l(0x0000005c), t3.xxxx
add o0.w, r0.y, r0.z
ld_structured_indexable(structured_buffer, stride=96)(mixed,mixed,mixed,mixed) o0.y, r0.x, l(0x00000024), t3.xxxx
ld_structured_indexable(structured_buffer, stride=96)(mixed,mixed,mixed,mixed) o0.z, r0.x, l(0x0000003c), t3.xxxx
ret 

      0x00000000: ps_5_0
      0x00000008: dcl_globalFlags refactoringAllowed
      0x0000000C: dcl_constantbuffer CB0[1], immediateIndexed
      0x0000001C: dcl_resource_structured t3, 96
      0x0000002C: dcl_resource_structured t4, 4
      0x0000003C: dcl_resource_structured t5, 12
      0x0000004C: dcl_output o0.xyzw
      0x00000058: dcl_temps 1
   0  0x00000060: ld_structured_indexable(structured_buffer, stride=4)(mixed,mixed,mixed,mixed) r0.x, cb0[0].x, l(0x00000000), t4.xxxx
   1  0x00000090: ld_structured_indexable(structured_buffer, stride=96)(mixed,mixed,mixed,mixed) r0.y, r0.x, l(0x00000000), t3.xxxx
   2  0x000000BC: ld_structured_indexable(structured_buffer, stride=96)(mixed,mixed,mixed,mixed) r0.z, r0.x, l(0x0000000c), t3.xxxx
   3  0x000000E8: add o0.x, r0.z, r0.y
   4  0x00000104: ld_structured_indexable(structured_buffer, stride=12)(mixed,mixed,mixed,mixed) r0.y, cb0[0].x, l(0x00000008), t5.xxxx
   5  0x00000134: utof r0.y, r0.y
   6  0x00000148: ld_structured_indexable(structured_buffer, stride=96)(mixed,mixed,mixed,mixed) r0.z, r0.x, l(0x0000005c), t3.xxxx
   7  0x00000174: add o0.w, r0.y, r0.z
   8  0x00000190: ld_structured_indexable(structured_buffer, stride=96)(mixed,mixed,mixed,mixed) o0.y, r0.x, l(0x00000024), t3.xxxx
   9  0x000001BC: ld_structured_indexable(structured_buffer, stride=96)(mixed,mixed,mixed,mixed) o0.z, r0.x, l(0x0000003c), t3.xxxx
  10  0x000001E8: ret 

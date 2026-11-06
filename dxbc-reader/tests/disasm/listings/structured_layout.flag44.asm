      ps_5_0
      dcl_globalFlags refactoringAllowed
      dcl_constantbuffer CB0[1], immediateIndexed
      dcl_resource_structured t3, 96
      dcl_resource_structured t4, 4
      dcl_resource_structured t5, 12
      dcl_output o0.xyzw
      dcl_temps 1
   0: ld_structured_indexable(structured_buffer, stride=4)(mixed,mixed,mixed,mixed) r0.x, cb0[0].x, l(0), t4.xxxx
   1: ld_structured_indexable(structured_buffer, stride=96)(mixed,mixed,mixed,mixed) r0.y, r0.x, l(0), t3.xxxx
   2: ld_structured_indexable(structured_buffer, stride=96)(mixed,mixed,mixed,mixed) r0.z, r0.x, l(12), t3.xxxx
   3: add o0.x, r0.z, r0.y
   4: ld_structured_indexable(structured_buffer, stride=12)(mixed,mixed,mixed,mixed) r0.y, cb0[0].x, l(8), t5.xxxx
   5: utof r0.y, r0.y
   6: ld_structured_indexable(structured_buffer, stride=96)(mixed,mixed,mixed,mixed) r0.z, r0.x, l(92), t3.xxxx
   7: add o0.w, r0.y, r0.z
   8: ld_structured_indexable(structured_buffer, stride=96)(mixed,mixed,mixed,mixed) o0.y, r0.x, l(36), t3.xxxx
   9: ld_structured_indexable(structured_buffer, stride=96)(mixed,mixed,mixed,mixed) o0.z, r0.x, l(60), t3.xxxx
  10: ret 

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
   0: mov r0.x, v1.x {min16u as def32}
   1: ishl r1.x {min16u}, v1.x {min16u}, l(2)
   2: imm_atomic_iadd r0.x, u1, r1.x {min16u}, r0.x
   3: ld_raw_indexable(raw_buffer)(mixed,mixed,mixed,mixed) r0.y, r1.x {min16u}, t1.xxxx
   4: utof r2.x {min16f}, r0.y
   5: utof r0.x, r0.x
   6: ld_structured_indexable(structured_buffer, stride=4)(mixed,mixed,mixed,mixed) r1.x {min16u}, v1.x {min16u}, l(0), t0.xxxx
   7: utof r2.y {min16f}, r1.x {min16u}
   8: lod r2.z {min16f}, v0.xyxx {min16f}, t2.x, s0
   9: sample_indexable(texture2d)(float,float,float,float) r1.xyzw {min16f}, v0.xyxx {min16f}, t2.xyzw, s0
  10: mad r1.xyzw {min16f}, r1.xyzw {min16f}, r2.zzzz {min16f}, r2.yyyy {min16f}
  11: ld_structured_indexable(structured_buffer, stride=4)(mixed,mixed,mixed,mixed) r3.x {min16u}, l(3), l(0), t0.xxxx
  12: utof r2.y {min16f}, r3.x {min16u}
  13: add r1.xyzw {min16f}, r1.xyzw {min16f}, r2.yyyy {min16f}
  14: add r1.xyzw {min16f}, r2.xxxx {min16f}, r1.xyzw {min16f}
  15: lod r0.y, v0.xyxx {min16f}, t3.x, s0
  16: sample_c_indexable(texture2d)(float,float,float,float) r2.x {min16f}, v0.xyxx {min16f}, t3.xxxx, s1, v0.z {min16f}
  17: add r0.y, r0.y, r2.x {min16f as def32}
  18: sample_c_lz_indexable(texture2d)(float,float,float,float) r2.x {min16f}, v0.xyxx {min16f}, t3.xxxx, s1, v0.z {min16f}
  19: add r0.y, r0.y, r2.x {min16f as def32}
  20: gather4_c_indexable(texture2d)(float,float,float,float) r2.xyzw {min16f}, v0.xyxx {min16f}, t3.xyzw, s1.x, v0.z {min16f}
  21: add r2.xyzw, r0.yyyy, r2.xyzw {min16f as def32}
  22: mov r3.xz {min16u}, v1.xxxx {min16u}
  23: mov r3.yw {min16u}, l(0,1,0,2) {def32 as min16u}
  24: gather4_po_c_indexable(texture2d)(float,float,float,float) r4.xyzw {min16f}, v0.xyxx {min16f}, r3.xyxx {min16u}, t3.xyzw, s1.x, v0.z {min16f}
  25: gather4_po_indexable(texture2d)(float,float,float,float) r3.xyzw, v0.xyxx {min16f}, r3.zwzz {min16u}, t3.xyzw, s0.x
  26: add r2.xyzw, r2.xyzw, r4.xyzw {min16f as def32}
  27: add r2.xyzw, r3.xyzw, r2.xyzw
  28: add r0.xyzw, r0.xxxx, r2.xyzw
  29: add o0.xyzw {min16f}, r0.xyzw {def32 as min16f}, r1.xyzw {min16f}
  30: ret 

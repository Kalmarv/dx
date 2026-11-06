      ps_4_0
      dcl_globalFlags refactoringAllowed | enableMinimumPrecision
      dcl_constantbuffer CB0[4], immediateIndexed
      dcl_resource_texture2d (float,float,float,float) t0
      dcl_resource_buffer (float,float,float,float) t1
      dcl_input_ps linear v0.xyz
      dcl_input_ps constant v1.xyzw
      dcl_output o0.xyzw
      dcl_temps 6
   0: mov r0.zw {min16u}, l(0,0,0,0) {def32 as min16u}
   1: ftou r0.x {min16u}, v0.x
   2: iadd r0.y {min16u}, r0.x {min16u}, v1.x {def32 as min16u}
   3: and r1.x {min16u}, r0.y {min16u}, l(7) {def32 as min16u}
   4: ld r2.xyzw, r0.xyzw {min16u}, t0.xyzw
   5: xor r3.x, r0.x {min16u as def32}, v1.y
   6: or r3.x, r1.x {min16u as def32}, r3.x
   7: ushr r0.y {min16u}, r3.x {def32 as min16u}, l(2)
   8: utof r3.x, r3.x
   9: ld r1.xyzw, r0.yyyy {min16u}, t1.xyzw
  10: ieq r3.y, r0.x {min16u}, v1.w
  11: ult r3.z, r0.x {min16u}, cb0[1].x
  12: movc r0.xyzw, r3.yyyy, r2.xyzw, r1.xyzw
  13: mad r0.xyzw, r0.xyzw, cb0[3].xyzw {min16f as def32}, cb0[0].xyzw
  14: ftoi r4.x {min16i}, v0.y
  15: ishl r4.y {min16i}, r4.x {min16i}, l(1)
  16: ilt r2.y, r4.x {min16i}, cb0[2].x
  17: imax r4.x {min16i}, r4.x {min16i}, -r4.x {min16i}
  18: itof r2.xz, r4.yyxy {min16i}
  19: movc r2.x, r2.y, r2.x, r3.x
  20: add o0.yw, r0.yyyw, r2.xxxz
  21: utof r5.x {min16f}, v1.z
  22: min r5.y {min16f}, r5.x {min16f}, cb0[3].x {min16f}
  23: max r5.z {min16f}, r5.x {min16f}, cb0[3].y {min16f}
  24: lt r2.x, r5.x {min16f}, v0.z
  25: and r2.x, r2.x, l(0x3f800000)
  26: add o0.x, r0.x, r2.x
  27: movc r5.x {min16f}, r3.z, r5.y {min16f}, r5.z {min16f}
  28: add o0.z, r0.z, r5.x {min16f as def32}
  29: ret 

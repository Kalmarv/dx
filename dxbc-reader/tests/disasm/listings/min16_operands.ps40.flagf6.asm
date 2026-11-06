      0x00000000: ps_4_0
      0x00000008: dcl_globalFlags refactoringAllowed | enableMinimumPrecision
      0x0000000C: dcl_constantbuffer CB0[4], immediateIndexed
      0x0000001C: dcl_resource_texture2d (float,float,float,float) t0
      0x0000002C: dcl_resource_buffer (float,float,float,float) t1
      0x0000003C: dcl_input_ps linear v0.xyz
      0x00000048: dcl_input_ps constant v1.xyzw
      0x00000054: dcl_output o0.xyzw
      0x00000060: dcl_temps 6
   0  0x00000068: mov r0.zw {min16u}, l(0x00000000,0x00000000,0x00000000,0x00000000) {def32 as min16u}
   1  0x0000008C: ftou r0.x {min16u}, v0.x
   2  0x000000A4: iadd r0.y {min16u}, r0.x {min16u}, v1.x {def32 as min16u}
   3  0x000000C8: and r1.x {min16u}, r0.y {min16u}, l(0x00000007) {def32 as min16u}
   4  0x000000EC: ld r2.xyzw, r0.xyzw {min16u}, t0.xyzw
   5  0x0000010C: xor r3.x, r0.x {min16u as def32}, v1.y
   6  0x0000012C: or r3.x, r1.x {min16u as def32}, r3.x
   7  0x0000014C: ushr r0.y {min16u}, r3.x {def32 as min16u}, l(0x00000002)
   8  0x0000016C: utof r3.x, r3.x
   9  0x00000180: ld r1.xyzw, r0.yyyy {min16u}, t1.xyzw
  10  0x000001A0: ieq r3.y, r0.x {min16u}, v1.w
  11  0x000001C0: ult r3.z, r0.x {min16u}, cb0[1].x
  12  0x000001E4: movc r0.xyzw, r3.yyyy, r2.xyzw, r1.xyzw
  13  0x00000208: mad r0.xyzw, r0.xyzw, cb0[3].xyzw {min16f as def32}, cb0[0].xyzw
  14  0x00000238: ftoi r4.x {min16i}, v0.y
  15  0x00000250: ishl r4.y {min16i}, r4.x {min16i}, l(0x00000001)
  16  0x00000274: ilt r2.y, r4.x {min16i}, cb0[2].x
  17  0x00000298: imax r4.x {min16i}, r4.x {min16i}, -r4.x {min16i}
  18  0x000002C0: itof r2.xz, r4.yyxy {min16i}
  19  0x000002D8: movc r2.x, r2.y, r2.x, r3.x
  20  0x000002FC: add o0.yw, r0.yyyw, r2.xxxz
  21  0x00000318: utof r5.x {min16f}, v1.z
  22  0x00000330: min r5.y {min16f}, r5.x {min16f}, cb0[3].x {min16f}
  23  0x0000035C: max r5.z {min16f}, r5.x {min16f}, cb0[3].y {min16f}
  24  0x00000388: lt r2.x, r5.x {min16f}, v0.z
  25  0x000003A8: and r2.x, r2.x, l(0x3f800000)
  26  0x000003C4: add o0.x, r0.x, r2.x
  27  0x000003E0: movc r5.x {min16f}, r3.z, r5.y {min16f}, r5.z {min16f}
  28  0x00000410: add o0.z, r0.z, r5.x {min16f as def32}
  29  0x00000430: ret 

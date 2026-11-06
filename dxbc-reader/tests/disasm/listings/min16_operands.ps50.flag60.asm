0x00000000: ps_5_0
0x00000008: dcl_globalFlags refactoringAllowed | enableMinimumPrecision
0x0000000C: dcl_constantbuffer CB0[4], immediateIndexed
0x0000001C: dcl_resource_texture2d (float,float,float,float) t0
0x0000002C: dcl_resource_buffer (float,float,float,float) t1
0x0000003C: dcl_input_ps linear v0.xyz
0x00000048: dcl_input_ps constant v1.xyzw
0x00000054: dcl_output o0.xyzw
0x00000060: dcl_temps 6
0x00000068: mov r0.zw {min16u}, l(0,0,0,0) {def32 as min16u}
0x0000008C: ftou r0.x {min16u}, v0.x
0x000000A4: iadd r0.y {min16u}, r0.x {min16u}, v1.x {def32 as min16u}
0x000000C8: and r1.x {min16u}, r0.y {min16u}, l(7) {def32 as min16u}
0x000000EC: ld_indexable(texture2d)(float,float,float,float) r2.xyzw, r0.xyzw {min16u}, t0.xyzw
0x00000114: xor r3.x, r0.x {min16u as def32}, v1.y
0x00000134: or r3.x, r1.x {min16u as def32}, r3.x
0x00000154: ushr r0.y {min16u}, r3.x {def32 as min16u}, l(2)
0x00000174: utof r3.x, r3.x
0x00000188: ld_indexable(buffer)(float,float,float,float) r1.xyzw, r0.yyyy {min16u}, t1.xyzw
0x000001B0: ieq r3.y, r0.x {min16u}, v1.w
0x000001D0: ult r3.z, r0.x {min16u}, cb0[1].x
0x000001F4: movc r0.xyzw, r3.yyyy, r2.xyzw, r1.xyzw
0x00000218: mad r0.xyzw, r0.xyzw, cb0[3].xyzw {min16f as def32}, cb0[0].xyzw
0x00000248: ftoi r4.x {min16i}, v0.y
0x00000260: ishl r4.y {min16i}, r4.x {min16i}, l(1)
0x00000284: ilt r2.y, r4.x {min16i}, cb0[2].x
0x000002A8: imax r4.x {min16i}, r4.x {min16i}, -r4.x {min16i}
0x000002D0: itof r2.xz, r4.yyxy {min16i}
0x000002E8: movc r2.x, r2.y, r2.x, r3.x
0x0000030C: add o0.yw, r0.yyyw, r2.xxxz
0x00000328: utof r5.x {min16f}, v1.z
0x00000340: min r5.y {min16f}, r5.x {min16f}, cb0[3].x {min16f}
0x0000036C: max r5.z {min16f}, r5.x {min16f}, cb0[3].y {min16f}
0x00000398: lt r2.x, r5.x {min16f}, v0.z
0x000003B8: and r2.x, r2.x, l(0x3f800000)
0x000003D4: add o0.x, r0.x, r2.x
0x000003F0: movc r5.x {min16f}, r3.z, r5.y {min16f}, r5.z {min16f}
0x00000420: add o0.z, r0.z, r5.x {min16f as def32}
0x00000440: ret 

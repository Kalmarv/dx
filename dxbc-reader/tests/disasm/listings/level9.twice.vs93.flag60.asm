0x00000000: vs_4_0
0x00000008: dcl_constantbuffer CB2[2], immediateIndexed
0x00000018: dcl_constantbuffer CB3[3], immediateIndexed
0x00000028: dcl_input v0.xyzw
0x00000034: dcl_output_siv o0.xyzw, position
0x00000044: dcl_temps 3
0x0000004C: mov r0.xyzw, v0.xyzw
0x00000060: mov r1.x, l(0)
0x00000074: loop 
0x00000078:   ige r1.y, r1.x, cb3[1].z
0x00000098:   breakc_nz r1.y
0x000000A4:   itof r1.y, r1.x
0x000000B8:   mad r0.xyzw, cb2[1].xyzw, r1.yyyy, r0.xyzw
0x000000E0:   iadd r1.x, r1.x, l(1)
0x000000FC: endloop 
0x00000100: mov r1.xyzw, r0.xyzw
0x00000114: mov r2.x, l(0)
0x00000128: loop 
0x0000012C:   ige r2.y, r2.x, cb3[1].y
0x0000014C:   breakc_nz r2.y
0x00000158:   mul r1.xyzw, r1.yzwx, r1.xyzw
0x00000174:   iadd r2.x, r2.x, l(1)
0x00000190: endloop 
0x00000194: if_nz cb3[2].x
0x000001A4:   mov o0.xyzw, -r1.xyzw
0x000001BC: else 
0x000001C0:   mov o0.xyzw, r1.xyzw
0x000001D4: endif 
0x000001D8: ret 

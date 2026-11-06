0x00000000: vs_4_0
0x00000008: dcl_constantbuffer CB2[2], immediateIndexed
0x00000018: dcl_constantbuffer CB3[3], immediateIndexed
0x00000028: dcl_input v0.xyzw
0x00000034: dcl_output_siv o0.xyzw, position
0x00000044: dcl_temps 4
//
// Initial variable locations:
//   v0.x <- p.x; v0.y <- p.y; v0.z <- p.z; v0.w <- p.w; 
//   o0.x <- <twice return value>.x; o0.y <- <twice return value>.y; o0.z <- <twice return value>.z; o0.w <- <twice return value>.w
//
#line 34 "C:\dx-fixtures\level9.hlsl"
0x0000004C: mov r0.xyzw, v0.xyzw  // r0.x <- o.x; r0.y <- o.y; r0.z <- o.z; r0.w <- o.w

#line 35
0x00000060: mov r1.x, l(0)  // r1.x <- k
0x00000074: mov r2.xyzw, r0.xyzw  // r2.x <- o.x; r2.y <- o.y; r2.z <- o.z; r2.w <- o.w
0x00000088: mov r1.y, r1.x  // r1.y <- k
0x0000009C: loop 
0x000000A0:   ilt r1.z, r1.y, cb3[1].z
0x000000C0:   breakc_z r1.z
0x000000CC:   itof r3.xyzw, r1.yyyy
0x000000E0:   mul r3.xyzw, r3.xyzw, cb2[1].xyzw
0x00000100:   add r2.xyzw, r2.xyzw, r3.xyzw
0x0000011C:   iadd r1.y, r1.y, l(1)
0x00000138: endloop 

#line 36
0x0000013C: mov r0.x, l(0)  // r0.x <- j
0x00000150: mov r1.xyzw, r2.xyzw  // r1.x <- o.x; r1.y <- o.y; r1.z <- o.z; r1.w <- o.w
0x00000164: mov r0.y, r0.x  // r0.y <- j
0x00000178: loop 
0x0000017C:   ilt r0.z, r0.y, cb3[1].y
0x0000019C:   breakc_z r0.z
0x000001A8:   mul r1.xyzw, r1.yzwx, r1.xyzw
0x000001C4:   iadd r0.y, r0.y, l(1)
0x000001E0: endloop 

#line 37
0x000001E4: ine r0.x, l(0, 0, 0, 0), cb3[2].x
0x00000210: if_nz r0.x
0x0000021C:   mov r1.xyzw, -r1.xyzw
0x00000234: endif 

#line 38
0x00000238: mov o0.xyzw, r1.xyzw
0x0000024C: ret 

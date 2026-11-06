0x00000000: vs_4_0
0x00000008: dcl_constantbuffer CB1[3], immediateIndexed
0x00000018: dcl_constantbuffer CB2[3], dynamicIndexed
0x00000028: dcl_input v0.xyzw
0x00000034: dcl_output_siv o0.xyzw, position
0x00000044: dcl_temps 3
//
// Initial variable locations:
//   v0.x <- p.x; v0.y <- p.y; v0.z <- p.z; v0.w <- p.w; 
//   o0.x <- <looped return value>.x; o0.y <- <looped return value>.y; o0.z <- <looped return value>.z; o0.w <- <looped return value>.w
//
#line 26 "C:\dx-fixtures\level9.hlsl"
0x0000004C: mov r0.xyzw, v0.xyzw  // r0.x <- o.x; r0.y <- o.y; r0.z <- o.z; r0.w <- o.w

#line 27
0x00000060: mov r1.x, l(0)  // r1.x <- k
0x00000074: mov r2.xyzw, r0.xyzw  // r2.x <- o.x; r2.y <- o.y; r2.z <- o.z; r2.w <- o.w
0x00000088: mov r1.y, r1.x  // r1.y <- k
0x0000009C: loop 
0x000000A0:   ilt r1.z, r1.y, cb1[0].x
0x000000C0:   breakc_z r1.z
0x000000CC:   add r2.xyzw, r2.xyzw, cb2[r1.y + 0].xyzw
0x000000F0:   iadd r1.y, r1.y, l(1)
0x0000010C: endloop 

#line 28
0x00000110: mul o0.xyzw, r2.xyzw, cb1[2].yyyy
0x00000130: ret 

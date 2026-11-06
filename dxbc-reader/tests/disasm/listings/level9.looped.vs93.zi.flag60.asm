0x00000000: vs_4_0
0x00000008: dcl_constantbuffer CB1[3], immediateIndexed
0x00000018: dcl_constantbuffer CB2[3], dynamicIndexed
0x00000028: dcl_input v0.xyzw
0x00000034: dcl_output_siv o0.xyzw, position
0x00000044: dcl_temps 2
//
// Initial variable locations:
//   v0.x <- p.x; v0.y <- p.y; v0.z <- p.z; v0.w <- p.w; 
//   o0.x <- <looped return value>.x; o0.y <- <looped return value>.y; o0.z <- <looped return value>.z; o0.w <- <looped return value>.w
//
#line 27 "C:\dx-fixtures\level9.hlsl"
0x0000004C: mov r0.xyzw, v0.xyzw  // r0.x <- o.x; r0.y <- o.y; r0.z <- o.z; r0.w <- o.w
0x00000060: mov r1.x, l(0)  // r1.x <- k
0x00000074: loop 
0x00000078:   ige r1.y, r1.x, cb1[0].x
0x00000098:   breakc_nz r1.y
0x000000A4:   add r0.xyzw, r0.xyzw, cb2[r1.x + 0].xyzw
0x000000C8:   iadd r1.x, r1.x, l(1)
0x000000E4: endloop 

#line 28
0x000000E8: mul o0.xyzw, r0.xyzw, cb1[2].yyyy
0x00000108: ret 

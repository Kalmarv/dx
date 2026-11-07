0x00000000: vs_4_0
0x00000008: dcl_constantbuffer CB2[2], immediateIndexed
0x00000018: dcl_constantbuffer CB3[3], immediateIndexed
0x00000028: dcl_input v0.xyzw
0x00000034: dcl_output_siv o0.xyzw, position
0x00000044: dcl_temps 3
//
// Initial variable locations:
//   v0.x <- p.x; v0.y <- p.y; v0.z <- p.z; v0.w <- p.w; 
//   o0.x <- o.x; o0.y <- o.y; o0.z <- o.z; o0.w <- o.w
//
#line 35 "C:\dx-fixtures\level9.hlsl"
0x0000004C: mov r0.xyzw, v0.xyzw  // r0.x <- o.x; r0.y <- o.y; r0.z <- o.z; r0.w <- o.w
0x00000060: mov r1.x, l(0)  // r1.x <- k
0x00000074: loop 
0x00000078:   ige r1.y, r1.x, cb3[1].z
0x00000098:   breakc_nz r1.y
0x000000A4:   itof r1.y, r1.x
0x000000B8:   mad r0.xyzw, cb2[1].xyzw, r1.yyyy, r0.xyzw
0x000000E0:   iadd r1.x, r1.x, l(1)
0x000000FC: endloop 

#line 36
0x00000100: mov r1.xyzw, r0.xyzw  // r1.x <- o.x; r1.y <- o.y; r1.z <- o.z; r1.w <- o.w
0x00000114: mov r2.x, l(0)  // r2.x <- j
0x00000128: loop 
0x0000012C:   ige r2.y, r2.x, cb3[1].y
0x0000014C:   breakc_nz r2.y
0x00000158:   mul r1.xyzw, r1.yzwx, r1.xyzw
0x00000174:   iadd r2.x, r2.x, l(1)
0x00000190: endloop 

#line 37
0x00000194: if_nz cb3[2].x
0x000001A4:   mov o0.xyzw, -r1.xyzw
0x000001BC: else_sat   // Prior locations: r1.x <- o.x; r1.y <- o.y; r1.z <- o.z; r1.w <- o.w
0x000001C0:   mov o0.xyzw, r1.xyzw  // o0.x <- o.x; o0.y <- o.y; o0.z <- o.z; o0.w <- o.w
0x000001D4: endif 

#line 38
0x000001D8: ret 

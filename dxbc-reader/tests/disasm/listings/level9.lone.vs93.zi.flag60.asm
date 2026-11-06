0x00000000: vs_4_0
0x00000008: dcl_constantbuffer CB4[1], immediateIndexed
0x00000018: dcl_input v0.xyzw
0x00000024: dcl_output_siv o0.xyzw, position
0x00000034: dcl_temps 2
//
// Initial variable locations:
//   v0.x <- p.x; v0.y <- p.y; v0.z <- p.z; v0.w <- p.w; 
//   o0.x <- o.x; o0.y <- o.y; o0.z <- o.z; o0.w <- o.w
//
#line 45 "C:\dx-fixtures\level9.hlsl"
0x0000003C: mov r0.xyzw, v0.xyzw  // r0.x <- o.x; r0.y <- o.y; r0.z <- o.z; r0.w <- o.w
0x00000050: mov r1.x, l(0)  // r1.x <- k
0x00000064: loop 
0x00000068:   ige r1.y, r1.x, cb4[0].w
0x00000088:   breakc_nz r1.y
0x00000094:   mul r0.xyzw, r0.yzwx, r0.xyzw
0x000000B0:   iadd r1.x, r1.x, l(1)
0x000000CC: endloop 

#line 46
0x000000D0: if_nz cb4[0].y
0x000000E0:   mov o0.xyzw, -r0.xyzw
0x000000F8: else   // Prior locations: r0.x <- o.x; r0.y <- o.y; r0.z <- o.z; r0.w <- o.w
0x000000FC:   mov o0.xyzw, r0.xyzw  // o0.x <- o.x; o0.y <- o.y; o0.z <- o.z; o0.w <- o.w
0x00000110: endif 

#line 47
0x00000114: ret 

0x00000000: vs_4_0
0x00000008: dcl_constantbuffer CB4[1], immediateIndexed
0x00000018: dcl_input v0.xyzw
0x00000024: dcl_output_siv o0.xyzw, position
0x00000034: dcl_temps 3
//
// Initial variable locations:
//   v0.x <- p.x; v0.y <- p.y; v0.z <- p.z; v0.w <- p.w; 
//   o0.x <- <lone return value>.x; o0.y <- <lone return value>.y; o0.z <- <lone return value>.z; o0.w <- <lone return value>.w
//
#line 44 "C:\dx-fixtures\level9.hlsl"
0x0000003C: mov r0.xyzw, v0.xyzw  // r0.x <- o.x; r0.y <- o.y; r0.z <- o.z; r0.w <- o.w

#line 45
0x00000050: mov r1.x, l(0)  // r1.x <- k
0x00000064: mov r2.xyzw, r0.xyzw  // r2.x <- o.x; r2.y <- o.y; r2.z <- o.z; r2.w <- o.w
0x00000078: mov r1.y, r1.x  // r1.y <- k
0x0000008C: loop 
0x00000090:   ilt r1.z, r1.y, cb4[0].w
0x000000B0:   breakc_z r1.z
0x000000BC:   mul r2.xyzw, r2.yzwx, r2.xyzw
0x000000D8:   iadd r1.y, r1.y, l(1)
0x000000F4: endloop 

#line 46
0x000000F8: ine r0.x, l(0, 0, 0, 0), cb4[0].y
0x00000124: if_nz r0.x
0x00000130:   mov r2.xyzw, -r2.xyzw
0x00000148: endif 

#line 47
0x0000014C: mov o0.xyzw, r2.xyzw
0x00000160: ret 

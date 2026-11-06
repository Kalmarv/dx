      0x00000000: vs_4_0
      0x00000008: dcl_constantbuffer CB4[1], immediateIndexed
      0x00000018: dcl_input v0.xyzw
      0x00000024: dcl_output_siv o0.xyzw, position
      0x00000034: dcl_temps 3
   0  0x0000003C: mov r0.xyzw, v0.xyzw
   1  0x00000050: mov r1.x, l(0x00000000)
   2  0x00000064: mov r2.xyzw, r0.xyzw
   3  0x00000078: mov r1.y, r1.x
   4  0x0000008C: loop 
   5  0x00000090:   ilt r1.z, r1.y, cb4[0].w
   6  0x000000B0:   breakc_z r1.z
   7  0x000000BC:   mul r2.xyzw, r2.yzwx, r2.xyzw
   8  0x000000D8:   iadd r1.y, r1.y, l(0x00000001)
   9  0x000000F4: endloop 
  10  0x000000F8: ine r0.x, l(0x00000000, 0x00000000, 0x00000000, 0x00000000), cb4[0].y
  11  0x00000124: if_nz r0.x
  12  0x00000130:   mov r2.xyzw, -r2.xyzw
  13  0x00000148: endif 
  14  0x0000014C: mov o0.xyzw, r2.xyzw
  15  0x00000160: ret 

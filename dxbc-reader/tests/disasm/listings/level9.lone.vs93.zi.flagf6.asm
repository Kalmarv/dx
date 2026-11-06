      0x00000000: vs_4_0
      0x00000008: dcl_constantbuffer CB4[1], immediateIndexed
      0x00000018: dcl_input v0.xyzw
      0x00000024: dcl_output_siv o0.xyzw, position
      0x00000034: dcl_temps 2
   0  0x0000003C: mov r0.xyzw, v0.xyzw
   1  0x00000050: mov r1.x, l(0x00000000)
   2  0x00000064: loop 
   3  0x00000068:   ige r1.y, r1.x, cb4[0].w
   4  0x00000088:   breakc_nz r1.y
   5  0x00000094:   mul r0.xyzw, r0.yzwx, r0.xyzw
   6  0x000000B0:   iadd r1.x, r1.x, l(0x00000001)
   7  0x000000CC: endloop 
   8  0x000000D0: if_nz cb4[0].y
   9  0x000000E0:   mov o0.xyzw, -r0.xyzw
  10  0x000000F8: else 
  11  0x000000FC:   mov o0.xyzw, r0.xyzw
  12  0x00000110: endif 
  13  0x00000114: ret 

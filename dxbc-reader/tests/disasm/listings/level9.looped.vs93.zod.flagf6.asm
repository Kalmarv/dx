      0x00000000: vs_4_0
      0x00000008: dcl_constantbuffer CB1[3], immediateIndexed
      0x00000018: dcl_constantbuffer CB2[3], dynamicIndexed
      0x00000028: dcl_input v0.xyzw
      0x00000034: dcl_output_siv o0.xyzw, position
      0x00000044: dcl_temps 3
   0  0x0000004C: mov r0.xyzw, v0.xyzw
   1  0x00000060: mov r1.x, l(0x00000000)
   2  0x00000074: mov r2.xyzw, r0.xyzw
   3  0x00000088: mov r1.y, r1.x
   4  0x0000009C: loop 
   5  0x000000A0:   ilt r1.z, r1.y, cb1[0].x
   6  0x000000C0:   breakc_z r1.z
   7  0x000000CC:   add r2.xyzw, r2.xyzw, cb2[r1.y + 0].xyzw
   8  0x000000F0:   iadd r1.y, r1.y, l(0x00000001)
   9  0x0000010C: endloop 
  10  0x00000110: mul o0.xyzw, r2.xyzw, cb1[2].yyyy
  11  0x00000130: ret 

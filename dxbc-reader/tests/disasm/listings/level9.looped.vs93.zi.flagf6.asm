      0x00000000: vs_4_0
      0x00000008: dcl_constantbuffer CB1[3], immediateIndexed
      0x00000018: dcl_constantbuffer CB2[3], dynamicIndexed
      0x00000028: dcl_input v0.xyzw
      0x00000034: dcl_output_siv o0.xyzw, position
      0x00000044: dcl_temps 2
   0  0x0000004C: mov r0.xyzw, v0.xyzw
   1  0x00000060: mov r1.x, l(0x00000000)
   2  0x00000074: loop 
   3  0x00000078:   ige r1.y, r1.x, cb1[0].x
   4  0x00000098:   breakc_nz r1.y
   5  0x000000A4:   add r0.xyzw, r0.xyzw, cb2[r1.x + 0].xyzw
   6  0x000000C8:   iadd r1.x, r1.x, l(0x00000001)
   7  0x000000E4: endloop 
   8  0x000000E8: mul o0.xyzw, r0.xyzw, cb1[2].yyyy
   9  0x00000108: ret 

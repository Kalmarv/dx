      0x00000000: vs_4_0
      0x00000008: dcl_constantbuffer CB2[2], immediateIndexed
      0x00000018: dcl_constantbuffer CB3[3], immediateIndexed
      0x00000028: dcl_input v0.xyzw
      0x00000034: dcl_output_siv o0.xyzw, position
      0x00000044: dcl_temps 4
   0  0x0000004C: mov r0.xyzw, v0.xyzw
   1  0x00000060: mov r1.x, l(0x00000000)
   2  0x00000074: mov r2.xyzw, r0.xyzw
   3  0x00000088: mov r1.y, r1.x
   4  0x0000009C: loop 
   5  0x000000A0:   ilt r1.z, r1.y, cb3[1].z
   6  0x000000C0:   breakc_z r1.z
   7  0x000000CC:   itof r3.xyzw, r1.yyyy
   8  0x000000E0:   mul r3.xyzw, r3.xyzw, cb2[1].xyzw
   9  0x00000100:   add r2.xyzw, r2.xyzw, r3.xyzw
  10  0x0000011C:   iadd r1.y, r1.y, l(0x00000001)
  11  0x00000138: endloop 
  12  0x0000013C: mov r0.x, l(0x00000000)
  13  0x00000150: mov r1.xyzw, r2.xyzw
  14  0x00000164: mov r0.y, r0.x
  15  0x00000178: loop 
  16  0x0000017C:   ilt r0.z, r0.y, cb3[1].y
  17  0x0000019C:   breakc_z r0.z
  18  0x000001A8:   mul r1.xyzw, r1.yzwx, r1.xyzw
  19  0x000001C4:   iadd r0.y, r0.y, l(0x00000001)
  20  0x000001E0: endloop 
  21  0x000001E4: ine r0.x, l(0x00000000, 0x00000000, 0x00000000, 0x00000000), cb3[2].x
  22  0x00000210: if_nz r0.x
  23  0x0000021C:   mov r1.xyzw, -r1.xyzw
  24  0x00000234: endif 
  25  0x00000238: mov o0.xyzw, r1.xyzw
  26  0x0000024C: ret 

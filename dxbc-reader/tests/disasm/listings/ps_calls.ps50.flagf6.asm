      0x00000000: ps_5_0
      0x00000008: dcl_globalFlags refactoringAllowed
      0x0000000C: dcl_input_ps linear v0.xy
      0x00000018: dcl_input_ps constant v1.xy
      0x00000024: dcl_output o0.x
      0x00000030: dcl_temps 1
   0  0x00000038: switch v1.x
   1  0x00000044:   case l(0x00000001)
   2  0x00000050:   call label0
   3  0x0000005C:   break 
   4  0x00000060:   case l(0x00000002)
   5  0x0000006C:   call label1
   6  0x00000078:   break 
   7  0x0000007C:   default 
   8  0x00000080:   call label2
   9  0x0000008C:   break 
  10  0x00000090: endswitch 
  11  0x00000094: ilt r0.y, l(0x00000000), v1.y
  12  0x000000B0: add r0.z, r0.x, v0.y
  13  0x000000CC: add r0.x, r0.x, l(0xbf800000)
  14  0x000000E8: movc o0.x, r0.y, r0.z, r0.x
  15  0x0000010C: ret 
  16  0x00000110: label label0
  17  0x0000011C: mov r0.x, l(0x40a00000)
  18  0x00000130: ret 
  19  0x00000134: label label1
  20  0x00000140: mov r0.x, v0.x
  21  0x00000154: ret 
  22  0x00000158: label label2
  23  0x00000164: mov r0.x, l(0x40400000)
  24  0x00000178: ret 

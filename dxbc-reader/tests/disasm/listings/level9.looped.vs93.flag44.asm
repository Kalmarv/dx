      vs_4_0
      dcl_constantbuffer CB1[3], immediateIndexed
      dcl_constantbuffer CB2[3], dynamicIndexed
      dcl_input v0.xyzw
      dcl_output_siv o0.xyzw, position
      dcl_temps 2
   0: mov r0.xyzw, v0.xyzw
   1: mov r1.x, l(0)
   2: loop 
   3:   ige r1.y, r1.x, cb1[0].x
   4:   breakc_nz r1.y
   5:   add r0.xyzw, r0.xyzw, cb2[r1.x + 0].xyzw
   6:   iadd r1.x, r1.x, l(1)
   7: endloop 
   8: mul o0.xyzw, r0.xyzw, cb1[2].yyyy
   9: ret 

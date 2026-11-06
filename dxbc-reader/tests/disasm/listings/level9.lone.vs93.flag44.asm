      vs_4_0
      dcl_constantbuffer CB4[1], immediateIndexed
      dcl_input v0.xyzw
      dcl_output_siv o0.xyzw, position
      dcl_temps 2
   0: mov r0.xyzw, v0.xyzw
   1: mov r1.x, l(0)
   2: loop 
   3:   ige r1.y, r1.x, cb4[0].w
   4:   breakc_nz r1.y
   5:   mul r0.xyzw, r0.yzwx, r0.xyzw
   6:   iadd r1.x, r1.x, l(1)
   7: endloop 
   8: if_nz cb4[0].y
   9:   mov o0.xyzw, -r0.xyzw
  10: else 
  11:   mov o0.xyzw, r0.xyzw
  12: endif 
  13: ret 

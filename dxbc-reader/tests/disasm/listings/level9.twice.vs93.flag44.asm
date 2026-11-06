      vs_4_0
      dcl_constantbuffer CB2[2], immediateIndexed
      dcl_constantbuffer CB3[3], immediateIndexed
      dcl_input v0.xyzw
      dcl_output_siv o0.xyzw, position
      dcl_temps 3
   0: mov r0.xyzw, v0.xyzw
   1: mov r1.x, l(0)
   2: loop 
   3:   ige r1.y, r1.x, cb3[1].z
   4:   breakc_nz r1.y
   5:   itof r1.y, r1.x
   6:   mad r0.xyzw, cb2[1].xyzw, r1.yyyy, r0.xyzw
   7:   iadd r1.x, r1.x, l(1)
   8: endloop 
   9: mov r1.xyzw, r0.xyzw
  10: mov r2.x, l(0)
  11: loop 
  12:   ige r2.y, r2.x, cb3[1].y
  13:   breakc_nz r2.y
  14:   mul r1.xyzw, r1.yzwx, r1.xyzw
  15:   iadd r2.x, r2.x, l(1)
  16: endloop 
  17: if_nz cb3[2].x
  18:   mov o0.xyzw, -r1.xyzw
  19: else 
  20:   mov o0.xyzw, r1.xyzw
  21: endif 
  22: ret 

      gs_4_1
      dcl_globalFlags refactoringAllowed
      dcl_constantbuffer CB0[24], dynamicIndexed
      dcl_input v[3][0].xyzw
      dcl_temps 3
      dcl_inputprimitive triangle 
      dcl_outputtopology trianglestrip 
      dcl_output_siv o0.xyzw, position
      dcl_output o1.xyzw
      dcl_output_siv o2.x, rendertarget_array_index
      dcl_maxout 18
   0: mov r0.x, l(0)
   1: loop 
   2:   uge r0.y, r0.x, l(6)
   3:   breakc_nz r0.y
   4:   ishl r0.y, r0.x, l(2)
   5:   utof r0.z, r0.x
   6:   mul r0.z, r0.z, l(0.166667)
   7:   mov r0.w, l(0)
   8:   loop 
   9:     uge r1.x, r0.w, l(3)
  10:     breakc_nz r1.x
  11:     dp4 r1.x, v[r0.w + 0][0].xyzw, cb0[r0.y + 0].xyzw
  12:     dp4 r1.y, v[r0.w + 0][0].xyzw, cb0[r0.y + 1].xyzw
  13:     dp4 r1.z, v[r0.w + 0][0].xyzw, cb0[r0.y + 2].xyzw
  14:     dp4 r1.w, v[r0.w + 0][0].xyzw, cb0[r0.y + 3].xyzw
  15:     utof r2.x, r0.w
  16:     mul r2.x, r2.x, l(0.333333)
  17:     mov o0.x, r1.x
  18:     mov o0.y, r1.y
  19:     mov o0.z, r1.z
  20:     mov o0.w, r1.w
  21:     mov o1.x, r0.z
  22:     mov o1.y, r2.x
  23:     mov o1.zw, l(0,0,0,1.000000)
  24:     mov o2.x, r0.x
  25:     emit 
  26:     iadd r0.w, r0.w, l(1)
  27:   endloop 
  28:   cut 
  29:   iadd r0.x, r0.x, l(1)
  30: endloop 
  31: ret 

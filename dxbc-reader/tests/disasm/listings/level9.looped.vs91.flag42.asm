vs_4_0
dcl_constantbuffer CB1[3], immediateIndexed
dcl_constantbuffer CB2[3], dynamicIndexed
dcl_input v0.xyzw
dcl_output_siv o0.xyzw, position
dcl_temps 2
mov r0.xyzw, v0.xyzw
mov r1.x, l(0)
loop 
  ige r1.y, r1.x, cb1[0].x
  breakc_nz r1.y
  add r0.xyzw, r0.xyzw, cb2[r1.x + 0].xyzw
  iadd r1.x, r1.x, l(1)
endloop 
mul o0.xyzw, r0.xyzw, cb1[2].yyyy
ret 

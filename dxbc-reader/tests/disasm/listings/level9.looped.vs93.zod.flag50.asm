vs_4_0
dcl_constantbuffer CB1[3], immediateIndexed
dcl_constantbuffer CB2[3], dynamicIndexed
dcl_input v0.xyzw
dcl_output_siv o0.xyzw, position
dcl_temps 3
mov r0.xyzw, v0.xyzw
mov r1.x, l(0)
mov r2.xyzw, r0.xyzw
mov r1.y, r1.x
loop 
  ilt r1.z, r1.y, cb1[0].x
  breakc_z r1.z
  add r2.xyzw, r2.xyzw, cb2[r1.y + 0].xyzw
  iadd r1.y, r1.y, l(1)
endloop 
mul o0.xyzw, r2.xyzw, cb1[2].yyyy
ret 

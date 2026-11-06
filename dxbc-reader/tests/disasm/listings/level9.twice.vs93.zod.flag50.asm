vs_4_0
dcl_constantbuffer CB2[2], immediateIndexed
dcl_constantbuffer CB3[3], immediateIndexed
dcl_input v0.xyzw
dcl_output_siv o0.xyzw, position
dcl_temps 4
mov r0.xyzw, v0.xyzw
mov r1.x, l(0)
mov r2.xyzw, r0.xyzw
mov r1.y, r1.x
loop 
  ilt r1.z, r1.y, cb3[1].z
  breakc_z r1.z
  itof r3.xyzw, r1.yyyy
  mul r3.xyzw, r3.xyzw, cb2[1].xyzw
  add r2.xyzw, r2.xyzw, r3.xyzw
  iadd r1.y, r1.y, l(1)
endloop 
mov r0.x, l(0)
mov r1.xyzw, r2.xyzw
mov r0.y, r0.x
loop 
  ilt r0.z, r0.y, cb3[1].y
  breakc_z r0.z
  mul r1.xyzw, r1.yzwx, r1.xyzw
  iadd r0.y, r0.y, l(1)
endloop 
ine r0.x, l(0, 0, 0, 0), cb3[2].x
if_nz r0.x
  mov r1.xyzw, -r1.xyzw
endif 
mov o0.xyzw, r1.xyzw
ret 

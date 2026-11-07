vs_4_0
dcl_constantbuffer CB2[2], immediateIndexed
dcl_constantbuffer CB3[3], immediateIndexed
dcl_input v0.xyzw
dcl_output_siv o0.xyzw, position
dcl_temps 3
mov r0.xyzw, v0.xyzw
mov r1.x, l(0)
loop 
  ige r1.y, r1.x, cb3[1].z
  breakc_nz r1.y
  itof r1.y, r1.x
  mad r0.xyzw, cb2[1].xyzw, r1.yyyy, r0.xyzw
  iadd r1.x, r1.x, l(1)
endloop 
mov r1.xyzw, r0.xyzw
mov r2.x, l(0)
loop 
  ige r2.y, r2.x, cb3[1].y
  breakc_nz r2.y
  mul r1.xyzw, r1.yzwx, r1.xyzw
  iadd r2.x, r2.x, l(1)
endloop 
if_nz cb3[2].x
  mov o0.xyzw, -r1.xyzw
else_sat 
  mov o0.xyzw, r1.xyzw
endif 
ret 

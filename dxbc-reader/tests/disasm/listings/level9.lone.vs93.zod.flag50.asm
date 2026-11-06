vs_4_0
dcl_constantbuffer CB4[1], immediateIndexed
dcl_input v0.xyzw
dcl_output_siv o0.xyzw, position
dcl_temps 3
mov r0.xyzw, v0.xyzw
mov r1.x, l(0)
mov r2.xyzw, r0.xyzw
mov r1.y, r1.x
loop 
  ilt r1.z, r1.y, cb4[0].w
  breakc_z r1.z
  mul r2.xyzw, r2.yzwx, r2.xyzw
  iadd r1.y, r1.y, l(1)
endloop 
ine r0.x, l(0, 0, 0, 0), cb4[0].y
if_nz r0.x
  mov r2.xyzw, -r2.xyzw
endif 
mov o0.xyzw, r2.xyzw
ret 

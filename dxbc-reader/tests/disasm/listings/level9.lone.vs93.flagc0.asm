vs_4_0
dcl_constantbuffer CB4[1], immediateIndexed
dcl_input v0.xyzw
dcl_output_siv o0.xyzw, position
dcl_temps 2
mov r0.xyzw, v0.xyzw
mov r1.x, l(0x00000000)
loop 
  ige r1.y, r1.x, cb4[0].w
  breakc_nz r1.y
  mul r0.xyzw, r0.yzwx, r0.xyzw
  iadd r1.x, r1.x, l(0x00000001)
endloop 
if_nz cb4[0].y
  mov o0.xyzw, -r0.xyzw
else 
  mov o0.xyzw, r0.xyzw
endif 
ret 

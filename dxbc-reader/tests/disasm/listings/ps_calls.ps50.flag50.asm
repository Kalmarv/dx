ps_5_0
dcl_globalFlags refactoringAllowed
dcl_input_ps linear v0.xy
dcl_input_ps constant v1.xy
dcl_output o0.x
dcl_temps 1
switch v1.x
  case l(1)
  call label0
  break 
  case l(2)
  call label1
  break 
  default 
  call label2
  break 
endswitch 
ilt r0.y, l(0), v1.y
add r0.z, r0.x, v0.y
add r0.x, r0.x, l(-1.000000)
movc o0.x, r0.y, r0.z, r0.x
ret 
label label0
mov r0.x, l(5.000000)
ret 
label label1
mov r0.x, v0.x
ret 
label label2
mov r0.x, l(3.000000)
ret 

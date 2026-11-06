      ps_5_0
      dcl_globalFlags refactoringAllowed
      dcl_input_ps linear v0.xy
      dcl_input_ps constant v1.xy
      dcl_output o0.x
      dcl_temps 1
   0: switch v1.x
   1:   case l(1)
   2:   call label0
   3:   break 
   4:   case l(2)
   5:   call label1
   6:   break 
   7:   default 
   8:   call label2
   9:   break 
  10: endswitch 
  11: ilt r0.y, l(0), v1.y
  12: add r0.z, r0.x, v0.y
  13: add r0.x, r0.x, l(-1.000000)
  14: movc o0.x, r0.y, r0.z, r0.x
  15: ret 
  16: label label0
  17: mov r0.x, l(5.000000)
  18: ret 
  19: label label1
  20: mov r0.x, v0.x
  21: ret 
  22: label label2
  23: mov r0.x, l(3.000000)
  24: ret 

ps_5_1
dcl_globalFlags refactoringAllowed | skipOptimization
dcl_uav_structured U0[1:5], 4, space=0
dcl_input_ps constant v0.x
dcl_output o0.xyzw
dcl_temps 1
mov r0.x, l(0)
imm_atomic_alloc r0.x, U0[r0.x + 1]
mov r0.x, l(1)
ld_structured r0.x, v0.x, l(0), U0[r0.x + 1].xxxx
utof o0.xyzw, r0.xxxx
ret 

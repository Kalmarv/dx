      0x00000000: ps_5_1
      0x00000008: dcl_globalFlags refactoringAllowed | skipOptimization
      0x0000000C: dcl_uav_structured U0[1:5], 4, space=0
      0x00000028: dcl_input_ps constant v0.x
      0x00000034: dcl_output o0.xyzw
      0x00000040: dcl_temps 1
   0  0x00000048: mov r0.x, l(0x00000000)
   1  0x0000005C: imm_atomic_alloc r0.x, U0[r0.x + 1]
   2  0x0000007C: mov r0.x, l(0x00000001)
   3  0x00000090: ld_structured r0.x, v0.x, l(0x00000000), U0[r0.x + 1].xxxx
   4  0x000000C0: utof o0.xyzw, r0.xxxx
   5  0x000000D4: ret 

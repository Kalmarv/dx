      ps_5_1
      dcl_globalFlags refactoringAllowed | skipOptimization
      dcl_uav_structured U0[1:5], 4, space=0
      dcl_input_ps constant v0.x
      dcl_output o0.xyzw
      dcl_temps 1
//
// Initial variable locations:
//   v0.x <- idx; 
//   o0.x <- <main return value>.x; o0.y <- <main return value>.y; o0.z <- <main return value>.z; o0.w <- <main return value>.w
//
#line 9 "C:\dx-fixtures\zi_uav_local.hlsl"
   0: mov r0.x, l(0)  // U1 <- local
   1: imm_atomic_alloc r0.x, U0[r0.x + 1]

#line 10
   2: mov r0.x, l(1)
   3: ld_structured r0.x, v0.x, l(0), U0[r0.x + 1].xxxx
   4: utof o0.xyzw, r0.xxxx
   5: ret 

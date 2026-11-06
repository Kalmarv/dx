      ps_5_0
      dcl_globalFlags refactoringAllowed | skipOptimization
      dcl_constantbuffer CB0[1], immediateIndexed
      dcl_function_body fb0
      dcl_function_table ft0 = {fb0}
      dcl_interface fp0[1][1] = {ft0}
      dcl_input_ps linear v0.xyz
      dcl_input_ps_sgv constant v1.x, sampleIndex
      dcl_output o0.xyzw
      dcl_temps 2
//
// Initial variable locations:
//   v0.x <- n.x; v0.y <- n.y; v0.z <- n.z; 
//   v1.x <- s; 
//   o0.x <- <main return value>.x; o0.y <- <main return value>.y; o0.z <- <main return value>.z; o0.w <- <main return value>.w
//
#line 8 "C:\dx-fixtures\classes_sample_rate.hlsl"
   0: nop 
   1: mov r0.xyz, v0.xyzx
   2: fcall fp0[0][0]
   3: utof r0.xyz, v1.xxxx
   4: mul o0.xyz, r0.xyzx, r1.xyzx
   5: itof o0.w, l(1)
   6: ret 

#line 6 "C:\dx-fixtures\classes_sample_rate.hlsl"
   7: label fb0
   8: nop 
   9: mov r0.w, this[0].y
  10: mov r1.w, this[0].x
  11: mul r1.xyz, r0.xyzx, cb[r1.w + 0][r0.w + 0].xxxx
  12: ret 

      vs_5_0
      dcl_globalFlags refactoringAllowed | skipOptimization
      dcl_constantbuffer CB0[2], immediateIndexed
      dcl_function_body fb0
      dcl_function_body fb1
      dcl_function_table ft0 = {fb0}
      dcl_function_table ft1 = {fb1}
      dcl_interface fp0[1][1] = {ft0, ft1}
      dcl_input v0.xyzw
      dcl_output_siv o0.xyzw, position
      dcl_temps 2
//
// Initial variable locations:
//   v0.x <- p.x; v0.y <- p.y; v0.z <- p.z; v0.w <- p.w; 
//   o0.x <- <vmain return value>.x; o0.y <- <vmain return value>.y; o0.z <- <vmain return value>.z; o0.w <- <vmain return value>.w
//
#line 28 "C:\dx-fixtures\classes_resources.hlsl"
   0: nop 
   1: mov r0.xyzw, v0.wzyx
   2: fcall fp0[0][0]
   3: mov o0.xyzw, r0.xyzw
   4: ret 

#line 15 "C:\dx-fixtures\classes_resources.hlsl"
   5: label fb0
   6: nop 
   7: mov r0.xyzw, r0.xyzw
   8: ret 

#line 14 "C:\dx-fixtures\classes_resources.hlsl"
   9: label fb1
  10: nop 
  11: mov r1.x, this[0].y
  12: mov r1.y, this[0].x
  13: mul r0.xyzw, r0.wzyx, cb[r1.y + 0][r1.x + 0].xyzw
  14: ret 

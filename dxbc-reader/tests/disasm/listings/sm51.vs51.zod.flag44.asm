      vs_5_1
      dcl_globalFlags refactoringAllowed | skipOptimization
      dcl_constantbuffer CB0[2:2][4], immediateIndexed, space=0
      dcl_constantbuffer CB1[0:7][1], dynamicIndexed, space=1
      dcl_input v0.xyz
      dcl_input_sgv v1.x, instance_id
      dcl_output_siv o0.xyzw, position
      dcl_temps 2
//
// Initial variable locations:
//   v0.x <- pos.x; v0.y <- pos.y; v0.z <- pos.z; 
//   v1.x <- iid; 
//   o0.x <- <vs return value>.x; o0.y <- <vs return value>.y; o0.z <- <vs return value>.z; o0.w <- <vs return value>.w
//
#line 32 "C:\dx-fixtures\sm51.hlsl"
   0: itof r0.w, l(1)
   1: mov r1.x, l(7)
   2: and r1.x, r1.x, v1.x
   3: mov r0.xyz, v0.xyzx
   4: mul r0.xyzw, r0.xyzw, CB1[r1.x + 0][0].xyzw
   5: dp4 o0.x, r0.xyzw, CB0[2][0].xyzw
   6: dp4 o0.y, r0.xyzw, CB0[2][1].xyzw
   7: dp4 o0.z, r0.xyzw, CB0[2][2].xyzw
   8: dp4 o0.w, r0.xyzw, CB0[2][3].xyzw
   9: ret 

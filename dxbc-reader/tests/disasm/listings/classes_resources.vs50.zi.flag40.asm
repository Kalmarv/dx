vs_5_0
dcl_globalFlags refactoringAllowed
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
fcall fp0[0][0]
mov o0.xyzw, r0.xyzw
ret 

#line 15 "C:\dx-fixtures\classes_resources.hlsl"
label fb0
mov r0.xyzw, v0.wzyx
ret 

#line 14 "C:\dx-fixtures\classes_resources.hlsl"
label fb1
mov r1.xy, this[0].yxyy
mul r0.xyzw, v0.xyzw, cb[r1.y + 0][r1.x + 0].xyzw
ret 

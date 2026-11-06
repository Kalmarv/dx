0x00000000: ps_5_0
0x00000008: dcl_globalFlags refactoringAllowed | skipOptimization
0x0000000C: dcl_constantbuffer CB0[1], immediateIndexed
0x0000001C: dcl_function_body fb0
0x00000024: dcl_function_table ft0 = {fb0}
0x00000034: dcl_interface fp0[1][1] = {ft0}
0x00000048: dcl_input_ps linear v0.xyz
0x00000054: dcl_input_ps_sgv constant v1.x, sampleIndex
0x00000064: dcl_output o0.xyzw
0x00000070: dcl_temps 2
//
// Initial variable locations:
//   v0.x <- n.x; v0.y <- n.y; v0.z <- n.z; 
//   v1.x <- s; 
//   o0.x <- <main return value>.x; o0.y <- <main return value>.y; o0.z <- <main return value>.z; o0.w <- <main return value>.w
//
#line 8 "C:\dx-fixtures\classes_sample_rate.hlsl"
0x00000078: nop 
0x0000007C: mov r0.xyz, v0.xyzx
0x00000090: fcall fp0[0][0]
0x000000A4: utof r0.xyz, v1.xxxx
0x000000B8: mul o0.xyz, r0.xyzx, r1.xyzx
0x000000D4: itof o0.w, l(1)
0x000000E8: ret 

#line 6 "C:\dx-fixtures\classes_sample_rate.hlsl"
0x000000EC: label fb0
0x000000F8: nop 
0x000000FC: mov r0.w, this[0].y
0x00000110: mov r1.w, this[0].x
0x00000124: mul r1.xyz, r0.xyzx, cb[r1.w + 0][r0.w + 0].xxxx
0x0000014C: ret 

0x00000000: vs_5_0
0x00000008: dcl_globalFlags refactoringAllowed | skipOptimization
0x0000000C: dcl_constantbuffer CB0[2], immediateIndexed
0x0000001C: dcl_function_body fb0
0x00000024: dcl_function_body fb1
0x0000002C: dcl_function_table ft0 = {fb0}
0x0000003C: dcl_function_table ft1 = {fb1}
0x0000004C: dcl_interface fp0[1][1] = {ft0, ft1}
0x00000064: dcl_input v0.xyzw
0x00000070: dcl_output_siv o0.xyzw, position
0x00000080: dcl_temps 2
//
// Initial variable locations:
//   v0.x <- p.x; v0.y <- p.y; v0.z <- p.z; v0.w <- p.w; 
//   o0.x <- <vmain return value>.x; o0.y <- <vmain return value>.y; o0.z <- <vmain return value>.z; o0.w <- <vmain return value>.w
//
#line 28 "C:\dx-fixtures\classes_resources.hlsl"
0x00000088: nop 
0x0000008C: mov r0.xyzw, v0.wzyx
0x000000A0: fcall fp0[0][0]
0x000000B4: mov o0.xyzw, r0.xyzw
0x000000C8: ret 

#line 15 "C:\dx-fixtures\classes_resources.hlsl"
0x000000CC: label fb0
0x000000D8: nop 
0x000000DC: mov r0.xyzw, r0.xyzw
0x000000F0: ret 

#line 14 "C:\dx-fixtures\classes_resources.hlsl"
0x000000F4: label fb1
0x00000100: nop 
0x00000104: mov r1.x, this[0].y
0x00000118: mov r1.y, this[0].x
0x0000012C: mul r0.xyzw, r0.wzyx, cb[r1.y + 0][r1.x + 0].xyzw
0x00000154: ret 

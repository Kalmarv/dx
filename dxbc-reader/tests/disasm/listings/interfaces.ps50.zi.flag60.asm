0x00000000: ps_5_0
0x00000008: dcl_globalFlags refactoringAllowed
0x0000000C: dcl_constantbuffer CB0[4], immediateIndexed
0x0000001C: dcl_function_body fb0
0x00000024: dcl_function_body fb1
0x0000002C: dcl_function_body fb2
0x00000034: dcl_function_body fb3
0x0000003C: dcl_function_body fb4
0x00000044: dcl_function_body fb5
0x0000004C: dcl_function_table ft0 = {fb0, fb2}
0x00000060: dcl_function_table ft1 = {fb1, fb3}
0x00000074: dcl_function_table ft2 = {fb4}
0x00000084: dcl_function_table ft3 = {fb5}
0x00000094: dcl_interface fp0[2][2] = {ft0, ft1}
0x000000AC: dcl_interface fp2[1][1] = {ft2, ft3}
0x000000C4: dcl_input_ps linear v0.xyz
0x000000D0: dcl_output o0.xyzw
0x000000DC: dcl_temps 3
//
// Initial variable locations:
//   v0.x <- n.x; v0.y <- n.y; v0.z <- n.z; 
//   o0.x <- <main return value>.x; o0.y <- <main return value>.y; o0.z <- <main return value>.z; o0.w <- <main return value>.w
//
#line 17 "C:\dx-fixtures\interfaces.hlsl"
0x000000E4: fcall fp0[0][0]
0x000000F8: fcall fp0[1][1]
0x0000010C: add r0.xyz, r0.xyzx, r1.xyzx  // r0.x <- c.x; r0.y <- c.y; r0.z <- c.z

#line 18
0x00000128: fcall fp2[0][0]
0x0000013C: mov o0.xyzw, r0.xyzw
0x00000150: ret 

#line 8 "C:\dx-fixtures\interfaces.hlsl"
0x00000154: label fb0
0x00000160: mov r0.w, this[0].y
0x00000174: mov r1.x, this[0].x
0x00000188: mov r0.xyz, cb[r1.x + 0][r0.w + 0].xyzx
0x000001A8: ret 

#line 7 "C:\dx-fixtures\interfaces.hlsl"
0x000001AC: label fb1
0x000001B8: mov r0.w, this[0].y
0x000001CC: mov r1.x, this[0].x
0x000001E0: dp3_sat r1.y, v0.xyzx, cb[r1.x + 0][r0.w + 0].xyzx
0x00000208: mul r0.xyz, r1.yyyy, cb[r1.x + 0][r0.w + 1].xyzx
0x00000234: ret 

#line 8 "C:\dx-fixtures\interfaces.hlsl"
0x00000238: label fb2
0x00000244: mov r0.w, this[1].y
0x00000258: mov r1.w, this[1].x
0x0000026C: mov r1.xyz, cb[r1.w + 0][r0.w + 0].xyzx
0x0000028C: ret 

#line 7 "C:\dx-fixtures\interfaces.hlsl"
0x00000290: label fb3
0x0000029C: mov r0.w, this[1].y
0x000002B0: mov r1.w, this[1].x
0x000002C4: dp3_sat r2.x, v0.xyzx, cb[r1.w + 0][r0.w + 0].xyzx
0x000002EC: mul r1.xyz, r2.xxxx, cb[r1.w + 0][r0.w + 1].xyzx
0x00000318: ret   // r0.x <- c.x; r0.y <- c.y; r0.z <- c.z

#line 11 "C:\dx-fixtures\interfaces.hlsl"
0x0000031C: label fb4
0x00000328: mov r0.w, l(1.000000)
0x0000033C: mov r1.xy, this[2].yxyy
0x00000350: mul r0.xyzw, r0.xyzw, cb[r1.y + 0][r1.x + 0].xyzw
0x00000378: ret 

#line 10 "C:\dx-fixtures\interfaces.hlsl"
0x0000037C: label fb5
0x00000388: mov r0.w, l(1.000000)
0x0000039C: ret 

0x00000000: vs_5_1
0x00000008: dcl_globalFlags refactoringAllowed | skipOptimization
0x0000000C: dcl_constantbuffer CB0[2:2][4], immediateIndexed, space=0
0x00000028: dcl_constantbuffer CB1[0:7][1], dynamicIndexed, space=1
0x00000044: dcl_input v0.xyz
0x00000050: dcl_input_sgv v1.x, instance_id
0x00000060: dcl_output_siv o0.xyzw, position
0x00000070: dcl_temps 2
//
// Initial variable locations:
//   v0.x <- pos.x; v0.y <- pos.y; v0.z <- pos.z; 
//   v1.x <- iid; 
//   o0.x <- <vs return value>.x; o0.y <- <vs return value>.y; o0.z <- <vs return value>.z; o0.w <- <vs return value>.w
//
#line 32 "C:\dx-fixtures\sm51.hlsl"
0x00000078: itof r0.w, l(1)
0x0000008C: mov r1.x, l(7)
0x000000A0: and r1.x, r1.x, v1.x
0x000000BC: mov r0.xyz, v0.xyzx
0x000000D0: mul r0.xyzw, r0.xyzw, CB1[r1.x + 0][0].xyzw
0x000000F8: dp4 o0.x, r0.xyzw, CB0[2][0].xyzw
0x0000011C: dp4 o0.y, r0.xyzw, CB0[2][1].xyzw
0x00000140: dp4 o0.z, r0.xyzw, CB0[2][2].xyzw
0x00000164: dp4 o0.w, r0.xyzw, CB0[2][3].xyzw
0x00000188: ret 

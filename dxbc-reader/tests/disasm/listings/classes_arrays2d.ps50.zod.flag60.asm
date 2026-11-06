0x00000000: ps_5_0
0x00000008: dcl_globalFlags refactoringAllowed | skipOptimization
0x0000000C: dcl_constantbuffer CB0[1], immediateIndexed
0x0000001C: dcl_constantbuffer CB1[7], immediateIndexed
0x0000002C: dcl_sampler s0, mode_default
0x00000038: dcl_resource_texture2d (float,float,float,float) t2
0x00000048: dcl_function_body fb0
0x00000050: dcl_function_body fb1
0x00000058: dcl_function_body fb2
0x00000060: dcl_function_body fb3
0x00000068: dcl_function_body fb4
0x00000070: dcl_function_body fb5
0x00000078: dcl_function_body fb6
0x00000080: dcl_function_body fb7
0x00000088: dcl_function_table ft0 = {fb0, fb2}
0x0000009C: dcl_function_table ft1 = {fb1, fb3}
0x000000B0: dcl_function_table ft2 = {fb4, fb6}
0x000000C4: dcl_function_table ft3 = {fb5, fb7}
0x000000D8: dcl_interface_dynamicindexed fp0[6][2] = {ft0, ft1}
0x000000F0: dcl_interface_dynamicindexed fp6[2][2] = {ft2, ft3}
0x00000108: dcl_input_ps linear v0.xyz
0x00000114: dcl_input_ps linear v1.xyz
0x00000120: dcl_input_ps linear v2.xy
0x0000012C: dcl_output o0.xyzw
0x00000138: dcl_temps 7
//
// Initial variable locations:
//   v0.x <- n.x; v0.y <- n.y; v0.z <- n.z; 
//   v1.x <- p.x; v1.y <- p.y; v1.z <- p.z; 
//   v2.x <- uv.x; v2.y <- uv.y; 
//   o0.x <- <main return value>.x; o0.y <- <main return value>.y; o0.z <- <main return value>.z; o0.w <- <main return value>.w
//
#line 24 "C:\dx-fixtures\classes_arrays2d.hlsl"
0x00000140: itof r0.xyz, l(0, 0, 0, 0)  // r0.x <- acc.x; r0.y <- acc.y; r0.z <- acc.z

#line 25
0x00000160: mov r0.w, l(0)  // r0.w <- i
0x00000174: mov r1.xyz, r0.xyzx  // r1.x <- acc.x; r1.y <- acc.y; r1.z <- acc.z
0x00000188: mov r2.x, r0.w  // r2.x <- i
0x0000019C: loop 
0x000001A0:   ilt r2.y, r2.x, cb0[0].x
0x000001C0:   breakc_z r2.y
0x000001CC:   nop 
0x000001D0:   imul null, r2.y, r2.x, l(2)
0x000001F0:   mov r2.z, l(1)
0x00000204:   and r2.z, r2.z, cb0[0].y
0x00000224:   iadd r2.y, r2.z, r2.y
0x00000240:   mov r3.xyz, v0.xyzx
0x00000254:   mov r4.xyz, v1.xyzx
0x00000268:   fcall fp0[r2.y + 0][0]
0x00000280:   nop 
0x00000284:   imul null, r2.y, r2.x, l(2)
0x000002A4:   iadd r2.y, r2.y, l(1)
0x000002C0:   itof r2.z, r2.x
0x000002D4:   fcall fp0[r2.y + 0][1]
0x000002EC:   mul r2.yzw, r2.wwww, r5.xxyz
0x00000308:   add r1.xyz, r1.xyzx, r2.yzwy
0x00000324:   iadd r2.x, r2.x, l(1)
0x00000340: endloop 

#line 26
0x00000344: itof r1.w, l(1)
0x00000358: nop 
0x0000035C: mov r0.x, l(1)
0x00000370: and r0.x, r0.x, cb0[0].y
0x00000390: fcall fp6[r0.x + 0][0]
0x000003A8: mul r0.xyzw, r1.xyzw, r2.xyzw
0x000003C4: nop 
0x000003C8: itof r1.xy, l(2, 2, 0, 0)
0x000003E8: mul r1.xy, r1.xyxx, v2.xyxx
0x00000404: fcall fp6[0][1]
0x00000418: add o0.xyzw, r0.xyzw, r2.xyzw
0x00000434: ret   // r1.x <- acc.x; r1.y <- acc.y; r1.z <- acc.z; r2.x <- i

#line 15 "C:\dx-fixtures\classes_arrays2d.hlsl"
0x00000438: label fb0
0x00000444: nop 
0x00000448: mov r4.xyz, -r4.xyzx
0x00000460: mov r2.z, this[r2.y + 0].y
0x00000478: mov r2.w, this[r2.y + 0].x
0x00000490: add r4.xyz, r4.xyzx, cb[r2.w + 0][r2.z + 0].xyzx  // r4.x <- l.x; r4.y <- l.y; r4.z <- l.z
0x000004B8: dp3 r3.w, r4.xyzx, r4.xyzx
0x000004D4: rsq r3.w, r3.w
0x000004E8: mul r6.xyz, r3.wwww, r4.xyzx
0x00000504: dp3 r3.w, r3.xyzx, r6.xyzx
0x00000520: max r3.w, r3.w, l(0.000000)
0x0000053C: min r3.w, r3.w, l(1.000000)
0x00000558: mul r6.xyz, r3.wwww, cb[r2.w + 0][r2.z + 1].xyzx
0x00000584: nop 
0x00000588: dp3 r3.w, r4.xyzx, r4.xyzx
0x000005A4: sqrt r3.w, r3.w

#line 16
0x000005B8: itof r4.x, l(1)
0x000005CC: div r2.z, r3.w, cb[r2.w + 0][r2.z + 1].w
0x000005F8: mov r2.z, -r2.z
0x00000610: add r2.z, r2.z, r4.x
0x0000062C: max r2.z, r2.z, l(0.000000)
0x00000648: min r2.z, r2.z, l(1.000000)  // r2.z <- <Point::Atten return value>

#line 15
0x00000664: mul r5.xyz, r2.zzzz, r6.xyzx
0x00000680: ret 

#line 12 "C:\dx-fixtures\classes_arrays2d.hlsl"
0x00000684: label fb1
0x00000690: nop 
0x00000694: mov r2.z, this[r2.y + 0].y
0x000006AC: mov r2.y, this[r2.y + 0].x
0x000006C4: dp3 r2.w, r3.xyzx, cb[r2.y + 0][r2.z + 0].xyzx
0x000006EC: max r2.w, r2.w, l(0.000000)
0x00000708: min r2.w, r2.w, l(1.000000)
0x00000724: mul r5.xyz, r2.wwww, cb[r2.y + 0][r2.z + 1].xyzx
0x00000750: ret 

#line 16 "C:\dx-fixtures\classes_arrays2d.hlsl"
0x00000754: label fb2
0x00000760: nop 
0x00000764: itof r3.x, l(1)
0x00000778: mov r3.y, this[r2.y + 0].y
0x00000790: mov r3.z, this[r2.y + 0].x
0x000007A8: div r2.z, r2.z, cb[r3.z + 0][r3.y + 1].w
0x000007D4: mov r2.z, -r2.z
0x000007EC: add r2.z, r2.z, r3.x
0x00000808: max r2.z, r2.z, l(0.000000)
0x00000824: min r2.w, r2.z, l(1.000000)
0x00000840: ret 

#line 13 "C:\dx-fixtures\classes_arrays2d.hlsl"
0x00000844: label fb3
0x00000850: nop 
0x00000854: itof r2.w, l(1)
0x00000868: ret 

#line 18 "C:\dx-fixtures\classes_arrays2d.hlsl"
0x0000086C: label fb4
0x00000878: nop 
0x0000087C: mov r0.y, this[r0.x + 6].z
0x00000898: sample_indexable(texture2d)(float,float,float,float) r2.xyzw, v2.xyxx, t[r0.y + 0].xyzw, s0
0x000008C8: ret 

#line 17 "C:\dx-fixtures\classes_arrays2d.hlsl"
0x000008CC: label fb5  // r2.x <- i
0x000008D8: nop 
0x000008DC: mov r0.y, this[r0.x + 6].y
0x000008F8: mov r0.x, this[r0.x + 6].x
0x00000914: mov r2.xyzw, cb[r0.x + 0][r0.y + 0].xyzw
0x00000934: ret 

#line 18 "C:\dx-fixtures\classes_arrays2d.hlsl"
0x00000938: label fb6
0x00000944: nop   // this[6].x <- this.x; this[6].y <- this.y; this[6].z <- this.z; this[6].w <- this.w
0x00000948: mov r1.z, this[6].z
0x0000095C: sample_indexable(texture2d)(float,float,float,float) r2.xyzw, r1.xyxx, t[r1.z + 0].xyzw, s0
0x0000098C: ret 

#line 17 "C:\dx-fixtures\classes_arrays2d.hlsl"
0x00000990: label fb7  // r1.z <- acc.z
0x0000099C: nop   // this[6].x <- this.x; this[6].y <- this.y; this[6].z <- this.z; this[6].w <- this.w
0x000009A0: mov r1.x, this[6].y
0x000009B4: mov r1.y, this[6].x
0x000009C8: mov r2.xyzw, cb[r1.y + 0][r1.x + 0].xyzw
0x000009E8: ret 

0x00000000: ps_5_0
0x00000008: dcl_globalFlags refactoringAllowed | skipOptimization
0x0000000C: dcl_constantbuffer CB0[5], immediateIndexed
0x0000001C: dcl_sampler s0, mode_default
0x00000028: dcl_sampler s1, mode_default
0x00000034: dcl_sampler s2, mode_default
0x00000040: dcl_sampler s3, mode_default
0x0000004C: dcl_sampler s4, mode_default
0x00000058: dcl_resource_texture2d (float,float,float,float) t0
0x00000068: dcl_resource_texture2d (float,float,float,float) t1
0x00000078: dcl_resource_texture2d (float,float,float,float) t2
0x00000088: dcl_resource_texture2d (float,float,float,float) t3
0x00000098: dcl_resource_texture2d (float,float,float,float) t4
0x000000A8: dcl_function_body fb0
0x000000B0: dcl_function_body fb1
0x000000B8: dcl_function_body fb2
0x000000C0: dcl_function_body fb3
0x000000C8: dcl_function_table ft0 = {fb0}
0x000000D8: dcl_function_table ft1 = {fb1}
0x000000E8: dcl_function_table ft2 = {fb2}
0x000000F8: dcl_function_table ft3 = {fb3}
0x00000108: dcl_interface fp0[1][1] = {ft0, ft1, ft2, ft3}
0x00000128: dcl_input_ps linear v0.xyz
0x00000134: dcl_output o0.xyzw
0x00000140: dcl_temps 4
//
// Initial variable locations:
//   v0.x <- n.x; v0.y <- n.y; v0.z <- n.z; 
//   o0.x <- <main return value>.x; o0.y <- <main return value>.y; o0.z <- <main return value>.z; o0.w <- <main return value>.w
//
#line 17 "C:\dx-fixtures\classes_textures.hlsl"
0x00000148: nop 
0x0000014C: mov r0.xy, v0.xyxx
0x00000160: fcall fp0[0][0]
0x00000174: itof o0.w, l(1)
0x00000188: mov o0.xyz, r1.xyzx
0x0000019C: ret 

#line 10 "C:\dx-fixtures\classes_textures.hlsl"
0x000001A0: label fb0
0x000001AC: nop 
0x000001B0: mov r0.z, this[0].z
0x000001C4: mov r0.w, this[0].w
0x000001D8: sample_indexable(texture2d)(float,float,float,float) r2.xyz, v0.xyxx, t[r0.z + 0].xyzw, s[r0.w + 0]
0x0000020C: mov r0.z, this[0].y
0x00000220: mov r0.w, this[0].x
0x00000234: mul r1.xyz, r2.xyzx, cb[r0.w + 0][r0.z + 0].wwww
0x0000025C: ret 

#line 9 "C:\dx-fixtures\classes_textures.hlsl"
0x00000260: label fb1
0x0000026C: nop 
0x00000270: mov r0.z, this[0].z
0x00000284: mov r0.w, this[0].w
0x00000298: sample_indexable(texture2d)(float,float,float,float) r2.xyz, v0.xyxx, t[r0.z + 0].xyzw, s[r0.w + 0]
0x000002CC: mov r0.z, this[0].y
0x000002E0: mov r0.w, this[0].x
0x000002F4: mul r1.xyz, r2.xyzx, cb[r0.w + 0][r0.z + 0].yyyy
0x0000031C: ret 

#line 8 "C:\dx-fixtures\classes_textures.hlsl"
0x00000320: label fb2
0x0000032C: nop 
0x00000330: mov r0.z, this[0].z
0x00000344: mov r0.w, this[0].w
0x00000358: sample_indexable(texture2d)(float,float,float,float) r2.xyz, v0.xyxx, t[r0.z + 0].xyzw, s[r0.w + 0]
0x0000038C: sample_indexable(texture2d)(float,float,float,float) r3.xyz, v0.yzyy, t[r0.z + 0].xyzw, s[r0.w + 1]
0x000003C4: mov r0.z, this[0].y
0x000003D8: mov r0.w, this[0].x
0x000003EC: mul r3.xyz, r3.xyzx, cb[r0.w + 0][r0.z + 0].xxxx
0x00000414: add r1.xyz, r2.xyzx, r3.xyzx
0x00000430: ret 

#line 7 "C:\dx-fixtures\classes_textures.hlsl"
0x00000434: label fb3
0x00000440: nop 
0x00000444: ftoi r0.xy, r0.xyxx
0x00000458: mov r0.zw, l(0,0,0,0)
0x00000478: mov r1.w, this[0].z
0x0000048C: ld_indexable(texture2d)(float,float,float,float) r0.xyz, r0.xyzw, t[r1.w + 0].xyzw
0x000004B4: mov r0.w, this[0].y
0x000004C8: mov r1.w, this[0].x
0x000004DC: mul r1.xyz, r0.xyzx, cb[r1.w + 0][r0.w + 0].xyzx
0x00000504: ret 

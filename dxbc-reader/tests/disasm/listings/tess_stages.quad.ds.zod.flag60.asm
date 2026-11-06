0x00000000: ds_5_0
0x00000008: dcl_input_control_point_count 4
0x0000000C: dcl_tessellator_domain domain_quad
0x00000010: dcl_globalFlags refactoringAllowed | skipOptimization
0x00000014: dcl_constantbuffer CB0[5], immediateIndexed
0x00000024: dcl_input_siv vpc4.x, finalQuadUInsideTessFactor
0x00000034: dcl_input_siv vpc5.x, finalQuadVInsideTessFactor
0x00000044: dcl_input vDomain.xy
0x0000004C: dcl_input vPrim
0x00000054: dcl_input vicp[4][0].xyzw
0x00000064: dcl_input vicp[4][1].xyz
0x00000074: dcl_output_siv o0.xyzw, position
0x00000084: dcl_output o1.xyz
0x00000090: dcl_temps 3
//
// Initial variable locations:
//   vpc0.x <- pc.e[0]; 
//   vpc1.x <- pc.e[1]; 
//   vpc2.x <- pc.e[2]; 
//   vpc3.x <- pc.e[3]; 
//   vpc4.x <- pc.i[0]; 
//   vpc5.x <- pc.i[1]; 
//   vDomain.x <- uv.x; vDomain.y <- uv.y; 
//   vPrim.x <- id; 
//   o1.x <- <ds_quad return value>.n.x; o1.y <- <ds_quad return value>.n.y; o1.z <- <ds_quad return value>.n.z; 
//   o0.x <- <ds_quad return value>.pos.x; o0.y <- <ds_quad return value>.pos.y; o0.z <- <ds_quad return value>.pos.z; o0.w <- <ds_quad return value>.pos.w; 
//   vicp[0][0].x <- patch[0].p.x; vicp[0][0].y <- patch[0].p.y; vicp[0][0].z <- patch[0].p.z; vicp[0][0].w <- patch[0].p.w; 
//   vicp[0][1].x <- patch[0].n.x; vicp[0][1].y <- patch[0].n.y; vicp[0][1].z <- patch[0].n.z; 
//   vicp[1][0].x <- patch[1].p.x; vicp[1][0].y <- patch[1].p.y; vicp[1][0].z <- patch[1].p.z; vicp[1][0].w <- patch[1].p.w; 
//   vicp[1][1].x <- patch[1].n.x; vicp[1][1].y <- patch[1].n.y; vicp[1][1].z <- patch[1].n.z; 
//   vicp[2][0].x <- patch[2].p.x; vicp[2][0].y <- patch[2].p.y; vicp[2][0].z <- patch[2].p.z; vicp[2][0].w <- patch[2].p.w; 
//   vicp[2][1].x <- patch[2].n.x; vicp[2][1].y <- patch[2].n.y; vicp[2][1].z <- patch[2].n.z; 
//   vicp[3][0].x <- patch[3].p.x; vicp[3][0].y <- patch[3].p.y; vicp[3][0].z <- patch[3].p.z; vicp[3][0].w <- patch[3].p.w; 
//   vicp[3][1].x <- patch[3].n.x; vicp[3][1].y <- patch[3].n.y; vicp[3][1].z <- patch[3].n.z
//
#line 95 "C:\dx-fixtures\tess_stages.hlsl"
0x00000098: mov r0.xyzw, -vicp[0][0].xyzw
0x000000B4: add r0.xyzw, r0.xyzw, vicp[1][0].xyzw
0x000000D4: mul r0.xyzw, r0.xyzw, vDomain.xxxx
0x000000EC: add r0.xyzw, r0.xyzw, vicp[0][0].xyzw  // r0.x <- a.x; r0.y <- a.y; r0.z <- a.z; r0.w <- a.w
0x0000010C: mov r1.xyzw, -vicp[3][0].xyzw
0x00000128: add r1.xyzw, r1.xyzw, vicp[2][0].xyzw
0x00000148: mul r1.xyzw, r1.xyzw, vDomain.xxxx
0x00000160: add r1.xyzw, r1.xyzw, vicp[3][0].xyzw  // r1.x <- b.x; r1.y <- b.y; r1.z <- b.z; r1.w <- b.w

#line 97
0x00000180: mov r2.xyzw, -r0.xyzw
0x00000198: add r1.xyzw, r1.xyzw, r2.xyzw
0x000001B4: mul r1.xyzw, r1.xyzw, vDomain.yyyy
0x000001CC: add r0.xyzw, r0.xyzw, r1.xyzw
0x000001E8: mov r1.x, l(1)
0x000001FC: and r1.x, r1.x, vPrim
0x00000214: utof r1.x, r1.x
0x00000228: mov r1.y, -vpc4.x
0x00000240: add r1.y, r1.y, vpc5.x
0x0000025C: mul r1.x, r1.y, r1.x
0x00000278: add r1.x, r1.x, vpc4.x
0x00000294: mul r0.xyzw, r0.xyzw, r1.xxxx
0x000002B0: dp4 r1.x, r0.xyzw, cb0[1].xyzw  // r1.x <- o.pos.x
0x000002D0: dp4 r1.y, r0.xyzw, cb0[2].xyzw  // r1.y <- o.pos.y
0x000002F0: dp4 r1.z, r0.xyzw, cb0[3].xyzw  // r1.z <- o.pos.z
0x00000310: dp4 r1.w, r0.xyzw, cb0[4].xyzw  // r1.w <- o.pos.w

#line 98
0x00000330: mov r0.x, l(1)
0x00000344: and r0.x, r0.x, vPrim
0x0000035C: utof r0.x, r0.x
0x00000370: mov r0.yzw, -vicp[1][1].xxyz
0x0000038C: add r0.yzw, r0.yyzw, vicp[3][1].xxyz
0x000003AC: mul r0.xyz, r0.yzwy, r0.xxxx
0x000003C8: add r0.xyz, r0.xyzx, vicp[1][1].xyzx  // r0.x <- o.n.x; r0.y <- o.n.y; r0.z <- o.n.z

#line 99
0x000003E8: mov o0.xyzw, r1.xyzw
0x000003FC: mov o1.xyz, r0.xyzx
0x00000410: ret 

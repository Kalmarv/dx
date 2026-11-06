ds_5_0
dcl_input_control_point_count 3
dcl_tessellator_domain domain_tri
dcl_globalFlags refactoringAllowed
dcl_constantbuffer CB0[5], immediateIndexed
dcl_input vpc0.yzw
dcl_input_siv vpc1.x, finalTriVeq0EdgeTessFactor
dcl_input_siv vpc3.x, finalTriInsideTessFactor
dcl_input vDomain.xyz
dcl_input vicp[3][0].xyzw
dcl_input vicp[3][1].xyz
dcl_output_siv o0.xyzw, position
dcl_output o1.xyz
dcl_temps 2
//
// Initial variable locations:
//   vpc3.x <- pc.i; 
//   vpc0.y <- pc.b.x; vpc0.z <- pc.b.y; vpc0.w <- pc.b.z; vpc0.x <- pc.e[0]; 
//   vpc1.x <- pc.e[1]; 
//   vpc2.x <- pc.e[2]; 
//   vDomain.x <- uvw.x; vDomain.y <- uvw.y; vDomain.z <- uvw.z; 
//   o1.x <- <ds_tri return value>.n.x; o1.y <- <ds_tri return value>.n.y; o1.z <- <ds_tri return value>.n.z; 
//   o0.x <- <ds_tri return value>.pos.x; o0.y <- <ds_tri return value>.pos.y; o0.z <- <ds_tri return value>.pos.z; o0.w <- <ds_tri return value>.pos.w; 
//   vicp[0][0].x <- patch[0].p.x; vicp[0][0].y <- patch[0].p.y; vicp[0][0].z <- patch[0].p.z; vicp[0][0].w <- patch[0].p.w; 
//   vicp[0][1].x <- patch[0].n.x; vicp[0][1].y <- patch[0].n.y; vicp[0][1].z <- patch[0].n.z; 
//   vicp[1][0].x <- patch[1].p.x; vicp[1][0].y <- patch[1].p.y; vicp[1][0].z <- patch[1].p.z; vicp[1][0].w <- patch[1].p.w; 
//   vicp[1][1].x <- patch[1].n.x; vicp[1][1].y <- patch[1].n.y; vicp[1][1].z <- patch[1].n.z; 
//   vicp[2][0].x <- patch[2].p.x; vicp[2][0].y <- patch[2].p.y; vicp[2][0].z <- patch[2].p.z; vicp[2][0].w <- patch[2].p.w; 
//   vicp[2][1].x <- patch[2].n.x; vicp[2][1].y <- patch[2].n.y; vicp[2][1].z <- patch[2].n.z
//
#line 87 "C:\dx-fixtures\tess_stages.hlsl"
mul r0.xyzw, vDomain.yyyy, vicp[1][0].xyzw
mad r0.xyzw, vicp[0][0].xyzw, vDomain.xxxx, r0.xyzw
mad r0.xyzw, vicp[2][0].xyzw, vDomain.zzzz, r0.xyzw  // r0.x <- p.x; r0.y <- p.y; r0.z <- p.z; r0.w <- p.w

#line 88
mov r1.xyz, vpc0.yzwy
mov r1.w, l(0x00000000)
mad r0.xyzw, r1.xyzw, vpc1.xxxx, r0.xyzw
dp4 o0.x, r0.xyzw, cb0[1].xyzw
dp4 o0.y, r0.xyzw, cb0[2].xyzw
dp4 o0.z, r0.xyzw, cb0[3].xyzw
dp4 o0.w, r0.xyzw, cb0[4].xyzw

#line 89
mul r0.xyz, vDomain.yyyy, vicp[1][1].xyzx
mad r0.xyz, vicp[0][1].xyzx, vDomain.xxxx, r0.xyzx
mad r0.xyz, vicp[2][1].xyzx, vDomain.zzzz, r0.xyzx
dp3 r0.w, r0.xyzx, r0.xyzx
rsq r0.w, r0.w
mul r0.xyz, r0.wwww, r0.xyzx
mul o1.xyz, r0.xyzx, vpc3.xxxx

#line 90
ret 

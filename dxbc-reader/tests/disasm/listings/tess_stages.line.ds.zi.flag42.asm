ds_5_0
dcl_input_control_point_count 2
dcl_tessellator_domain domain_isoline
dcl_globalFlags refactoringAllowed
dcl_input_siv vpc0.x, finalLineDensityTessFactor
dcl_input vDomain.x
dcl_input vicp[2][0].xyzw
dcl_input vicp[2][1].xyz
dcl_output_siv o0.xyzw, position
dcl_output o1.xyz
dcl_temps 1
//
// Initial variable locations:
//   vpc0.x <- pc.e[0]; 
//   vpc1.x <- pc.e[1]; 
//   vDomain.x <- uv.x; vDomain.y <- uv.y; 
//   o1.x <- <ds_line return value>.n.x; o1.y <- <ds_line return value>.n.y; o1.z <- <ds_line return value>.n.z; 
//   o0.x <- <ds_line return value>.pos.x; o0.y <- <ds_line return value>.pos.y; o0.z <- <ds_line return value>.pos.z; o0.w <- <ds_line return value>.pos.w; 
//   vicp[0][0].x <- patch[0].p.x; vicp[0][0].y <- patch[0].p.y; vicp[0][0].z <- patch[0].p.z; vicp[0][0].w <- patch[0].p.w; 
//   vicp[0][1].x <- patch[0].n.x; vicp[0][1].y <- patch[0].n.y; vicp[0][1].z <- patch[0].n.z; 
//   vicp[1][0].x <- patch[1].p.x; vicp[1][0].y <- patch[1].p.y; vicp[1][0].z <- patch[1].p.z; vicp[1][0].w <- patch[1].p.w; 
//   vicp[1][1].x <- patch[1].n.x; vicp[1][1].y <- patch[1].n.y; vicp[1][1].z <- patch[1].n.z
//
#line 104 "C:\dx-fixtures\tess_stages.hlsl"
add r0.xyzw, -vicp[0][0].xyzw, vicp[1][0].xyzw
mad r0.xyzw, vDomain.xxxx, r0.xyzw, vicp[0][0].xyzw
mul o0.xyzw, r0.xyzw, vpc0.xxxx

#line 106
mov o1.xyz, vicp[0][1].xyzx
ret 

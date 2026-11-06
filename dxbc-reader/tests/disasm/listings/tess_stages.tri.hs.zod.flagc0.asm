hs_5_0
hs_decls 
dcl_input_control_point_count 3
dcl_output_control_point_count 3
dcl_tessellator_domain domain_tri
dcl_tessellator_partitioning partitioning_fractional_odd
dcl_tessellator_output_primitive output_triangle_cw
dcl_hs_max_tessfactor l(15.000000)
dcl_globalFlags refactoringAllowed | skipOptimization
dcl_constantbuffer CB0[1], immediateIndexed
hs_control_point_phase 
dcl_input vOutputControlPointID
dcl_input v[3][0].xyzw
dcl_input v[3][1].xyz
dcl_output o0.xyzw
dcl_output o1.xyz
dcl_temps 3
//
// Initial variable locations:
//   vOutputControlPointID.x <- i; 
//   o1.x <- <hs_tri return value>.n.x; o1.y <- <hs_tri return value>.n.y; o1.z <- <hs_tri return value>.n.z; 
//   o0.x <- <hs_tri return value>.p.x; o0.y <- <hs_tri return value>.p.y; o0.z <- <hs_tri return value>.p.z; o0.w <- <hs_tri return value>.p.w; 
//   v[0][0].x <- patch[0].p.x; v[0][0].y <- patch[0].p.y; v[0][0].z <- patch[0].p.z; v[0][0].w <- patch[0].p.w; 
//   v[0][1].x <- patch[0].n.x; v[0][1].y <- patch[0].n.y; v[0][1].z <- patch[0].n.z; 
//   v[1][0].x <- patch[1].p.x; v[1][0].y <- patch[1].p.y; v[1][0].z <- patch[1].p.z; v[1][0].w <- patch[1].p.w; 
//   v[1][1].x <- patch[1].n.x; v[1][1].y <- patch[1].n.y; v[1][1].z <- patch[1].n.z; 
//   v[2][0].x <- patch[2].p.x; v[2][0].y <- patch[2].p.y; v[2][0].z <- patch[2].p.z; v[2][0].w <- patch[2].p.w; 
//   v[2][1].x <- patch[2].n.x; v[2][1].y <- patch[2].n.y; v[2][1].z <- patch[2].n.z
//
#line 41 "C:\dx-fixtures\tess_stages.hlsl"
mov r0.x, vOutputControlPointID
mov r0.yzw, v[r0.x + 0][0].xxyz  // r0.y <- o.p.x; r0.z <- o.p.y; r0.w <- o.p.z
mov r1.x, v[r0.x + 0][0].w  // r1.x <- o.p.w
mov r1.yzw, v[r0.x + 0][1].xxyz  // r1.y <- o.n.x; r1.z <- o.n.y; r1.w <- o.n.z

#line 42
mul r2.xyz, r1.yzwy, cb0[0].xxxx
add r0.xyz, r0.yzwy, r2.xyzx  // r0.x <- o.p.x; r0.y <- o.p.y; r0.z <- o.p.z

#line 43
mov o0.xyz, r0.xyzx
mov o0.w, r1.x
mov o1.xyz, r1.yzwy
ret 
hs_join_phase 
dcl_input vPrim
dcl_input vicp[3][0].xyzw
dcl_input vocp[3][0].xyzw
dcl_output_siv o0.x, finalTriUeq0EdgeTessFactor
dcl_output o0.yzw
dcl_output_siv o1.x, finalTriVeq0EdgeTessFactor
dcl_output_siv o2.x, finalTriWeq0EdgeTessFactor
dcl_output_siv o3.x, finalTriInsideTessFactor
dcl_temps 3

#line 33
mov r0.xyzw, -vicp[1][0].xyzw
add r0.xyzw, r0.xyzw, vocp[0][0].xyzw
dp4 r0.x, r0.xyzw, r0.xyzw
sqrt r0.x, r0.x
mul r0.x, r0.x, cb0[0].x  // r0.x <- o.e[0]
mov r1.xyzw, -vicp[2][0].xyzw
add r1.xyzw, r1.xyzw, vocp[1][0].xyzw
dp4 r1.x, r1.xyzw, r1.xyzw
sqrt r1.x, r1.x
mul r0.y, r1.x, cb0[0].y  // r0.y <- o.e[1]
mov r1.xyzw, -vicp[0][0].xyzw
add r1.xyzw, r1.xyzw, vocp[2][0].xyzw
dp4 r1.x, r1.xyzw, r1.xyzw
sqrt r1.x, r1.x
mul r0.z, r1.x, cb0[0].z  // r0.z <- o.e[2]

#line 34
utof r1.x, vPrim
add r0.w, r1.x, cb0[0].w  // r0.w <- o.i

#line 35
add r1.xyz, vicp[1][0].xyzx, vicp[0][0].xyzx
add r1.xyz, r1.xyzx, vicp[2][0].xyzx
itof r2.xyz, l(0x00000003, 0x00000003, 0x00000003, 0x00000000)
div r1.xyz, r1.xyzx, r2.xyzx  // r1.x <- o.b.x; r1.y <- o.b.y; r1.z <- o.b.z

#line 36
mov r0.x, r0.x  // r0.x <- <tri_pc return value>.e[0]
mov r0.y, r0.y  // r0.y <- <tri_pc return value>.e[1]
mov r0.z, r0.z  // r0.z <- <tri_pc return value>.e[2]
mov r0.w, r0.w  // r0.w <- <tri_pc return value>.i
mov o0.yzw, r1.xxyz
min r0.xyzw, r0.xyzw, l(0x41700000, 0x41700000, 0x41700000, 0x41700000)
mov o0.x, r0.x
mov o1.x, r0.y
mov o2.x, r0.z
mov o3.x, r0.w
ret 

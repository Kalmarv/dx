ds_5_0
dcl_input_control_point_count 2
dcl_tessellator_domain domain_isoline
dcl_globalFlags refactoringAllowed | skipOptimization
dcl_input_siv vpc0.x, finalLineDensityTessFactor
dcl_input vDomain.x
dcl_input vicp[2][0].xyzw
dcl_input vicp[2][1].xyz
dcl_output_siv o0.xyzw, position
dcl_output o1.xyz
dcl_temps 2
mov r0.xyzw, -vicp[0][0].xyzw
add r0.xyzw, r0.xyzw, vicp[1][0].xyzw
mul r0.xyzw, r0.xyzw, vDomain.xxxx
add r0.xyzw, r0.xyzw, vicp[0][0].xyzw
mul r0.xyzw, r0.xyzw, vpc0.xxxx
mov r1.xyz, vicp[0][1].xyzx
mov o0.xyzw, r0.xyzw
mov o1.xyz, r1.xyzx
ret 

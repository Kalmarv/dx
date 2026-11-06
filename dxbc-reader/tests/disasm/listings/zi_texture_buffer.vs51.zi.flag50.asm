vs_5_1
dcl_globalFlags refactoringAllowed
dcl_resource_buffer (mixed,mixed,mixed,mixed) T0[1:1], space=0
dcl_resource_buffer (mixed,mixed,mixed,mixed) T1[2:4], space=0
dcl_output o0.x
dcl_temps 1
ld r0.xy, l(0, 0, 0, 0), T0[1].xyzw
ld r0.z, l(5, 5, 5, 5), T0[1].yzxw
add r0.x, r0.y, r0.x
ld r0.y, l(3, 3, 3, 3), T0[1].xyzw
add r0.x, r0.y, r0.x
add r0.x, r0.z, r0.x
ld r0.y, l(9, 9, 9, 9), T0[1].yxzw
add r0.x, r0.y, r0.x
ld r0.y, l(0, 0, 0, 0), T1[4].yxzw
add r0.x, r0.y, r0.x
ld r0.y, l(0, 0, 0, 0), T1[3].xyzw
add r0.x, r0.y, r0.x
ld r0.y, l(3, 3, 3, 3), T1[2].xyzw
add r0.x, r0.y, r0.x
ld r0.y, l(5, 5, 5, 5), T1[3].yxzw
add r0.x, r0.y, r0.x
ld r0.y, l(9, 9, 9, 9), T1[2].yxzw
add o0.x, r0.y, r0.x
ret 

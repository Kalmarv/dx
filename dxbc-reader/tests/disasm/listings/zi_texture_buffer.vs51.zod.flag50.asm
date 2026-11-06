vs_5_1
dcl_globalFlags refactoringAllowed | skipOptimization
dcl_resource_buffer (mixed,mixed,mixed,mixed) T0[1:1], space=0
dcl_resource_buffer (mixed,mixed,mixed,mixed) T1[2:4], space=0
dcl_output o0.x
dcl_temps 1
ld r0.xy, l(0, 0, 0, 0), T0[1].xyzw
ld r0.z, l(5, 5, 5, 5), T0[1].yzxw
add r0.x, r0.y, r0.x
mov r0.y, l(2)
iadd r0.y, r0.y, l(1)
ld r0.y, r0.yyyy, T0[1].xyzw
add r0.x, r0.y, r0.x
add r0.x, r0.z, r0.x
mov r0.y, l(3)
iadd r0.y, r0.y, l(6)
ld r0.y, r0.yyyy, T0[1].yxzw
add r0.x, r0.y, r0.x
mov r0.y, l(2)
ld r0.y, l(0, 0, 0, 0), T1[r0.y + 2].yxzw
add r0.x, r0.y, r0.x
mov r0.y, l(1)
ld r0.y, l(0, 0, 0, 0), T1[r0.y + 2].xyzw
add r0.x, r0.y, r0.x
mov r0.y, l(0)
mov r0.z, l(2)
iadd r0.z, r0.z, l(1)
ld r0.y, r0.zzzz, T1[r0.y + 2].xyzw
add r0.x, r0.y, r0.x
mov r0.y, l(1)
ld r0.y, l(5, 5, 5, 5), T1[r0.y + 2].yxzw
add r0.x, r0.y, r0.x
mov r0.y, l(0)
mov r0.z, l(3)
iadd r0.z, r0.z, l(6)
ld r0.y, r0.zzzz, T1[r0.y + 2].yxzw
add o0.x, r0.y, r0.x
ret 

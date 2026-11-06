ps_2_0
dcl t0
mov r9, c1
exp r0, c0.x
log r1, c0.x
rcp r2, c0.x
rsq r3, c0.x
frc r4, c0
min r5, c0, r9
max r6, c0, r9
add r0, r0, r1
add r0, r0, r2
add r0, r0, r3
add r0, r0, r4
add r0, r0, r5
add r0, r0, r6
mov oC0, r0

ps_2_x
mov r1, c1
setp_gt p0, c0, r1
mov r0, c2
if !p0.y
mov r0, c3
endif
mov oC0, r0

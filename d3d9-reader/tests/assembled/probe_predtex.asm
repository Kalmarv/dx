ps_2_x
dcl t0
dcl_2d s0
mov r1, c1
setp_gt p0, c0, r1
mov r0, c2
(p0.y) add r0, r0, c3
(!p0) texld r1, t0, s0
mov oC0, r0

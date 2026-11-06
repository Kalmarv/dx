; ps_2_0 exp (2^x) and log (log2 |x|), each of a scalar replicated
; run: c0=3,8,-0.5,-8 -> SV_Target0=8,8,8,8 SV_Target1=3,3,3,3
ps_2_0
mov r0, c0
exp r1, r0.x
log r2, r0.w
mov oC0, r1
mov oC1, r2

; ps_2_0 dp2add: x*x' + y*y' + the replicated scalar, in every lane
; run: c0=1,2,9,9 c1=3,4,9,9 c2=0.5,0,0,0 -> SV_Target0=11.5,11.5,11.5,11.5
ps_2_0
mov r1, c0
mov r2, c1
dp2add r0, r1, r2, c2.x
mov oC0, r0

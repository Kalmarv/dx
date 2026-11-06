; ps_3_0 _abs source modifier, and its negation
; run: c0=1,1,1,1 c1=-1,2,-3,-0 -> SV_Target0=2,3,4,1 SV_Target1=0,-1,-2,1
ps_3_0
mov r1, c1
add r0, r1_abs, c0
add r2, -r1_abs, c0
mov oC0, r0
mov oC1, r2

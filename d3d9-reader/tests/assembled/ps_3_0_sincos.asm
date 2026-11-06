; ps_3_0 sincos (no constant operands from 3.0): cos in x, sin in y
; run: c0=0,0,0,0 c1=0,0,0.5,1 -> SV_Target0=1,0,0.5,1
ps_3_0
mov r1, c0
sincos r0.xy, r1.x
mov r0.zw, c1
mov oC0, r0

; ps_2_0 _pp: partial precision is a hint, computed at full precision
; run: c0=0.1,3,8,-0.5 c1=3,0.1,0.125,2 -> SV_Target0=0x3e99999a,0x3e99999a,1,-1
ps_2_0
mov r0, c0
mul_pp r1, r0, c1
mov oC0, r1

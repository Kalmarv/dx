; ps_1_1 cnd: src1 where r0.a > 0.5, else src2, for every lane
; run: c0=0,0,0,0.75 COLOR0=1,0.5,0.25,0 COLOR1=0,0.25,0.5,1 -> SV_Target0=1,0.5,0.25,0
; run: c0=0,0,0,0.5 COLOR0=1,0.5,0.25,0 COLOR1=0,0.25,0.5,1 -> SV_Target0=0,0.25,0.5,1
ps_1_1
mov r0, c0
cnd r0, r0.a, v0, v1

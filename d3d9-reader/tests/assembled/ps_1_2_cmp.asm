; ps_1_2 cmp: per lane, src1 where src0 >= 0, else src2 (-0 counts as >= 0)
; run: c0=1,-1,0,-0 COLOR0=1,0.5,0.25,0.75 COLOR1=0,0.125,0.5,1 -> SV_Target0=1,0.125,0.25,0.75
ps_1_2
mov r1, c0
cmp r0, r1, v0, v1

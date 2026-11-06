; ps_2_0 cmp: per lane, src1 where src0 >= 0, else src2 (-0 counts as >= 0, NaN does not)
; run: c0=1,-1,-0,nan c1=1,2,3,4 c2=5,6,7,8 -> SV_Target0=1,6,3,8
ps_2_0
mov r0, c0
mov r1, c1
cmp r2, r0, r1, c2
mov oC0, r2

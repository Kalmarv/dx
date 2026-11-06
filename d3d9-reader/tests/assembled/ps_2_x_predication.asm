; ps_2_x setp per lane and a predicated write, negated
; run: c0=1,5,3,0 c1=2,2,2,2 c2=7,7,7,7 c3=9,9,9,9 -> SV_Target0=9,7,7,9
ps_2_x
mov r1, c1
mov r3, c0
setp_gt p0, r3, r1
mov r0, c2
(!p0) mov r0, c3
mov oC0, r0

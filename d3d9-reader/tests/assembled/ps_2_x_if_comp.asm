; ps_2_x if_gt with else, on the first lanes of two temporaries
; run: c0=2,0,0,0 c1=1,0,0,0 c2=1,2,3,4 c3=5,6,7,8 -> SV_Target0=1,2,3,4
; run: c0=1,0,0,0 c1=1,0,0,0 c2=1,2,3,4 c3=5,6,7,8 -> SV_Target0=5,6,7,8
ps_2_x
mov r0, c0
mov r1, c1
if_gt r0.x, r1.x
mov r2, c2
else
mov r2, c3
endif
mov oC0, r2

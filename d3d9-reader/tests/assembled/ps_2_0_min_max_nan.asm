; ps_2_0 min and max with one NaN operand give the other operand (minNum/maxNum, as D3D10 and later hardware)
; run: c0=nan,1,nan,-2 c1=1,nan,-3,nan -> SV_Target0=1,1,-3,-2 SV_Target1=1,1,-3,-2
ps_2_0
mov r0, c0
min r1, r0, c1
max r2, r0, c1
mov oC0, r1
mov oC1, r2

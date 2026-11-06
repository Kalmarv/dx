; ps_1_1 result shifts: _x2 then _d2 (a multiply by 2 and by 0.5)
; run: c0=1,0.5,-1,0.25 COLOR0=1,1,0.5,1 -> SV_Target0=1,0.25,0.5,0.0625
ps_1_1
mul_x2 r1, c0, v0
mul_d2 r0, r1, c0

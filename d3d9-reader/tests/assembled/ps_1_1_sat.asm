; ps_1_1 _x4_sat: the shift, then the clamp to 0..1
; run: c0=1,0.125,-1,0.25 COLOR0=1,1,0.5,1 -> SV_Target0=1,0.5,0,1
ps_1_1
mul_x4_sat r0, c0, v0

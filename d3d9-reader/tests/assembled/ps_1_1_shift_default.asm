; ps_1_1 _x4 under the default policy: the result is not clamped
; run: c0=1,-1,0.5,0.75 COLOR0=1,0,0.25,0 -> SV_Target0=8,-4,3,3
ps_1_1
add_x4 r0, c0, v0

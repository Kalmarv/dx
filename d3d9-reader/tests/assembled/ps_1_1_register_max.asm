; ps_1_1 with the register range policy: each r# write clamped to -2..2 (the default has no clamp)
; lift: register_max=2
; run: c0=1,-1,0.5,0.75 COLOR0=1,0,0.25,0 -> SV_Target0=2,-2,2,2
ps_1_1
add_x4 r0, c0, v0

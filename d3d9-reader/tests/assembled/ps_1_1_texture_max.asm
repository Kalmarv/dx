; ps_1_1 with the texture register range policy: a t# written as a temporary clamped to -1..1
; lift: texture_max=1
; run: c0=1,-1,0.5,0.25 COLOR0=1,0,0.25,0 -> SV_Target0=1,-1,1,0.5
ps_1_1
add_x2 t0, c0, v0
mov r0, t0

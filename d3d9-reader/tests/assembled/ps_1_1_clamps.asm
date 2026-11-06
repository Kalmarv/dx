; ps_1_1 reads under the default policy: c# within -1..1 and v# within 0..1; a register write is not clamped
; run: c0=2,-3,0.5,-0.25 COLOR0=1.5,-0.5,0.25,1 -> SV_Target0=2,-1,0.75,0.75
ps_1_1
add r0, c0, v0

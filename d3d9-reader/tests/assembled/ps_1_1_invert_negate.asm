; ps_1_1 source modifiers - (negate) and 1- (complement)
; run: c0=0.75,0.25,0.5,1 COLOR0=0.25,1,0,0.5 -> SV_Target0=0,-0.25,0.5,-0.5
ps_1_1
mov r1, c0
add r0, -r1, 1-v0

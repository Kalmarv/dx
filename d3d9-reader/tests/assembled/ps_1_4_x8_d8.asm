; ps_1_4 result shifts _x8 and _d8
; run: c0=0.5,0.25,-0.125,1 c1=0.25,1,1,0.125 -> SV_Target0=1.015625,2.03125,-1.015625,1.015625
ps_1_4
mov r1, c1
mul_x8 r2, c0, r1
mul_d8 r3, c0, r1
add r0, r2, r3

; ps_2_0 abs and frc
; run: c0=-1.5,2.25,-0,-0.25 -> SV_Target0=1.5,2.25,0,0.25 SV_Target1=0.5,0.25,0,0.75
ps_2_0
mov r0, c0
abs r1, r0
frc r2, r0
mov oC0, r1
mov oC1, r2

; vs_1_1 min, max and frc: frc is x - floor(x), in 0..1 for negative x too
; run: c0=1.25,-1.25,3,-2 c1=2,-2,1,1 -> TEXCOORD0=1.25,-2,1,-2 TEXCOORD1=2,-1.25,3,1 TEXCOORD2=0.25,0.75
vs_1_1
dcl_position v0
mov oPos, v0
mov r1, c1
min oT0, c0, r1
max oT1, c0, r1
frc r0.xy, c0
mov oT2.xy, r0

; vs_2_0 if b#, else and endif
; run: b3=true c0=1,1,1,1 c1=2,2,2,2 -> TEXCOORD0=1,1,1,1
; run: b3=false c0=1,1,1,1 c1=2,2,2,2 -> TEXCOORD0=2,2,2,2
vs_2_0
dcl_position v0
mov oPos, v0
if b3
mov r0, c0
else
mov r0, c1
endif
mov oT0, r0

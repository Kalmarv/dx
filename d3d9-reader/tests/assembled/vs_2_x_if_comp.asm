; vs_2_x if_lt: a comparison of two lanes decides the branch
; run: c0=1,0,0,0 c1=2,0,0,0 c2=5,5,5,5 c3=6,6,6,6 -> TEXCOORD0=5
; run: c0=3,0,0,0 c1=2,0,0,0 c2=5,5,5,5 c3=6,6,6,6 -> TEXCOORD0=6
vs_2_x
dcl_position v0
mov oPos, v0
mov r1, c1
mov r0, c3
if_lt c0.x, r1.x
mov r0, c2
endif
mov oT0.x, r0.x

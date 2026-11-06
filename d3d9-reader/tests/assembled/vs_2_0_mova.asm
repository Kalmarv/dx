; vs_2_0 mova: a0 from the nearest integer of each lane, a constant read relative to a0.y
; run: c0=0,1.7,0,0 c2=5,6,7,8 c3=1,2,3,4 -> TEXCOORD0=5,6,7,8
; run: c0=0,2.7,0,0 c2=5,6,7,8 c3=1,2,3,4 -> TEXCOORD0=1,2,3,4
; run: c0=0,2.2,0,0 c2=5,6,7,8 c3=1,2,3,4 -> TEXCOORD0=5,6,7,8
vs_2_0
dcl_position v0
mov oPos, v0
mova a0.y, c0.y
mov oT0, c[a0.y]

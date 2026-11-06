; vs_1_1 mad: a declared input times a temporary plus a constant, to the clip position
; run: POSITION0=1,2,3,4 c0=2,2,2,2 c1=1,0.5,0,-1 -> POSITION0=3,4.5,6,7
vs_1_1
dcl_position v0
mov r0, c0
mad oPos, v0, r0, c1

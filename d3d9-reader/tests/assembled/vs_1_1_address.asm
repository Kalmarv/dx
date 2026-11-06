; vs_1_1 relative addressing: a0.x from a mov of an integer, a constant read at c[a0.x + 2]
; run: c0=1,0,0,0 c3=5,6,7,8 -> TEXCOORD0=5,6,7,8
vs_1_1
dcl_position v0
mov oPos, v0
mov a0.x, c0.x
mov oT0, c[a0.x + 2]

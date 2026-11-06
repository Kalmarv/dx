; vs_1_1 m3x2: two lanes, each a dp3 of the source with the next constant register
; run: c4=1,2,3,9 c0=1,0,0,9 c1=0,1,1,9 -> TEXCOORD0=1,5
vs_1_1
dcl_position v0
mov oPos, v0
mov r0, c4
m3x2 oT0.xy, r0, c0

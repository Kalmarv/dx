; vs_1_1 dp3 and dp4 into the lanes of a texture coordinate output
; run: POSITION0=1,2,3,4 c0=1,1,1,1 -> POSITION0=1,2,3,4 TEXCOORD0=6,10
vs_1_1
dcl_position v0
mov oPos, v0
dp3 oT0.x, v0, c0
dp4 oT0.y, v0, c0

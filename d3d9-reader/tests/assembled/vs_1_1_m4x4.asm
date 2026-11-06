; vs_1_1 m4x4: the position times four constant rows, each lane a dp4 with the next register
; run: POSITION0=1,2,3,1 c0=2,0,0,0 c1=0,3,0,0 c2=0,0,1,1 c3=0,0,0,1 -> POSITION0=2,6,4,1
vs_1_1
dcl_position v0
m4x4 oPos, v0, c0

; vs_1_1 slt and sge: 1 where the comparison holds, 0 where not, lane by lane
; run: c0=1,2,3,-0 c1=2,2,2,0 -> TEXCOORD0=1,0,0,0 TEXCOORD1=0,1,1,1
vs_1_1
dcl_position v0
mov oPos, v0
mov r1, c1
slt oT0, c0, r1
sge oT1, c0, r1

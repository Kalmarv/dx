; vs_2_x setp and predicated writes: setp_gt per lane, (p0) and (!p0) moves
; run: c0=1,5,3,0 c1=2,2,2,2 c2=7,7,7,7 c3=9,9,9,9 -> TEXCOORD0=9,7,7,9
vs_2_x
dcl_position v0
mov oPos, v0
mov r1, c1
setp_gt p0, c0, r1
mov r0, c3
(p0) mov r0, c2
mov oT0, r0

; vs_1_1 dst: the distance vector (1, a.y * b.y, a.z, b.w)
; run: c0=9,2,3,9 c1=9,4,9,5 -> TEXCOORD0=1,8,3,5
vs_1_1
dcl_position v0
mov oPos, v0
mov r1, c1
dst oT0, c0, r1

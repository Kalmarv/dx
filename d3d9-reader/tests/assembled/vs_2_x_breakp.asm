; vs_2_x breakp: a loop left where a predicate lane holds
; run: i0=10,0,0,0 c0=1,0,0,0 c1=4,0,0,0 -> TEXCOORD0=4
vs_2_x
def c2, 0, 0, 0, 0
dcl_position v0
mov oPos, v0
mov r0, c2
mov r1, c1
rep i0
add r0, r0, c0
setp_ge p0.x, r0.x, r1.x
breakp p0.x
endrep
mov oT0.x, r0.x

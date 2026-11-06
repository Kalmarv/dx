; vs_2_x callnz on a predicate lane, and a predicated call's negation
; run: c0=1,0,0,0 c1=0,0,0,0 c2=3,3,3,3 -> TEXCOORD0=6,6,6,6
; run: c0=-1,0,0,0 c1=0,0,0,0 c2=3,3,3,3 -> TEXCOORD0=3,3,3,3
vs_2_x
dcl_position v0
mov oPos, v0
mov r1, c1
setp_gt p0.x, c0.x, r1.x
mov r0, c2
callnz l0, p0.x
mov oT0, r0
ret
label l0
add r0, r0, r0
ret

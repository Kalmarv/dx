; vs_2_x break_ge inside rep: the loop left once the sum reaches the limit
; run: i0=10,0,0,0 c0=1,0,0,0 c1=3,0,0,0 -> TEXCOORD0=3
vs_2_x
def c2, 0, 0, 0, 0
dcl_position v0
mov oPos, v0
mov r0, c2
mov r1, c1
rep i0
break_ge r0.x, r1.x
add r0, r0, c0
endrep
mov oT0.x, r0.x

; vs_2_0 rep: the body run i0.x times, a count of 0 skipping it
; run: i0=3,0,0,0 c0=1,2,0,0 -> TEXCOORD0=3,6
; run: i0=0,0,0,0 c0=1,2,0,0 -> TEXCOORD0=0,0
vs_2_0
def c1, 0, 0, 0, 0
dcl_position v0
mov oPos, v0
mov r0, c1
rep i0
add r0, r0, c0
endrep
mov oT0.xy, r0

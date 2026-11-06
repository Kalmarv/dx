; vs_2_0 loop: aL from i0.y by i0.z, i0.x times, reading c[aL] in the body
; run: i0=3,1,2,0 c1=1,0,0,0 c3=10,0,0,0 c5=100,0,0,0 c7=1000,0,0,0 -> TEXCOORD0=111
vs_2_0
def c0, 0, 0, 0, 0
dcl_position v0
mov oPos, v0
mov r0, c0
loop aL, i0
add r0, r0, c[aL]
endloop
mov oT0.x, r0.x

; vs_3_0 loop with an output indexed by aL: o[aL] written each iteration
; run: i0=2,1,1,0 c0=3,3,3,3 c1=4,4,4,4 -> TEXCOORD0=3,3,3,3 TEXCOORD1=4,4,4,4
vs_3_0
def c2, 1, 1, 1, 1
dcl_position v0
dcl_position o0
dcl_texcoord0 o1
dcl_texcoord1 o2
mov o0, v0
mov r0, c0
loop aL, i0
mov o[aL], r0
add r0, r0, c2
endloop

; vs_1_1 negation and swizzles of sources, and write masks
; run: c0=1,-2,3,-4 -> TEXCOORD0=-1,2,-3,4 TEXCOORD1=-4,-4,3,-2
vs_1_1
dcl_position v0
mov oPos, v0
mov oT0, -c0
mov oT1, c0.wwzy

; vs_3_0 the absolute value source modifier, with negation
; run: c0=-1,2,-3,0 -> TEXCOORD0=1,2,3,0 TEXCOORD1=-1,-2,-3,-0
vs_3_0
dcl_position v0
dcl_position o0
dcl_texcoord0 o1
dcl_texcoord1 o2
mov o0, v0
mov r0, c0
mov o1, r0_abs
mov o2, -r0_abs

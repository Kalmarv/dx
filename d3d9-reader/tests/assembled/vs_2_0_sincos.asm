; vs_2_0 sincos with its constant operands, at zero: cos 1 and sin 0
; run: c0=0,0,0,0 -> TEXCOORD0=1,0
vs_2_0
def c1, -1.55009923e-006, -2.17013894e-005, 0.00260416674, 0.00026041668
def c2, -0.020833334, -0.125, 1, 0.5
dcl_position v0
mov oPos, v0
mov r1, c0
sincos r0.xy, r1.x, c1, c2
mov oT0.xy, r0

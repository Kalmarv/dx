; vs_1_1 expp, its exact lanes (2^floor(x), the fraction, and 1), and logp, log2(|x|) in every lane (as wined3d
; computes the shader model 1 macros)
; run: c0=2.5,-8,0,0 -> TEXCOORD0=4,0.5 TEXCOORD1=1 TEXCOORD2=3,3 TEXCOORD3=3
vs_1_1
dcl_position v0
mov oPos, v0
expp r0, c0.x
mov oT0.xy, r0
mov oT1.x, r0.w
logp r1, c0.y
mov oT2.xy, r1
mov oT3.x, r1.w

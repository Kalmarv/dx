; vs_3_0 texldl: a vertex texture sampled at an explicit level, the coordinate's w
; run: c0=0.5,0.25,0,2 -> TEXCOORD0=tex(0;0.5,0.25;level:2)
vs_3_0
dcl_position v0
dcl_position o0
dcl_texcoord o1
dcl_2d s0
mov o0, v0
mov r0, c0
texldl o1, r0, s0

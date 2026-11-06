; vs_3_0 declared outputs: semantics of any register, packed into lanes of one
; run: POSITION0=1,2,3,4 c0=5,6,7,8 -> POSITION0=1,2,3,4 TEXCOORD0=5,6 TEXCOORD1=7,8 COLOR0=8,7,6,5
vs_3_0
dcl_position v0
dcl_position o0
dcl_texcoord0 o1.xy
dcl_texcoord1 o1.zw
dcl_color o2
mov o0, v0
mov o1, c0
mov o2, c0.wzyx

; vs_1_1 lit: (1, max(N.L, 0), N.L > 0 and N.H > 0 ? N.H^power : 0, 1)
; run: c0=0.5,0.5,0,2 -> TEXCOORD0=1,0.5,0.25,1
; run: c0=-0.5,0.5,0,2 -> TEXCOORD0=1,0,0,1
vs_1_1
dcl_position v0
mov oPos, v0
lit oT0, c0

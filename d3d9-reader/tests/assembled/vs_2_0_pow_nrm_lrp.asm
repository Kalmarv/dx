; vs_2_0 pow (|x|^y), nrm (xyz over their length) and lrp (a*b + (1-a)*c)
; run: c0=-2,3,0,0 c1=0,4,0,7 c2=0.25,4,8,0 -> TEXCOORD0=8 TEXCOORD1=0,1,0 TEXCOORD2=7
vs_2_0
dcl_position v0
mov oPos, v0
mov r9, c0
pow r0.x, r9.x, c0.y
mov oT0.x, r0.x
mov r1, c1
nrm r2.xyz, r1
mov oT1.xyz, r2
mov r3, c2
lrp r4.x, r3.x, r3.y, r3.z
mov oT2.x, r4.x

; vs_2_0 sgn (-1, 0 or 1, of each lane) and crs (the cross product of the xyz lanes)
; run: c0=-2,0,3,-0 c1=1,0,0,0 c2=0,1,0,0 -> TEXCOORD0=-1,0,1,0 TEXCOORD1=0,0,1
vs_2_0
dcl_position v0
mov oPos, v0
mov r3, c0
sgn r0, r3, r1, r2
mov oT0, r0
mov r4, c1
crs r5.xyz, r4, c2
mov oT1.xyz, r5

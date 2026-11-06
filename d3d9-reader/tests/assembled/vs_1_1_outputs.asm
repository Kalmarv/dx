; vs_1_1 every output register: colours, texture coordinates, fog and point size
; run: c0=0.25,0.5,0.75,1 c1=2,3,4,5 -> COLOR0=0.25,0.5,0.75,1 COLOR1=1,0.75,0.5,0.25 TEXCOORD7=2,3,4,5 FOG0=3 PSIZE0=4
vs_1_1
dcl_position v0
mov oPos, v0
mov oD0, c0
mov oD1, c0.wzyx
mov oT7, c1
mov oFog, c1.y
mov oPts, c1.z

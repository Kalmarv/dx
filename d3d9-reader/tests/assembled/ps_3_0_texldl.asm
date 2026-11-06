; ps_3_0 texldl: sampled at the level of detail the coordinate's w gives
; run: TEXCOORD0=0.5,0.25,0,2 -> SV_Target0=tex(0;0.5,0.25;level:2)
ps_3_0
dcl_texcoord0 v0
dcl_2d s0
texldl r0, v0, s0
mov oC0, r0

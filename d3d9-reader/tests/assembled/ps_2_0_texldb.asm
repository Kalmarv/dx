; ps_2_0 texldb: sampled with the coordinate's w as the level of detail bias
; run: TEXCOORD0=0.5,0.25,0,1.5 -> SV_Target0=tex(0;0.5,0.25;bias:1.5)
ps_2_0
dcl t0
dcl_2d s0
texldb r0, t0, s0
mov oC0, r0

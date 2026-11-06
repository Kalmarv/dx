; ps_2_0 texld: a declared 2D sampler at the coordinate's x and y
; run: TEXCOORD0=0.5,0.25,0.75,2 -> SV_Target0=tex(0;0.5,0.25;auto)
ps_2_0
dcl t0
dcl_2d s0
texld r0, t0, s0
mov oC0, r0

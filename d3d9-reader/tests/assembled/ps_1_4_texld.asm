; ps_1_4 texld: sampler stage 0 at texture coordinate 0, by the dimension the state gives
; run: TEXCOORD0=0.5,0.25,0.75,1 texdim0=2d -> SV_Target0=tex(0;0.5,0.25;auto)
; run: TEXCOORD0=0.5,0.25,0.75,1 texdim0=3d -> SV_Target0=tex(0;0.5,0.25,0.75;auto)
ps_1_4
texld r0, t0

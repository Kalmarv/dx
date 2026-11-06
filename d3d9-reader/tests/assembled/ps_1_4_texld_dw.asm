; ps_1_4 texld with _dw: the coordinate divided by its w, then sampled
; lift: texdim0=2d
; run: TEXCOORD0=1,0.5,0.75,2 -> SV_Target0=tex(0;0.5,0.25;auto)
ps_1_4
texld r0, t0_dw.xyw

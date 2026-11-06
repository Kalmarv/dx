; ps_1_4 texld with _dz in phase 2: the coordinate divided by its z, then sampled
; lift: texdim1=2d
; run: TEXCOORD0=1,0.5,2,1 -> SV_Target0=tex(1;0.5,0.25;auto)
ps_1_4
texcrd r0.rgb, t0
phase
texld r1, r0_dz
mov r0, r1

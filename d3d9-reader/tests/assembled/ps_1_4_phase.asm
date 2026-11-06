; ps_1_4 phase: a coordinate computed in phase 1 sampled in phase 2 (a dependent read at stage 1)
; lift: texdim1=2d
; run: TEXCOORD0=0.25,0.5,0,1 c0=0.25,0.25,0,0 -> SV_Target0=tex(1;0.5,0.75;auto)
ps_1_4
texcrd r0.rgb, t0
add r0.rgb, r0, c0
phase
texld r1, r0
mov r0, r1

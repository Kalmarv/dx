; ps_1_1 texm3x2pad and texm3x2tex: stage 2 sampled at the dot products of coordinates 1 and 2 with t0
; run: TEXCOORD0=1,0.5,0.25,1 TEXCOORD1=0.5,0,0,0 TEXCOORD2=0,0.5,1,0 texdim2=2d -> SV_Target0=tex(2;0.5,0.5;auto)
ps_1_1
texcoord t0
texm3x2pad t1, t0
texm3x2tex t2, t0
mov r0, t2

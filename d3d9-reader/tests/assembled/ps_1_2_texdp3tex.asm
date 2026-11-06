; ps_1_2 texdp3tex: stage 1 sampled at the dot product of coordinate 1 with t0 (and 0 in y)
; run: TEXCOORD0=1,0.5,0.25,1 TEXCOORD1=0.25,0.5,1,9 texdim1=2d -> SV_Target0=tex(1;0.75,0;auto)
ps_1_2
texcoord t0
texdp3tex t1, t0
mov r0, t1

; ps_1_2 texdp3: the dot product of coordinate 1 with t0, in every lane
; run: TEXCOORD0=1,0.5,0.25,1 TEXCOORD1=1,2,3,9 -> SV_Target0=2.75,2.75,2.75,2.75
ps_1_2
texcoord t0
texdp3 t1, t0
mov r0, t1

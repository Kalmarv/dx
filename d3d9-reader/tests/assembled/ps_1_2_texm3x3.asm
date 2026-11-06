; ps_1_2 texm3x3: the dot products of coordinates 1, 2 and 3 with t0, and 1 in w
; run: TEXCOORD0=1,0.5,0.25,1 TEXCOORD1=1,0,0,0 TEXCOORD2=0,2,0,0 TEXCOORD3=1,1,4,0 -> SV_Target0=1,1,2.5,1
ps_1_2
texcoord t0
texm3x3pad t1, t0
texm3x3pad t2, t0
texm3x3 t3, t0
mov r0, t3

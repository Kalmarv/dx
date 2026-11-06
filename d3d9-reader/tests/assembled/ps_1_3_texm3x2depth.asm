; ps_1_3 texm3x2depth: the depth z / w of the dot products of coordinates 1 and 2 with t0, and 1 where w is 0
; run: TEXCOORD0=1,0.5,0.25,1 TEXCOORD1=0.25,0,0,0 TEXCOORD2=0.5,0,0,0 c0=0,0,0,1 -> SV_Target0=0,0,0,1 SV_Depth0=0.5
; run: TEXCOORD0=1,0.5,0.25,1 TEXCOORD1=0.25,0,0,0 TEXCOORD2=0,0,0,0 c0=0,0,0,1 -> SV_Target0=0,0,0,1 SV_Depth0=1
ps_1_3
texcoord t0
texm3x2pad t1, t0
texm3x2depth t2, t0
mov r0, c0

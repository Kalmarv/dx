; ps_2_0 oDepth: the depth output written from a scalar
; run: c0=0.25,0.5,0.75,1 -> SV_Target0=0.25,0.5,0.75,1 SV_Depth0=0.75
ps_2_0
mov oC0, c0
mov r0, c0
mov oDepth, r0.z

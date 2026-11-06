; ps_3_0 four render targets and the depth output
; run: c0=0.25,0.5,0.75,1 c1=1,2,3,4 -> SV_Target0=0.25,0.5,0.75,1 SV_Target1=1,2,3,4 SV_Target2=0.25,0.5,0.75,1 SV_Target3=1,2,3,4 SV_Depth0=1
ps_3_0
mov oC0, c0
mov oC1, c1
mov oC2, c0
mov oC3, c1
mov oDepth, c0.w

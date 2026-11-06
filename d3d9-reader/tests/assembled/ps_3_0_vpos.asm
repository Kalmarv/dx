; ps_3_0 vPos: the pixel's window position at its top left corner, half a pixel back from where it is sampled
; run: VPOS0=10.5,20.5,0.5,1 c0=0,0,0.5,1 -> SV_Target0=10,20,0.5,1
ps_3_0
dcl vPos.xy
mov r0.xy, vPos.xy
mov r0.zw, c0
mov oC0, r0

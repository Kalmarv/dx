; ps_2_0 texkill: the pixel is discarded where any of the four lanes is negative (w included, unlike pixel 1.x)
; run: TEXCOORD0=0.5,0.5,0.5,-1 -> kill
; run: TEXCOORD0=0.5,-0,0.5,1 -> SV_Target0=0.5,-0,0.5,1
ps_2_0
dcl t0
mov r0, t0
texkill r0
mov oC0, r0

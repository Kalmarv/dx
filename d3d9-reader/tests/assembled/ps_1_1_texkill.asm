; ps_1_1 texkill: the pixel is discarded where any of the coordinate's x, y and z is negative (w is not tested)
; run: TEXCOORD0=0.5,-0.1,0,1 COLOR0=0.25,0.5,0.75,1 -> kill
; run: TEXCOORD0=0.5,0.1,0,-1 COLOR0=0.25,0.5,0.75,1 -> SV_Target0=0.25,0.5,0.75,1
ps_1_1
texkill t0
mov r0, v0

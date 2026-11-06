; ps_1_1 texcoord: the coordinate's x, y and z within 0..1, and 1 in w
; run: TEXCOORD0=1.5,-0.5,0.25,0.75 -> SV_Target0=1,0,0.25,1
ps_1_1
texcoord t0
mov r0, t0

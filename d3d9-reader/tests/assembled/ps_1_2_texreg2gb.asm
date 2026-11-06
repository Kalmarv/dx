; ps_1_2 texreg2gb: stage 1 sampled at t0's green and blue
; run: TEXCOORD0=0.75,0.5,0.25,0 texdim1=2d -> SV_Target0=tex(1;0.5,0.25;auto)
ps_1_2
texcoord t0
texreg2gb t1, t0
mov r0, t1

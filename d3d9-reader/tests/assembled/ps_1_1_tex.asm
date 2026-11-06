; ps_1_1 tex: a texture stage of unknown dimension, sampled at its coordinate by the dimension the state gives
; run: TEXCOORD0=0.5,0.25,0.75,1 texdim0=2d projected0=false -> SV_Target0=tex(0;0.5,0.25;auto)
; run: TEXCOORD0=0.5,0.25,0.75,1 texdim0=cube projected0=false -> SV_Target0=tex(0;0.5,0.25,0.75;auto)
; run: TEXCOORD0=0.5,0.25,0.75,1 texdim0=3d projected0=false -> SV_Target0=tex(0;0.5,0.25,0.75;auto)
ps_1_1
tex t0
mov r0, t0

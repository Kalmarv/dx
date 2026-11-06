; ps_1_3 tex at a stage the host states is a cube map, which the stage's state does not project
; lift: texdim0=cube
; run: TEXCOORD0=0.5,0.25,0.75,2 projected0=true -> SV_Target0=tex(0;0.5,0.25,0.75;auto)
ps_1_3
tex t0
mov r0, t0

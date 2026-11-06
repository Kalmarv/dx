; ps_1_1 tex of a projecting stage (D3DTTFF_PROJECTED): the coordinate divided by its w before sampling
; run: TEXCOORD0=1,0.5,0.75,2 texdim0=2d projected0=true -> SV_Target0=tex(0;0.5,0.25;auto)
; run: TEXCOORD0=1,0.5,0.75,2 texdim0=2d projected0=false -> SV_Target0=tex(0;1,0.5;auto)
ps_1_1
tex t0
mov r0, t0

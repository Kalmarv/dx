; ps_1_1 texbem: stage 1 sampled at its coordinate plus its bump matrix (00, 01, 10, 11) times t0's x and y
; run: TEXCOORD0=0.5,0.25,0,1 TEXCOORD1=0.25,0.5,0,1 bumpenvmat1=1,2,3,4 texdim1=2d projected1=false projected0=false texdim0=2d -> SV_Target0=tex(1;1.5,2.5;auto)
ps_1_1
texcoord t0
texbem t1, t0
mov r0, t1

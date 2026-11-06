; ps_2_x texldd: sampled with explicit derivatives of the coordinate along x and y
; run: TEXCOORD0=0.5,0.25,0,1 c1=0.125,0,0,0 c2=0,0.25,0,0 -> SV_Target0=tex(0;0.5,0.25;grad:0.125,0/0,0.25)
ps_2_x
dcl t0
dcl_2d s0
mov r1, c1
mov r2, c2
texldd r0, t0, s0, r1, r2
mov oC0, r0

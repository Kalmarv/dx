; ps_3_0 texldd of a volume texture: explicit derivatives of x, y and z
; run: TEXCOORD0=0.5,0.25,0.75,1 c1=0.125,0,0,0 c2=0,0.25,0.5,0 -> SV_Target0=tex(0;0.5,0.25,0.75;grad:0.125,0,0/0,0.25,0.5)
ps_3_0
dcl_texcoord0 v0
dcl_volume s0
mov r1, c1
mov r2, c2
texldd r0, v0, s0, r1, r2
mov oC0, r0

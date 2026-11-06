; ps_2_0 texld at the implicit level in a quad: the sample is asked with the quad's coarse derivatives of its coordinate
; quad: TEXCOORD0=0.5,0.25 -> SV_Target0=tex(0;0.5,0.25;grad:0.25,0/0,1) | TEXCOORD0=0.75,0.25 -> SV_Target0=tex(0;0.75,0.25;grad:0.25,0/0,1) | TEXCOORD0=0.5,1.25 -> SV_Target0=tex(0;0.5,1.25;grad:0.25,0/0,1) | TEXCOORD0=1,2 -> SV_Target0=tex(0;1,2;grad:0.25,0/0,1)
ps_2_0
dcl t0.xy
dcl_2d s0
texld r0, t0, s0
mov oC0, r0

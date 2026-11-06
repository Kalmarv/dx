; ps_2_0 texldp: the coordinate divided by its w, then sampled
; run: TEXCOORD0=1,0.5,0.75,2 -> SV_Target0=tex(0;0.5,0.25;auto)
ps_2_0
dcl t0
dcl_2d s0
texldp r0, t0, s0
mov oC0, r0

; ps_2_0 texldp of a cube map: not divided by w, as wined3d
; run: TEXCOORD0=1,0.5,0.75,2 -> SV_Target0=tex(0;1,0.5,0.75;auto)
ps_2_0
dcl t0
dcl_cube s0
texldp r0, t0, s0
mov oC0, r0

; ps_3_0 dsx and dsy of an input, written to two render targets
; quad: TEXCOORD0=1,2,3,4 -> SV_Target0=1,2,4,-4 SV_Target1=4,-1,0,4 | TEXCOORD0=2,4,7,0 -> SV_Target0=1,2,4,-4 SV_Target1=4,-1,0,4 | TEXCOORD0=5,1,3,8 -> SV_Target0=1,2,4,-4 SV_Target1=4,-1,0,4 | TEXCOORD0=0,0,0,0 -> SV_Target0=1,2,4,-4 SV_Target1=4,-1,0,4
ps_3_0
dcl_texcoord0 v0
dsx r0, v0
dsy r1, v0
mov oC0, r0
mov oC1, r1

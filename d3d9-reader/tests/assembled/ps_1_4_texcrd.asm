; ps_1_4 texcrd: the texture coordinate copied as data
; run: TEXCOORD0=2,4,-1,8 c0=0,0,0,0.5 -> SV_Target0=2,4,-1,0.5
ps_1_4
texcrd r0.rgb, t0
mov r0.a, c0

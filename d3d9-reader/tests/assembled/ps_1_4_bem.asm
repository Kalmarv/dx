; ps_1_4 bem: x and y of source 0 plus stage 0's bump matrix (00, 01, 10, 11) times x and y of source 1
; run: TEXCOORD0=0.25,0.5,0,1 TEXCOORD1=0.5,0.25,0,1 bumpenvmat0=1,2,3,4 c0=0,0,0.5,1 -> SV_Target0=1.5,2.5,0.5,1
ps_1_4
texcrd r1.rgb, t0
texcrd r2.rgb, t1
bem r0.rg, r1, r2
phase
mov r0.ba, c0

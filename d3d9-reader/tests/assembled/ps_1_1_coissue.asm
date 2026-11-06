; ps_1_1 co-issue: the alpha half reads r0 as it was before the colour half of its pair writes it
; run: COLOR0=0.5,0.5,0.5,0.5 c0=0.5,0.5,0.5,0.5 -> SV_Target0=0.25,0.25,0.25,1
ps_1_1
mov r0, v0
mul r0.rgb, r0, c0
+add r0.a, r0.b, c0

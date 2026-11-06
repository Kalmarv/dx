; ps_2_0 mul, the default rule: zero times anything, infinity and NaN included, is +0, as Direct3D 9 drivers do
; run: c0=0,0,-0,2 c1=inf,nan,1,3 -> SV_Target0=0,0,0,6
ps_2_0
mov r1, c1
mul r0, c0, r1
mov oC0, r0

; ps_2_0 mad and dp3 under the default rule: a zero factor wins in each product, the sums are IEEE 754
; run: c0=0,1,1,0 c1=inf,2,3,nan c2=1,1,1,1 -> SV_Target0=1,3,4,1 SV_Target1=5,1,1,1
ps_2_0
mov r1, c1
mov r3, c2
mad r0, c0, r1, r3
dp3 r2.x, c0, r1
mov r2.yzw, r3
mov oC0, r0
mov oC1, r2

; ps_2_0 mul under the IEEE 754 rule: zero times infinity or NaN is NaN, and signs multiply
; lift: mul=ieee
; run: c0=0,0,-0,2 c1=inf,nan,1,3 -> SV_Target0=nan,nan,-0,6
ps_2_0
mov r1, c1
mul r0, c0, r1
mov oC0, r0

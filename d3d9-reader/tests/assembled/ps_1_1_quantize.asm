; ps_1_1 with the fixed point policy: each write kept to 8 fractional bits, rounded to nearest even
; lift: quantize=8,nearest_even
; run: c0=0.3,0.001,0.5,-0.3 -> SV_Target0=0.30078125,0,0.5,-0.30078125
ps_1_1
mov r0, c0

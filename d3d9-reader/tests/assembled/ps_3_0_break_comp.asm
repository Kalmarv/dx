; ps_3_0 break_ge out of a rep
; run: c1=3.5,0,0,0 -> SV_Target0=4,4,4,4
; run: c1=0,0,0,0 -> SV_Target0=1,1,1,1
ps_3_0
defi i0, 10, 0, 0, 0
def c3, 0, 0, 0, 0
def c4, 1, 1, 1, 1
mov r0, c3
rep i0
add r0, r0, c4
break_ge r0.x, c1.x
endrep
mov oC0, r0

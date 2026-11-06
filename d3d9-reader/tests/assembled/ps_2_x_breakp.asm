; ps_2_x setp_ge and breakp out of a rep
; run: c0=1,1,1,1 c1=3.5,0,0,0 -> SV_Target0=4,4,4,4
; run: c0=0.5,1,1,1 c1=1,0,0,0 -> SV_Target0=1,2,2,2
ps_2_x
defi i0, 10, 0, 0, 0
def c3, 0, 0, 0, 0
mov r0, c3
mov r1, c1
rep i0
add r0, r0, c0
setp_ge p0.x, r0.x, r1.x
breakp p0.x
endrep
mov oC0, r0

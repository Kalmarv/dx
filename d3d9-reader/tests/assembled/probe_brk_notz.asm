ps_2_x
defi i0, 4, 0, 0, 0
mov r1, c1
rep i0
setp_ge p0, c0, r1
breakp !p0.z
endrep
mov oC0, c0

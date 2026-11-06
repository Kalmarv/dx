; ps_2_x call of a subroutine twice
; run: c0=1,2,3,4 -> SV_Target0=4,8,12,16
ps_2_x
mov r0, c0
call l0
call l0
mov oC0, r0
ret
label l0
add r0, r0, r0
ret

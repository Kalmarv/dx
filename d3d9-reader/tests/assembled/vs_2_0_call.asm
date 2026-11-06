; vs_2_0 call and ret: a subroutine after the main program's ret, called twice
; run: c0=1,2,3,4 -> TEXCOORD0=2,4,6,8 TEXCOORD1=4,8,12,16
vs_2_0
dcl_position v0
mov oPos, v0
mov r0, c0
call l0
mov oT0, r0
call l0
mov oT1, r0
ret
label l0
add r0, r0, r0
ret

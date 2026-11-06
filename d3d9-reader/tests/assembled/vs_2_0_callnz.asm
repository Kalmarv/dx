; vs_2_0 callnz: the subroutine called where a boolean constant holds
; run: b0=true c0=1,2,3,4 -> TEXCOORD0=2,4,6,8
; run: b0=false c0=1,2,3,4 -> TEXCOORD0=1,2,3,4
vs_2_0
dcl_position v0
mov oPos, v0
mov r0, c0
callnz l1, b0
mov oT0, r0
ret
label l1
add r0, r0, r0
ret

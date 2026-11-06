; vs_2_0 defb and defi: a program's own boolean and integer constants decide its flow
; run: c0=1,0,0,0 b0=false i0=1,0,0,0 -> TEXCOORD0=4
vs_2_0
defb b0, true
defi i0, 4, 0, 0, 0
def c1, 0, 0, 0, 0
dcl_position v0
mov oPos, v0
mov r0, c1
if b0
rep i0
add r0, r0, c0
endrep
endif
mov oT0.x, r0.x

; vs_1_1 def: a constant the program defines is the value it reads, whatever the host sets
; run: c0=9,9,9,9 c1=1,2,3,4 -> TEXCOORD0=0.5,1.5,2.5,3.5 TEXCOORD1=1,2,3,4
vs_1_1
def c0, 0.5, 1.5, 2.5, 3.5
dcl_position v0
mov oPos, v0
mov oT0, c0
mov oT1, c1

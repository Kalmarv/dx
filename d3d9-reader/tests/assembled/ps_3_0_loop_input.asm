; ps_3_0 loop with an input indexed by aL: v[aL] read each iteration
; run: TEXCOORD0=1,2,3,4 TEXCOORD1=10,20,30,40 -> SV_Target0=11,22,33,44
ps_3_0
defi i0, 2, 0, 1, 0
def c0, 0, 0, 0, 0
dcl_texcoord0 v0
dcl_texcoord1 v1
mov r0, c0
loop aL, i0
add r0, r0, v[aL]
endloop
mov oC0, r0

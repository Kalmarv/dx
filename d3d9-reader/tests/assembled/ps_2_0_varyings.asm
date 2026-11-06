; ps_2_0 colour and texture coordinate inputs (v# and t#) and two render targets
; run: COLOR0=0.25,0.5,0.75,1 TEXCOORD1=2,3,4,5 -> SV_Target0=2.25,3.5,4.75,6 SV_Target1=2,3,4,5
ps_2_0
dcl v0
dcl t1
mov r1, t1
add r0, v0, r1
mov oC0, r0
mov oC1, t1

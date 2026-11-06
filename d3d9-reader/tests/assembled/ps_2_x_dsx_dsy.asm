; ps_2_x dsx and dsy: the coordinate's derivatives along x and y, coarse: lane 1 less lane 0, lane 2 less lane 0
; quad: TEXCOORD0=1,2,3,4 -> SV_Target0=5,1,4,0 | TEXCOORD0=2,4,7,0 -> SV_Target0=5,1,4,0 | TEXCOORD0=5,1,3,8 -> SV_Target0=5,1,4,0 | TEXCOORD0=0,0,0,0 -> SV_Target0=5,1,4,0
ps_2_x
dcl t0
dsx r0, t0
dsy r1, t0
add r0, r0, r1
mov oC0, r0

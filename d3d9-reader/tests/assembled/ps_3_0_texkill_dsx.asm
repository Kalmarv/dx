; ps_3_0 texkill before dsx: the killed pixel goes on as a helper, and its neighbours' derivatives still read it
; quad: TEXCOORD0=1,2,3,4 -> SV_Target0=1,-4,-3,-2 | TEXCOORD0=2,-2,0,2 -> kill | TEXCOORD0=5,1,3,8 -> SV_Target0=1,-4,-3,-2 | TEXCOORD0=0,0,0,0 -> SV_Target0=1,-4,-3,-2
ps_3_0
dcl_texcoord0 v0
mov r0, v0
texkill r0
dsx r1, v0
mov oC0, r1

ps_5_0
dcl_globalFlags refactoringAllowed
dcl_constantbuffer CB0[3], immediateIndexed
dcl_output o0.xyzw
dcl_output o1.xyzw
dcl_output o2.xyzw
dcl_output o3.xyzw
dcl_output o4.xyzw
min o0.x, cb0[0].y, cb0[0].x
max o0.yw, cb0[0].yyyy, cb0[0].xxxx
mov_sat o0.z, cb0[0].x
udiv o1.xz, null, cb0[1].xxzx, cb0[1].yywy
udiv null, o1.yw, cb0[1].xxxz, cb0[1].yyyw
ftoi o2.xz, cb0[0].xxzx
ftou o2.yw, cb0[0].xxxz
ishl o3.x, cb0[1].x, cb0[1].y
ushr o3.y, cb0[1].x, cb0[1].y
ishr o3.z, cb0[2].x, cb0[2].y
and o3.w, cb0[1].y, cb0[1].x
div o4.x, cb0[0].x, cb0[0].w
sqrt o4.y, cb0[0].z
log o4.z, cb0[0].w
mul o4.w, cb0[0].y, cb0[0].y
ret 

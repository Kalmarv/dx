ps_5_0
dcl_globalFlags refactoringAllowed | skipOptimization
dcl_input_ps linear v0.xyzw
dcl_output o0.xyzw
dcl_temps 4
itof r0.xy, l(2, 2, 0, 0)
mul r0.xy, r0.xyxx, v0.xyxx
itof r0.zw, l(0, 0, 1, 1)
add r0.zw, r0.zzzw, v0.zzzw
mul r1.x, v0.w, v0.x
mul r1.y, v0.z, v0.y
itof r1.zw, l(0, 0, 3, 3)
mul r1.zw, r1.zzzw, v0.yyyx
itof r2.xy, l(4, 4, 0, 0)
mul r2.xy, r2.xyxx, v0.wzww
itof r2.zw, l(0, 0, 5, 5)
mul r2.zw, r2.zzzw, v0.xxxz
itof r3.xy, l(6, 6, 0, 0)
mul r3.xy, r3.xyxx, v0.zxzz
add o0.x, r0.x, r1.w
add o0.y, r0.w, r2.x
add r0.x, r0.z, r0.y
add o0.z, r2.z, r0.x
add r0.x, r1.y, r1.x
add r0.x, r1.z, r0.x
add r0.x, r2.y, r0.x
add r0.x, r2.w, r0.x
mul r0.y, r3.y, r3.x
add o0.w, r0.y, r0.x
ret 

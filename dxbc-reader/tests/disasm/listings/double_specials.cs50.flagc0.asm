cs_5_0
dcl_globalFlags refactoringAllowed | enableDoublePrecisionFloatOps
dcl_uav_raw u0
dcl_input vThreadID.xyz
dcl_temps 2
dcl_thread_group 1, 1, 1
mov r0.xy, vThreadID.xyxx
dmul r1.xyzw, r0.xyxy, d(0x00000000, 0xfff00000, 0x00000000, 0x7ff00000)
store_raw u0.xyzw, l(0x00000000), r1.xyzw
dmovc r1.xyzw, vThreadID.zzzz, r0.xyxy, d(0x00000001, 0x7ff00001, 0x00000001, 0xfff00001)
store_raw u0.xyzw, l(0x00000010), r1.xyzw
dmovc r1.xyzw, vThreadID.zzzz, r0.xyxy, d(0x00000000, 0xfff80000, 0x00000005, 0x7ff80000)
dmovc r0.xy, vThreadID.zzzz, r0.xyxy, d(0x00000005, 0xfff80000, 0x00000000, 0x00000000)
store_raw u0.xyzw, l(0x00000020), r1.xyzw
store_raw u0.xy, l(0x00000030), r0.xyxx
ret 

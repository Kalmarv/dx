cs_4_0
dcl_globalFlags refactoringAllowed | skipOptimization
dcl_uav_structured u0, 4
dcl_input vThreadIDInGroupFlattened
dcl_input vThreadID.x
dcl_temps 1
dcl_tgsm_structured g0, 4, 256
dcl_thread_group 256, 1, 1
store_structured g0.x, vThreadIDInGroupFlattened.x, l(0), vThreadID.x
sync_g_t
mov r0.x, l(255)
ineg r0.y, vThreadIDInGroupFlattened.x
iadd r0.x, r0.y, r0.x
ld_structured r0.x, r0.x, l(0), g0.xxxx
store_structured u0.x, vThreadID.x, l(0), r0.x
ret 

      cs_5_1
      dcl_globalFlags refactoringAllowed
      dcl_resource_raw T0[3:3], space=7
      dcl_uav_typed_texture2d (float,float,float,float) U0[1:2], space=0
      dcl_input vThreadIDInGroupFlattened
      dcl_input vThreadID.xyz
      dcl_temps 1
      dcl_tgsm_structured g0, 4, 64
      dcl_thread_group 8, 8, 1
   0: ishl r0.x, vThreadIDInGroupFlattened.x, l(2)
   1: ld_raw r0.x, r0.x, T0[3].xxxx
   2: store_structured g0.x, vThreadIDInGroupFlattened.x, l(0), r0.x
   3: sync_g_t
   4: and r0.x, vThreadID.z, l(1)
   5: iadd r0.y, -vThreadIDInGroupFlattened.x, l(63)
   6: ld_structured r0.y, r0.y, l(0), g0.xxxx
   7: store_uav_typed U0[r0.x + 1].xyzw, vThreadID.xyyy, r0.yyyy
   8: ret 

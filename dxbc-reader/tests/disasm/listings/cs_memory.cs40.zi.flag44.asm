      cs_4_0
      dcl_globalFlags refactoringAllowed
      dcl_uav_structured u0, 4
      dcl_input vThreadIDInGroupFlattened
      dcl_input vThreadID.x
      dcl_temps 1
      dcl_tgsm_structured g0, 4, 256
      dcl_thread_group 256, 1, 1
//
// Initial variable locations:
//   vThreadID.x <- tid; 
//   vThreadIDInGroupFlattened.x <- flat
//
#line 71 "C:\dx-fixtures\cs_memory.hlsl"
   0: store_structured g0.x, vThreadIDInGroupFlattened.x, l(0), vThreadID.x

#line 72
   1: sync_g_t

#line 73
   2: iadd r0.x, -vThreadIDInGroupFlattened.x, l(255)
   3: ld_structured r0.x, r0.x, l(0), g0.xxxx
   4: store_structured u0.x, vThreadID.x, l(0), r0.x

#line 74
   5: ret 

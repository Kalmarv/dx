      cs_5_0
      dcl_globalFlags refactoringAllowed
      dcl_uav_typed_buffer (uint,uint,uint,uint) u0
      dcl_input vThreadID.x
      dcl_temps 1
      dcl_thread_group 4, 1, 1
   0: ld_uav_typed_indexable(buffer)(uint,uint,uint,uint) r0.x, vThreadID.xxxx, u0.xyzw
   1: ult r0.y, l(3), r0.x
   2: if_nz r0.y
   3:   printf "big %u at %u", r0.x, vThreadID.x
   4:   ult r0.x, l(100), r0.x
   5:   if_nz r0.x
   6:     abort 
   7:   endif 
   8: endif 
   9: store_uav_typed u0.xyzw, vThreadID.xxxx, vThreadID.xxxx
  10: ret 

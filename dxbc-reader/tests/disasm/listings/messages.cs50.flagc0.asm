cs_5_0
dcl_globalFlags refactoringAllowed
dcl_uav_typed_buffer (uint,uint,uint,uint) u0
dcl_input vThreadID.x
dcl_temps 1
dcl_thread_group 4, 1, 1
ld_uav_typed_indexable(buffer)(uint,uint,uint,uint) r0.x, vThreadID.xxxx, u0.xyzw
ult r0.y, l(0x00000003), r0.x
if_nz r0.y
  printf "big %u at %u", r0.x, vThreadID.x
  ult r0.x, l(0x00000064), r0.x
  if_nz r0.x
    abort 
  endif 
endif 
store_uav_typed u0.xyzw, vThreadID.xxxx, vThreadID.xxxx
ret 

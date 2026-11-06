cs_5_0
dcl_globalFlags refactoringAllowed
dcl_uav_typed_texture2d (float,float,float,float) u0
dcl_thread_group 1, 1, 1

#line 8 "C:\dx-fixtures\zi_compute.hlsl"
store_uav_typed u0.xyzw, l(0x00000000,0x00000000,0x00000000,0x00000000), l(0xc2f60000,0xc2f60000,0xc2f60000,0xc2f60000)

#line 9
store_uav_typed u0.xyzw, l(0x00000001,0x00000000,0x00000000,0x00000000), l(0x40e00000,0x40e00000,0x40e00000,0x40e00000)

#line 10
ret 

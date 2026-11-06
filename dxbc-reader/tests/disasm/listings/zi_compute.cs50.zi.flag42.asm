cs_5_0
dcl_globalFlags refactoringAllowed
dcl_uav_typed_texture2d (float,float,float,float) u0
dcl_thread_group 1, 1, 1

#line 8 "C:\dx-fixtures\zi_compute.hlsl"
store_uav_typed u0.xyzw, l(0,0,0,0), l(-123.000000,-123.000000,-123.000000,-123.000000)

#line 9
store_uav_typed u0.xyzw, l(1,0,0,0), l(7.000000,7.000000,7.000000,7.000000)

#line 10
ret 

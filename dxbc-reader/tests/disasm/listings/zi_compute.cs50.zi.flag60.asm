0x00000000: cs_5_0
0x00000008: dcl_globalFlags refactoringAllowed
0x0000000C: dcl_uav_typed_texture2d (float,float,float,float) u0
0x0000001C: dcl_thread_group 1, 1, 1

#line 8 "C:\dx-fixtures\zi_compute.hlsl"
0x0000002C: store_uav_typed u0.xyzw, l(0,0,0,0), l(-123.000000,-123.000000,-123.000000,-123.000000)

#line 9
0x00000060: store_uav_typed u0.xyzw, l(1,0,0,0), l(7.000000,7.000000,7.000000,7.000000)

#line 10
0x00000094: ret 

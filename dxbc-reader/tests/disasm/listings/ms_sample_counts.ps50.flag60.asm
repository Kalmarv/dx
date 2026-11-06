0x00000000: ps_5_0
0x00000008: dcl_globalFlags refactoringAllowed
0x0000000C: dcl_resource_texture2dms(0) (float,float,float,float) t0
0x0000001C: dcl_resource_texture2dmsarray(0) (float,float,float,float) t1
0x0000002C: dcl_resource_texture2dms(0) (float,float,float,float) t2
0x0000003C: dcl_resource_texture2dmsarray(0) (float,float,float,float) t3
0x0000004C: dcl_resource_texture2dms(8) (float,float,float,float) t4
0x0000005C: dcl_resource_texture2dmsarray(4) (float,float,float,float) t5
0x0000006C: dcl_input_ps constant v0.xyz
0x00000078: dcl_output o0.xyzw
0x00000084: dcl_temps 3
0x0000008C: mov r0.xy, v0.xyxx
0x000000A0: mov r0.zw, l(0,0,0,0)
0x000000C0: ldms_indexable(texture2dms)(float,float,float,float) r0.xyzw, r0.xyzw, t0.xyzw, l(2)
0x000000EC: mov r1.xyz, v0.xyzx
0x00000100: mov r1.w, l(0)
0x00000114: ldms_indexable(texture2dmsarray)(float,float,float,float) r2.xyzw, r1.xyzw, t1.xyzw, l(3)
0x00000140: add r0.xyzw, r0.xyzw, r2.xyzw
0x0000015C: ldms_indexable(texture2dms)(float,float,float,float) r2.xyzw, r1.xyww, t2.xyzw, l(2)
0x00000188: add r0.xyzw, r0.xyzw, r2.xyzw
0x000001A4: ldms_indexable(texture2dmsarray)(float,float,float,float) r2.xyzw, r1.xyzw, t3.xyzw, l(3)
0x000001D0: add r0.xyzw, r0.xyzw, r2.xyzw
0x000001EC: ldms_indexable(texture2dms)(float,float,float,float) r2.xyzw, r1.xyww, t4.xyzw, l(2)
0x00000218: ldms_indexable(texture2dmsarray)(float,float,float,float) r1.xyzw, r1.xyzw, t5.xyzw, l(3)
0x00000244: add r0.xyzw, r0.xyzw, r2.xyzw
0x00000260: add o0.xyzw, r1.xyzw, r0.xyzw
0x0000027C: ret 

      ps_5_0
      dcl_globalFlags refactoringAllowed
      dcl_resource_texture2dms(0) (float,float,float,float) t0
      dcl_resource_texture2dmsarray(0) (float,float,float,float) t1
      dcl_resource_texture2dms(0) (float,float,float,float) t2
      dcl_resource_texture2dmsarray(0) (float,float,float,float) t3
      dcl_resource_texture2dms(8) (float,float,float,float) t4
      dcl_resource_texture2dmsarray(4) (float,float,float,float) t5
      dcl_input_ps constant v0.xyz
      dcl_output o0.xyzw
      dcl_temps 3
   0: mov r0.xy, v0.xyxx
   1: mov r0.zw, l(0,0,0,0)
   2: ldms_indexable(texture2dms)(float,float,float,float) r0.xyzw, r0.xyzw, t0.xyzw, l(2)
   3: mov r1.xyz, v0.xyzx
   4: mov r1.w, l(0)
   5: ldms_indexable(texture2dmsarray)(float,float,float,float) r2.xyzw, r1.xyzw, t1.xyzw, l(3)
   6: add r0.xyzw, r0.xyzw, r2.xyzw
   7: ldms_indexable(texture2dms)(float,float,float,float) r2.xyzw, r1.xyww, t2.xyzw, l(2)
   8: add r0.xyzw, r0.xyzw, r2.xyzw
   9: ldms_indexable(texture2dmsarray)(float,float,float,float) r2.xyzw, r1.xyzw, t3.xyzw, l(3)
  10: add r0.xyzw, r0.xyzw, r2.xyzw
  11: ldms_indexable(texture2dms)(float,float,float,float) r2.xyzw, r1.xyww, t4.xyzw, l(2)
  12: ldms_indexable(texture2dmsarray)(float,float,float,float) r1.xyzw, r1.xyzw, t5.xyzw, l(3)
  13: add r0.xyzw, r0.xyzw, r2.xyzw
  14: add o0.xyzw, r1.xyzw, r0.xyzw
  15: ret 

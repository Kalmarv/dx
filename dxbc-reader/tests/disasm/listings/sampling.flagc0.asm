ps_5_0
dcl_globalFlags refactoringAllowed
dcl_sampler s1, mode_default
dcl_sampler s2, mode_default
dcl_sampler s4, mode_comparison
dcl_resource_texture2d (float,float,float,float) t3
dcl_resource_texture2d (float,float,float,float) t4
dcl_resource_texture2darray (float,float,float,float) t5
dcl_resource_texture2d (float,float,float,float) t6
dcl_resource_texture2d (float,float,float,float) t9
dcl_resource_texture2d (float,float,float,float) t20
dcl_resource_buffer (float,float,float,float) t21
dcl_resource_raw t22
dcl_input_ps_siv linear noperspective v0.xy, position
dcl_input_ps linear v1.xy
dcl_input_ps constant v2.x
dcl_output o0.xyzw
dcl_temps 2
sample_indexable(texture2d)(float,float,float,float) r0.xyzw, v1.xyxx, t3.xyzw, s1
sample_l_indexable(texture2d)(float,float,float,float) r1.xyzw, v1.xyxx, t4.xyzw, s2, l(0x00000000)
add r0.xyzw, r0.xyzw, r1.xyzw
mov r1.xy, v1.xyxx
mov r1.z, l(0x00000000)
sample_b_indexable(texture2darray)(float,float,float,float) r1.xyzw, r1.xyzx, t5.xyzw, s1, l(0x3f800000)
add r0.xyzw, r0.xyzw, r1.xyzw
sample_c_indexable(texture2d)(float,float,float,float) r1.x, v1.xyxx, t6.xxxx, s4, l(0x3f000000)
add r0.xyzw, r0.xyzw, r1.xxxx
sample_c_lz_indexable(texture2d)(float,float,float,float) r1.x, v1.xyxx, t6.xxxx, s4, l(0x3f000000)
add r0.xyzw, r0.xyzw, r1.xxxx
gather4_indexable(texture2d)(float,float,float,float) r1.xyzw, v1.xyxx, t3.xyzw, s2.x
add r0.xyzw, r0.xyzw, r1.xyzw
gather4_c_indexable(texture2d)(float,float,float,float) r1.xyzw, v1.xyxx, t6.xyzw, s4.x, l(0x3f000000)
add r0.xyzw, r0.xyzw, r1.xyzw
deriv_rtx_coarse r1.xy, v1.xyxx
deriv_rty_coarse r1.zw, v1.xxxy
sample_d_indexable(texture2d)(float,float,float,float) r1.xyzw, v1.xyxx, t9.xyzw, s1, r1.xyxx, r1.zwzz
add r0.xyzw, r0.xyzw, r1.xyzw
ftoi r1.xy, v0.xyxx
mov r1.zw, l(0x00000000,0x00000000,0x00000000,0x00000000)
ld_indexable(texture2d)(float,float,float,float) r1.xyzw, r1.xyzw, t20.xyzw
add r0.xyzw, r0.xyzw, r1.xyzw
ld_indexable(buffer)(float,float,float,float) r1.xyzw, v2.xxxx, t21.xyzw
add r0.xyzw, r0.xyzw, r1.xyzw
ishl r1.x, v2.x, l(0x00000004)
ld_raw_indexable(raw_buffer)(mixed,mixed,mixed,mixed) r1.xyzw, r1.x, t22.xyzw
utof r1.xyzw, r1.xyzw
add r0.xyzw, r0.xyzw, r1.xyzw
lod r1.x, v1.xyxx, t3.x, s2
add o0.x, r0.x, r1.x
mov o0.yzw, r0.yyzw
ret 

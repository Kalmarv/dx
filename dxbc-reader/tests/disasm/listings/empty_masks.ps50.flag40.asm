ps_5_0
dcl_globalFlags refactoringAllowed
dcl_constantbuffer CB1[12], dynamicIndexed
dcl_sampler s3, mode_default
dcl_resource_texture2d (float,float,float,float) t3
dcl_resource_raw t5
dcl_uav_structured u1, 16
dcl_input_ps_siv linear noperspective v0., position
dcl_input_ps linear v1.
dcl_input_ps linear v2.
dcl_input_ps linear v3.
dcl_input_ps_sgv constant v4., is_front_face
dcl_output o0.
dcl_temps 2
dcl_indexrange v1. 3
dcl_indexableTemp x0[4], 4
mov x0[0]., v0.xyzw
mov x0[1]., v1.xyzw
mov x0[2]., v2.xyzw
mov x0[3]., v3.xyzw
and r0., cb1[11].x, l(3)
mov r1., x0[r0.x + 0].xyzw
mov r0., cb1[11].x
add r1., r1.xyzw, cb1[r0.y + 3].xyzw
mov x0[r0.x + 0]., r1.xyzw
iadd r0., cb1[11].x, l(1)
and r0., r0.x, l(3)
mov r0., x0[r0.x + 0].xyzw
udiv null, r1.x, cb1[11].x, l(3)
add r0., r0.xyzw, v[r1.x + 1].xyzw
sample_indexable(texture2d)(float,float,float,float) r1., v0.xyxx, t3.xyzw, s3
add r0., r0.xyzw, r1.xyzw
ishl r1., cb1[11].x, l(2)
ld_raw_indexable(raw_buffer)(mixed,mixed,mixed,mixed) r1., r1.x, t5.xxxx
add r0., r0.xyzw, r1.xxxx
store_structured u1., cb1[11].x, l(0), r0.xyzw
movc o0., v4.xxxx, r0.xyzw, -r0.xyzw
ret 

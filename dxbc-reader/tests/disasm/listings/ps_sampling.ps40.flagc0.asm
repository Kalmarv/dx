ps_4_0
dcl_immediateConstantBuffer { { 0x3f800000, 0x00000000, 0x00000000, 0x3f800000},
                              { 0x00000000, 0x3f800000, 0x00000000, 0x3f800000},
                              { 0x00000000, 0x00000000, 0x3f800000, 0x3f800000},
                              { 0x3f000000, 0x3e800000, 0x322bcc77, 0xe0ad78ec},
                              { 0x7f7fffff, 0x00000000, 0x3eaaaaab, 0x47c35000},
                              { 0x7f800000, 0xff800000, 0x00000000, 0x00000000},
                              { 0x00000001, 0x00000000, 0x00000000, 0x00000000},
                              { 0xffffffff, 0x00000000, 0x00000000, 0x00000000},
                              { 0x80000000, 0x00000000, 0x00000000, 0x00000000},
                              { 0x00bc614e, 0x00000000, 0x00000000, 0x00000000},
                              { 0x00002710, 0x00000000, 0x00000000, 0x00000000} }
dcl_constantbuffer CB0[3], immediateIndexed
dcl_sampler s0, mode_default
dcl_sampler s1, mode_comparison
dcl_sampler s3, mode_default
dcl_resource_texture1d (float,float,float,float) t0
dcl_resource_texture1darray (float,float,float,float) t1
dcl_resource_texture2d (float,float,float,float) t2
dcl_resource_texture2darray (float,float,float,float) t3
dcl_resource_texture3d (float,float,float,float) t4
dcl_resource_texturecube (float,float,float,float) t5
dcl_resource_texture2dms(4) (float,float,float,float) t6
dcl_resource_buffer (sint,sint,sint,sint) t7
dcl_resource_texture2d (uint,uint,uint,uint) t8
dcl_resource_texture2dmsarray(2) (snorm,snorm,snorm,snorm) t9
dcl_resource_texture2d (unorm,unorm,unorm,unorm) t10
dcl_input_ps_siv linear noperspective v0.z, position
dcl_input_ps linear v1.xyzw
dcl_input_ps constant v2.xyzw
dcl_input_ps linear noperspective v3.xy
dcl_input_ps linear centroid v4.x
dcl_input_ps_sgv constant v5.x, primitive_id
dcl_input_ps_sgv constant v6.x, is_front_face
dcl_output o0.xyzw
dcl_output o2.xyzw
dcl_output o3.x
dcl_output oDepth
dcl_temps 6
sample r0.xyzw, v1.xxxx, t0.xyzw, s0
sample_l r1.xyzw, v1.xyxx, t1.xyzw, s0, l(0x40000000)
add r0.xyzw, r0.xyzw, r1.xyzw
sample_aoffimmi(1,-2,0) r1.xyzw, v1.xyxx, t2.xyzw, s0
add r0.xyzw, r0.xyzw, r1.xyzw
sample_b r1.xyzw, v1.xyzx, t3.xyzw, s0, cb0[0].x
deriv_rtx r2.xyz, v1.xyzx
deriv_rty r3.xyz, v1.xyzx
sample_d r2.xyzw, v1.xyzx, t4.xyzw, s0, r2.xyzx, r3.xyzx
add r1.xyzw, r1.xyzw, r2.xyzw
add r0.xyzw, r0.xyzw, r1.xyzw
sample r1.xyzw, v1.xyzx, t5.xyzw, s3
add r0.xyzw, r0.xyzw, r1.xyzw
sample_c r1.x, v1.xyxx, t2.xxxx, s1, cb0[0].y
sample_c_lz_aoffimmi(3,4,0) r1.y, v1.zwzz, t2.xxxx, s1, cb0[0].z
add r1.x, r1.y, r1.x
add r0.x, r0.x, r1.x
mov r1.xy, v2.xyxx
mov r1.zw, l(0x00000000,0x00000000,0x00000000,0x00000000)
ldms r1.xyzw, r1.xyzw, t6.xyzw, l(0x00000003)
mov r2.xyz, v2.xyzx
mov r2.w, l(0x00000000)
ldms r3.xyzw, r2.xyzw, t9.xyzw, l(0x00000001)
add r1.xyzw, r1.xyzw, r3.xyzw
ld_aoffimmi(-1,1,0) r3.xyzw, r2.xyww, t10.xyzw
add r1.xyzw, r1.xyzw, r3.xyzw
add r0.xyzw, r0.xyzw, r1.xyzw
ld r1.xyzw, v2.xyww, t2.xyzw
ld r3.xyzw, v2.xyzw, t4.xyzw
add r1.xyzw, r1.xyzw, r3.xyzw
add r0.xyzw, r0.xyzw, r1.xyzw
resinfo_uint r1.xyzw, l(0x00000001), t2.xyzw
resinfo r3.xyzw, l(0x00000000), t10.xyzw
utof r1.xyz, r1.xywx
mad r1.xy, r1.xyxx, r1.zzzz, r3.xyxx
add r0.xy, r0.xyxx, r1.xyxx
and r1.x, v2.x, l(0x80000000)
imax r1.y, v2.x, -v2.x
udiv null, r1.y, r1.y, l(0x00000006)
ineg r1.z, r1.y
movc r1.x, r1.x, r1.z, r1.y
mov r1.y, cb0[1].y
mad r0.xyzw, icb[r1.x + 0].xyzw, icb[r1.y + 0].xyzw, r0.xyzw
ld r1.xyzw, v2.xxxx, t7.xyzw
ld r2.xyzw, r2.yzww, t8.xyzw
iadd r1.xy, r1.xyxx, r2.xyxx
mov r1.zw, r1.xxxy
mov r3.x, cb0[1].z
mov r2.xyzw, r0.xyzw
mov r3.y, l(0x00000000)
loop 
  ige r3.z, r3.y, cb0[1].x
  breakc_nz r3.z
  itof r3.z, r3.y
  lt r3.z, r3.z, r2.x
  if_nz r3.z
    break 
  endif 
  mad r4.xyzw, r2.xyzw, l(0x3f000000, 0x3f000000, 0x3f000000, 0x3f000000), l(0x3e800000, 0x3e800000, 0x3e800000, 0x3e800000)
  ieq r3.z, r3.x, r3.y
  if_nz r3.z
    iadd r3.z, r3.y, l(0x00000001)
    mov r2.xyzw, r4.xyzw
    mov r3.y, r3.z
    continue 
  endif 
  iadd r1.zw, r1.zzzw, r3.yyyy
  mov r2.xyzw, r4.xyzw
  iadd r3.y, r3.y, l(0x00000001)
endloop 
mov o2.xy, r1.zwzz
switch cb0[1].w
  case l(0x00000000)
  mov r2.x, l(0x3f800000)
  break 
  case l(0x00000003)
  mov r2.y, l(0x40000000)
  break 
  case l(0x00000007)
  mov r2.z, l(0x40400000)
  break 
  default 
  mov r2.w, l(0xc0800000)
  break 
endswitch 
lt r0.x, r2.w, l(0xc47a0000)
discard_nz r0.x
xor r0.x, r2.y, cb0[2].x
ishl r0.y, r0.x, l(0x00000003)
ushr r0.x, r0.x, cb0[2].y
not r0.z, cb0[2].z
and r0.x, r0.z, r0.x
or r0.x, r0.x, r0.y
udiv null, r0.y, v5.x, l(0x00000005)
iadd r0.x, r0.x, icb[r0.y + 6].x
udiv r0.y, null, r0.x, cb0[2].w
iadd r0.z, cb0[2].w, l(0x00000001)
udiv null, r0.x, r0.x, r0.z
iadd r0.x, r0.x, r0.y
ishr r0.y, r0.x, l(0x00000002)
imin r0.z, r0.x, cb0[1].y
imad r0.y, r0.y, cb0[1].x, r0.z
imax r0.z, r0.x, -cb0[1].z
iadd r0.y, -r0.z, r0.y
imax r0.z, -r0.x, r0.x
iadd r0.y, r0.z, r0.y
xor r0.w, r0.x, cb0[1].w
imax r1.x, cb0[1].w, -cb0[1].w
udiv r0.z, null, r0.z, r1.x
ineg r1.x, r0.z
and r0.w, r0.w, l(0x80000000)
movc r0.z, r0.w, r1.x, r0.z
iadd o2.z, -r0.z, r0.y
movc r1.xyzw, v6.xxxx, r2.xyzw, -r2.wzyx
and r3.xyzw, r1.xyzw, l(0x7fffffff, 0x7fffffff, 0x7fffffff, 0x7fffffff)
ieq r3.xyzw, r3.xyzw, l(0x7f800000, 0x7f800000, 0x7f800000, 0x7f800000)
movc r1.xyzw, r3.xyzw, l(0x3f800000,0x3f800000,0x3f800000,0x3f800000), r1.xyzw
sincos r3.xyzw, null, r2.xyzw
sincos null, r4.xyzw, r2.yxwz
rsq r5.xyzw, |r2.xyzw|
mad r3.xyzw, r3.xyzw, r4.xyzw, r5.xyzw
exp r4.xyzw, r2.xyzw
add r3.xyzw, r3.xyzw, r4.xyzw
log r4.xyzw, |r2.xyzw|
add r3.xyzw, r3.xyzw, r4.xyzw
frc r4.xyzw, r2.xyzw
add r3.xyzw, r3.xyzw, r4.xyzw
round_ne r4.xyzw, r2.xyzw
add r3.xyzw, r3.xyzw, r4.xyzw
round_ni r4.xyzw, r2.xyzw
add r3.xyzw, r3.xyzw, r4.xyzw
round_pi r4.xyzw, r2.xyzw
add r3.xyzw, r3.xyzw, r4.xyzw
round_z r4.xyzw, r2.xyzw
add r3.xyzw, r3.xyzw, r4.xyzw
add r1.xyzw, r1.xyzw, r3.xyzw
mad r3.xyzw, v3.xyxy, v4.xxxx, r1.xyzw
mad r1.xyzw, r2.xyzw, cb0[0].xyzw, r1.xyzw
add_sat r1.xyzw, r1.xyzw, r3.xyzw
div r3.xyzw, l(0x3f800000, 0x3f800000, 0x3f800000, 0x3f800000), r2.xyzw
add r1.xyzw, r1.xyzw, r3.xyzw
sqrt r3.xyzw, |r2.xyzw|
add o0.xyzw, r1.xyzw, r3.xyzw
ftoi o2.w, v1.z
ftou r0.y, v1.w
iadd o3.x, r0.y, r0.x
mad_sat oDepth, r2.x, l(0x358637bd), v0.z
ret 

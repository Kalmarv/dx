ps_5_0
dcl_globalFlags refactoringAllowed
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
dcl_resource_texture2dmsarray(0) (snorm,snorm,snorm,snorm) t9
dcl_resource_texture2d (unorm,unorm,unorm,unorm) t10
dcl_resource_texturecubearray (float,float,float,float) t11
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
//
// Initial variable locations:
//   v0.x <- p.pos.x; v0.y <- p.pos.y; v0.z <- p.pos.z; v0.w <- p.pos.w; 
//   v1.x <- p.uv.x; v1.y <- p.uv.y; v1.z <- p.uv.z; v1.w <- p.uv.w; 
//   v2.x <- p.i.x; v2.y <- p.i.y; v2.z <- p.i.z; v2.w <- p.i.w; 
//   v3.x <- p.np.x; v3.y <- p.np.y; 
//   v4.x <- p.c; 
//   v5.x <- p.prim; 
//   v6.x <- p.front; 
//   oDepth <- <main return value>.d; 
//   o3.x <- <main return value>.c; 
//   o2.z <- <main return value>.b.z; o2.w <- <main return value>.b.w; 
//   o0.x <- <main return value>.a.x; o0.y <- <main return value>.a.y; o0.z <- <main return value>.a.z; o0.w <- <main return value>.a.w; 
//   o2.x <- b.x; o2.y <- b.y
//
#line 52 "C:\dx-fixtures\ps_sampling.hlsl"
sample_indexable(texture1d)(float,float,float,float) r0.xyzw, v1.xxxx, t0.xyzw, s0
sample_l_indexable(texture1darray)(float,float,float,float) r1.xyzw, v1.xyxx, t1.xyzw, s0, l(0x40000000)
add r0.xyzw, r0.xyzw, r1.xyzw
sample_aoffimmi_indexable(1,-2,0)(texture2d)(float,float,float,float) r1.xyzw, v1.xyxx, t2.xyzw, s0
add r0.xyzw, r0.xyzw, r1.xyzw  // r0.x <- c.x; r0.y <- c.y; r0.z <- c.z; r0.w <- c.w

#line 53
sample_b_indexable(texture2darray)(float,float,float,float) r1.xyzw, v1.xyzx, t3.xyzw, s0, cb0[0].x
deriv_rtx_coarse r2.xyz, v1.xyzx
deriv_rty_coarse r3.xyz, v1.xyzx
sample_d_indexable(texture3d)(float,float,float,float) r2.xyzw, v1.xyzx, t4.xyzw, s0, r2.xyzx, r3.xyzx
add r1.xyzw, r1.xyzw, r2.xyzw
add r0.xyzw, r0.xyzw, r1.xyzw

#line 54
sample_indexable(texturecube)(float,float,float,float) r1.xyzw, v1.xyzx, t5.xyzw, s3
add r0.xyzw, r0.xyzw, r1.xyzw

#line 55
sample_c_indexable(texture2d)(float,float,float,float) r1.x, v1.xyxx, t2.xxxx, s1, cb0[0].y
sample_c_lz_aoffimmi_indexable(3,4,0)(texture2d)(float,float,float,float) r1.y, v1.zwzz, t2.xxxx, s1, cb0[0].z
add r1.x, r1.y, r1.x
add r0.x, r0.x, r1.x

#line 56
mov r1.xy, v2.xyxx
mov r1.zw, l(0x00000000,0x00000000,0x00000000,0x00000000)
ldms_indexable(texture2dms)(float,float,float,float) r1.xyzw, r1.xyzw, t6.xyzw, v2.z
mov r2.xyz, v2.xyzx
mov r2.w, l(0x00000000)
ldms_indexable(texture2dmsarray)(snorm,snorm,snorm,snorm) r4.xyzw, r2.xyzw, t9.xyzw, l(0x00000001)
add r1.xyzw, r1.xyzw, r4.xyzw
ld_aoffimmi_indexable(-1,1,0)(texture2d)(unorm,unorm,unorm,unorm) r4.xyzw, r2.xyww, t10.xyzw
add r1.xyzw, r1.xyzw, r4.xyzw
add r0.xyzw, r0.xyzw, r1.xyzw

#line 57
ld_indexable(texture2d)(float,float,float,float) r1.xyzw, v2.xyww, t2.xyzw
ld_indexable(texture3d)(float,float,float,float) r4.xyzw, v2.xyzw, t4.xyzw
add r1.xyzw, r1.xyzw, r4.xyzw
add r0.xyzw, r0.xyzw, r1.xyzw

#line 59
resinfo_indexable(texture2d)(float,float,float,float)_uint r1.xyz, l(0x00000001), t2.xywz  // r1.x <- w; r1.y <- h; r1.z <- levels

#line 61
resinfo_indexable(texture2d)(unorm,unorm,unorm,unorm) r3.xz, l(0x00000000), t10.xzyw  // r3.x <- fw; r3.z <- fh

#line 62
utof r1.xyz, r1.xyzx
mad r1.xy, r1.xyxx, r1.zzzz, r3.xzxx
add r0.xy, r0.xyxx, r1.xyxx

#line 63
and r1.x, v2.x, l(0x80000000)
imax r1.y, v2.x, -v2.x
udiv null, r1.y, r1.y, l(0x00000006)
ineg r1.z, r1.y
movc r1.x, r1.x, r1.z, r1.y
mov r1.y, cb0[1].y
mad r0.xyzw, icb[r1.x + 0].xyzw, icb[r1.y + 0].xyzw, r0.xyzw

#line 65
sample_l_indexable(texturecubearray)(float,float,float,float) r1.xyzw, v1.xyzw, t11.xyzw, s0, l(0x00000000)
add r0.xyzw, r0.xyzw, r1.xyzw

#line 66
lod r1.x, v1.xyxx, t2.x, s0
add r0.xyzw, r0.xyzw, r1.xxxx

#line 69
gather4_indexable(texture2d)(float,float,float,float) r1.xyzw, v1.xyxx, t2.xyzw, s0.x
gather4_aoffimmi_indexable(1,1,0)(texture2d)(float,float,float,float) r4.xyzw, v1.xyxx, t2.xyzw, s0.x
add r1.xyzw, r1.xyzw, r4.xyzw
gather4_po_indexable(texture2d)(float,float,float,float) r4.xyzw, v1.xyxx, v2.zwzz, t2.xyzw, s0.y
add r1.xyzw, r1.xyzw, r4.xyzw
add r0.xyzw, r0.xyzw, r1.xyzw

#line 70
gather4_c_indexable(texture2d)(float,float,float,float) r1.xyzw, v1.xyxx, t2.xyzw, s1.x, cb0[0].w
gather4_po_c_indexable(texture2d)(float,float,float,float) r4.xyzw, v1.xyxx, v2.xyxx, t2.xyzw, s1.z, cb0[0].x
add r1.xyzw, r1.xyzw, r4.xyzw
add r0.xyzw, r0.xyzw, r1.xyzw

#line 72
sample_cl_s_indexable(texture2d)(float,float,float,float) r1.xyzw, r2.x, v1.xyxx, t2.xyzw, s0, l(0x3fc00000)
check_access_fully_mapped r2.x, r2.x  // r2.x <- status
add r0.xyzw, r0.xyzw, r1.xyzw

#line 73
movc r1.x, r2.x, l(0x3f800000), l(0x00000000)
add r0.w, r0.w, r1.x

#line 74
deriv_rtx_fine r1.x, v1.x
add r1.x, r3.y, r1.x
add r0.x, r0.x, r1.x

#line 76
ld_indexable(buffer)(sint,sint,sint,sint) r1.xy, v2.xxxx, t7.xyzw
ld_indexable(texture2d)(uint,uint,uint,uint) r1.zw, r2.yzww, t8.zwxy
iadd r1.xy, r1.zwzz, r1.xyxx  // r1.x <- b.x; r1.y <- b.y

#line 77
mov r1.zw, r1.xxxy  // r1.z <- b.x; r1.w <- b.y
mov r3.x, cb0[1].z  // r3.x <- n.z
mov r2.xyzw, r0.xyzw  // r2.x <- c.x; r2.y <- c.y; r2.z <- c.z; r2.w <- c.w
mov r3.y, l(0x00000000)  // r3.y <- i
loop 
  ige r3.z, r3.y, cb0[1].x
  breakc_nz r3.z

#line 78
  itof r3.z, r3.y
  lt r3.z, r3.z, r2.x
  if_nz r3.z
    break 
  endif 

#line 79
  mad r4.xyzw, r2.xyzw, l(0x3f000000, 0x3f000000, 0x3f000000, 0x3f000000), l(0x3e800000, 0x3e800000, 0x3e800000, 0x3e800000)  // r4.x <- c.x; r4.y <- c.y; r4.z <- c.z; r4.w <- c.w

#line 80
  ieq r3.z, r3.x, r3.y
  if_nz r3.z
    iadd r3.z, r3.y, l(0x00000001)  // r3.z <- i
    mov r2.xyzw, r4.xyzw  // r2.x <- c.x; r2.y <- c.y; r2.z <- c.z; r2.w <- c.w
    mov r3.y, r3.z  // r3.y <- i
    continue 
  endif   // r4.x <- c.x; r4.y <- c.y; r4.z <- c.z; r4.w <- c.w

#line 81
  iadd r1.zw, r1.zzzw, r3.yyyy
  mov r2.xyzw, r4.xyzw  // r2.x <- c.x; r2.y <- c.y; r2.z <- c.z; r2.w <- c.w

#line 77
  iadd r3.y, r3.y, l(0x00000001)

#line 82
endloop 
mov o2.xy, r1.zwzz

#line 83
switch cb0[1].w

#line 84
  case l(0x00000000)
  mov r2.x, l(0x3f800000)
  break   // r2.x <- c.x

#line 85
  case l(0x00000003)
  mov r2.y, l(0x40000000)
  break   // r2.y <- c.y

#line 86
  case l(0x00000007)
  mov r2.z, l(0x40400000)
  break   // r2.z <- c.z

#line 87
  default 
  mov r2.w, l(0xc0800000)
  break   // r2.w <- c.w

#line 88
endswitch 

#line 89
lt r0.x, r2.w, l(0xc47a0000)
discard_nz r0.x

#line 90
xor r0.x, r2.y, cb0[2].x  // r0.x <- x

#line 91
ishl r0.y, r0.x, l(0x00000003)
ushr r0.x, r0.x, cb0[2].y
not r0.z, cb0[2].z
and r0.x, r0.z, r0.x
or r0.x, r0.x, r0.y  // r0.x <- x

#line 92
udiv null, r0.y, v5.x, l(0x00000005)
iadd r0.x, r0.x, icb[r0.y + 6].x

#line 94
bfrev r0.y, r0.x
countbits r0.z, r0.x
iadd r0.y, r0.z, r0.y
firstbit_hi r0.z, r0.x
iadd r0.z, -r0.z, l(0x0000001f)
movc r0.z, r0.x, r0.z, l(0xffffffff)
iadd r0.y, r0.z, r0.y
firstbit_lo r0.z, r0.x
iadd r0.y, r0.z, r0.y
firstbit_shi r0.z, r0.x
ieq r0.w, r0.z, l(0xffffffff)
iadd r0.z, -r0.z, l(0x0000001f)
movc r0.z, r0.w, l(0xffffffff), r0.z
iadd r0.y, r0.z, r0.y
iadd r0.x, r0.y, r0.x

#line 95
f32tof16 r0.y, r2.x
f16tof32 r0.z, r0.x
ftou r0.z, r0.z
iadd r0.y, r0.z, r0.y
iadd r0.x, r0.y, r0.x

#line 97
udiv r0.y, null, r0.x, cb0[2].w
iadd r0.z, cb0[2].w, l(0x00000001)
udiv null, r0.x, r0.x, r0.z
iadd r0.x, r0.x, r0.y  // r0.x <- x

#line 99
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

#line 100
movc r1.xyzw, v6.xxxx, r2.xyzw, -r2.wzyx  // r1.x <- o.a.x; r1.y <- o.a.y; r1.z <- o.a.z; r1.w <- o.a.w

#line 101
and r3.xyzw, r1.xyzw, l(0x7fffffff, 0x7fffffff, 0x7fffffff, 0x7fffffff)
ieq r3.xyzw, r3.xyzw, l(0x7f800000, 0x7f800000, 0x7f800000, 0x7f800000)
movc r1.xyzw, r3.xyzw, l(0x3f800000,0x3f800000,0x3f800000,0x3f800000), r1.xyzw

#line 102
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

#line 103
mad r3.xyzw, v3.xyxy, v4.xxxx, r1.xyzw
mad r1.xyzw, r2.xyzw, cb0[0].xyzw, r1.xyzw
add_sat r1.xyzw, r1.xyzw, r3.xyzw
rcp r3.xyzw, r2.xyzw
add r1.xyzw, r1.xyzw, r3.xyzw
sqrt r3.xyzw, |r2.xyzw|
add o0.xyzw, r1.xyzw, r3.xyzw

#line 104
ftoi o2.w, v1.z

#line 105
ftou r0.y, v1.w
iadd o3.x, r0.y, r0.x

#line 106
mad_sat oDepth, r2.x, l(0x358637bd), v0.z

#line 107
ret 

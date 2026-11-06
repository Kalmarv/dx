ps_4_1
dcl_globalFlags refactoringAllowed | skipOptimization
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
dcl_indexableTemp x0[6], 4
dcl_indexableTemp x1[5], 4
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
//   o2.x <- <main return value>.b.x; o2.y <- <main return value>.b.y; o2.z <- <main return value>.b.z; o2.w <- <main return value>.b.w; 
//   o0.x <- <main return value>.a.x; o0.y <- <main return value>.a.y; o0.z <- <main return value>.a.z; o0.w <- <main return value>.a.w
//
#line 44 "C:\dx-fixtures\ps_sampling.hlsl"
itof r0.xyzw, l(0x00000001, 0x00000000, 0x00000000, 0x00000001)
itof r1.xyzw, l(0x00000000, 0x00000001, 0x00000000, 0x00000001)
itof r2.xyzw, l(0x00000000, 0x00000000, 0x00000001, 0x00000001)
itof r3.yw, l(0x00000000, 0x00000000, 0x00000000, 0x000186a0)
mov r4.x, l(0x7f800000)
mov r4.y, l(0xff800000)
mov r4.z, l(0x00000001)
mov r4.w, l(0x80000001)
mov x0[0].xyzw, r0.xyzw
mov x0[1].xyzw, r1.xyzw
mov x0[2].xyzw, r2.xyzw
mov x0[3].xyzw, l(0x3f000000,0x3e800000,0x322bcc77,0xe0ad78ec)
mov r3.xz, l(0x7f7fffff,0x00000000,0x3eaaaaab,0x00000000)
mov x0[4].xyzw, r3.xyzw
mov x0[5].xyzw, r4.xyzw

#line 45
mov r0.xyz, l(0x00000001,0x00bc614e,0x00002710,0x00000000)
mov x1[0].x, r0.x
mov x1[1].x, l(0xffffffff)
mov x1[2].x, l(0x80000000)
mov x1[3].x, r0.y
mov x1[4].x, r0.z

#line 52
sample r0.xyzw, v1.xxxx, t0.xyzw, s0
itof r1.x, l(0x00000002)
sample_l r1.xyzw, v1.xyxx, t1.xyzw, s0, r1.x
add r0.xyzw, r0.xyzw, r1.xyzw
sample_aoffimmi(1,-2,0) r1.xyzw, v1.xyxx, t2.xyzw, s0
add r0.xyzw, r0.xyzw, r1.xyzw  // r0.x <- c.x; r0.y <- c.y; r0.z <- c.z; r0.w <- c.w

#line 53
sample_b r1.xyzw, v1.xyzx, t3.xyzw, s0, cb0[0].x
deriv_rtx r2.xyz, v1.xyzx
deriv_rty r3.xyz, v1.xyzx
sample_d r2.xyzw, v1.xyzx, t4.xyzw, s0, r2.xyzx, r3.xyzx
add r1.xyzw, r1.xyzw, r2.xyzw
add r0.xyzw, r0.xyzw, r1.xyzw

#line 54
sample r1.xyzw, v1.xyzx, t5.xyzw, s3
add r0.xyzw, r0.xyzw, r1.xyzw

#line 55
sample_c r1.x, v1.xyxx, t2.xxxx, s1, cb0[0].y
sample_c_lz_aoffimmi(3,4,0) r1.y, v1.zwzz, t2.xxxx, s1, cb0[0].z
add r1.x, r1.y, r1.x
add r0.x, r0.x, r1.x

#line 56
mov r1.xy, v2.xyxx
mov r1.zw, l(0x00000000,0x00000000,0x00000000,0x00000000)
ldms r1.xyzw, r1.xyzw, t6.xyzw, v2.z
mov r2.xyz, v2.xyzx
mov r2.w, l(0x00000000)
ldms r3.xyzw, r2.xyzw, t9.xyzw, l(0x00000001)
add r1.xyzw, r1.xyzw, r3.xyzw
ld_aoffimmi(-1,1,0) r3.xyzw, r2.xyww, t10.xyzw
add r1.xyzw, r1.xyzw, r3.xyzw
add r0.xyzw, r0.xyzw, r1.xyzw

#line 57
ld r1.xyzw, v2.xyww, t2.xyzw
ld r3.xyzw, v2.xyzw, t4.xyzw
add r1.xyzw, r1.xyzw, r3.xyzw
add r0.xyzw, r0.xyzw, r1.xyzw

#line 59
resinfo_uint r1.xyz, l(0x00000001), t2.xywz
mov r1.x, r1.x  // r1.x <- w
mov r1.y, r1.y  // r1.y <- h
mov r1.z, r1.z  // r1.z <- levels

#line 61
resinfo r3.xy, l(0x00000000), t10.xyzw
mov r3.x, r3.x  // r3.x <- fw
mov r3.y, r3.y  // r3.y <- fh

#line 62
utof r4.x, r1.x
utof r4.y, r1.y
utof r1.xy, r1.zzzz
mul r1.xy, r1.xyxx, r4.xyxx
add r1.xy, r3.xyxx, r1.xyxx
add r0.xy, r0.xyxx, r1.xyxx

#line 63
ineg r1.x, v2.x
ineg r1.y, l(0x00000006)
and r1.z, v2.x, l(0x80000000)
imax r1.x, r1.x, v2.x
imax r1.y, r1.y, l(0x00000006)
udiv null, r1.x, r1.x, r1.y
ineg r1.y, r1.x
ine r1.z, l(0x00000000, 0x00000000, 0x00000000, 0x00000000), r1.z
movc r1.x, r1.z, r1.y, r1.x
mov r1.xyzw, x0[r1.x + 0].xyzw
mov r2.x, cb0[1].y
mov r3.xyzw, x0[r2.x + 0].xyzw
mul r1.xyzw, r1.xyzw, r3.xyzw
add r0.xyzw, r0.xyzw, r1.xyzw

#line 65
itof r1.x, l(0x00000000)
sample_l r1.xyzw, v1.xyzw, t11.xyzw, s0, r1.x
add r0.xyzw, r0.xyzw, r1.xyzw

#line 66
lod r1.x, v1.xyxx, t2.x, s0
add r0.xyzw, r0.xyzw, r1.xxxx

#line 76
ld r1.xy, v2.xxxx, t7.xyzw
ld r1.zw, r2.yzww, t8.zwxy
iadd r1.xy, r1.zwzz, r1.xyxx  // r1.x <- b.x; r1.y <- b.y

#line 77
mov r1.z, l(0x00000000)  // r1.z <- i
mov r2.yzw, r0.yyzw  // r2.y <- c.y; r2.z <- c.z; r2.w <- c.w
mov r3.xy, r1.xyxx  // r3.x <- b.x; r3.y <- b.y
mov r1.w, cb0[1].z  // r1.w <- n.z
mov r2.x, r0.x  // r2.x <- c.x
mov r4.x, r1.z  // r4.x <- i
loop 
  ilt r4.y, r4.x, cb0[1].x
  breakc_z r4.y

#line 78
  itof r4.y, r4.x
  lt r4.y, r4.y, r2.x
  if_nz r4.y
    mov r4.y, r2.x  // r4.y <- c.x
    mov r2.x, r4.y  // r2.x <- c.x
    break 
  endif 

#line 79
  mul r5.xyzw, r2.xyzw, l(0x3f000000, 0x3f000000, 0x3f000000, 0x3f000000)
  add r5.xyzw, r5.xyzw, l(0x3e800000, 0x3e800000, 0x3e800000, 0x3e800000)  // r5.x <- c.x; r5.y <- c.y; r5.z <- c.z; r5.w <- c.w

#line 80
  ieq r4.y, r1.w, r4.x
  if_nz r4.y
    iadd r4.x, r4.x, l(0x00000001)
    mov r2.yzw, r5.yyzw  // r2.y <- c.y; r2.z <- c.z; r2.w <- c.w
    mov r2.x, r5.x  // r2.x <- c.x
    continue 
  endif   // r5.x <- c.x; r5.y <- c.y; r5.z <- c.z; r5.w <- c.w

#line 81
  iadd r3.xy, r3.xyxx, r4.xxxx
  mov r2.yzw, r5.yyzw  // r2.y <- c.y; r2.z <- c.z; r2.w <- c.w
  mov r2.x, r5.x  // r2.x <- c.x

#line 77
  iadd r4.x, r4.x, l(0x00000001)

#line 82
endloop 

#line 83
mov r0.x, cb0[1].w
switch r0.x

#line 84
  case l(0x00000000)
  itof r2.x, l(0x00000001)
  break 

#line 85
  case l(0x00000003)
  itof r2.y, l(0x00000002)
  mov r2.xyzw, r2.xyzw
  break 

#line 86
  case l(0x00000007)
  itof r2.z, l(0x00000003)
  mov r2.xyzw, r2.xyzw
  break 

#line 87
  default 
  itof r2.w, l(0xfffffffc)
  mov r2.xyzw, r2.xyzw
  break 

#line 88
endswitch 

#line 89
itof r0.x, l(0xfffffc18)
lt r0.x, r2.w, r0.x
if_nz r0.x
  discard_nz l(0xffffffff)
endif 

#line 90
xor r0.x, r2.y, cb0[2].x  // r0.x <- x

#line 91
mov r0.y, l(0x00000003)
ishl r0.y, r0.x, r0.y
ushr r0.x, r0.x, cb0[2].y
not r0.z, cb0[2].z
and r0.x, r0.z, r0.x
or r0.x, r0.x, r0.y  // r0.x <- x

#line 92
mov r0.y, l(0x00000005)
udiv null, r0.y, v5.x, r0.y
mov r0.y, x1[r0.y + 0].x
iadd r0.x, r0.y, r0.x

#line 97
udiv r0.y, null, r0.x, cb0[2].w
mov r0.z, l(0x00000001)
iadd r0.z, r0.z, cb0[2].w
udiv null, r0.x, r0.x, r0.z
iadd r0.x, r0.x, r0.y  // r0.x <- x

#line 98
mov r0.x, r0.x  // r0.x <- sx

#line 99
ishr r0.y, r0.x, l(0x00000002)
imul null, r0.y, r0.y, cb0[1].x
imin r0.z, r0.x, cb0[1].y
iadd r0.y, r0.z, r0.y
ineg r0.z, r1.w
imax r0.z, r0.z, r0.x
ineg r0.z, r0.z
iadd r0.y, r0.z, r0.y
ineg r0.z, r0.x
imax r0.z, r0.z, r0.x
iadd r0.y, r0.z, r0.y
ineg r0.z, r0.x
ineg r0.w, cb0[1].w
xor r1.x, r0.x, cb0[1].w
imax r0.z, r0.x, r0.z
imax r0.w, r0.w, cb0[1].w
udiv r0.z, null, r0.z, r0.w
ineg r0.w, r0.z
and r1.x, r1.x, l(0x80000000)
ine r1.x, l(0x00000000, 0x00000000, 0x00000000, 0x00000000), r1.x
movc r0.z, r1.x, r0.w, r0.z
ineg r0.z, r0.z
iadd r3.z, r0.z, r0.y  // r3.z <- sx

#line 100
mov r1.xyzw, -r2.wzyx
movc r1.xyzw, v6.xxxx, r2.xyzw, r1.xyzw  // r1.x <- o.a.x; r1.y <- o.a.y; r1.z <- o.a.z; r1.w <- o.a.w

#line 101
and r4.xyzw, r1.xyzw, l(0x7fffffff, 0x7fffffff, 0x7fffffff, 0x7fffffff)
ieq r4.xyzw, r4.xyzw, l(0x7f800000, 0x7f800000, 0x7f800000, 0x7f800000)
itof r5.xyzw, l(0x00000001, 0x00000001, 0x00000001, 0x00000001)
movc r1.xyzw, r4.xyzw, r5.xyzw, r1.xyzw

#line 102
sincos r4.xyzw, null, r2.xyzw
sincos null, r5.xyzw, r2.yxwz
mul r4.xyzw, r4.xyzw, r5.xyzw
mov r5.xyzw, -r2.xyzw
max r5.xyzw, r2.xyzw, r5.xyzw
rsq r5.xyzw, r5.xyzw
add r4.xyzw, r4.xyzw, r5.xyzw
exp r5.xyzw, r2.xyzw
add r4.xyzw, r4.xyzw, r5.xyzw
mov r5.xyzw, -r2.xyzw
max r5.xyzw, r2.xyzw, r5.xyzw
log r5.xyzw, r5.xyzw
add r4.xyzw, r4.xyzw, r5.xyzw
frc r5.xyzw, r2.xyzw
add r4.xyzw, r4.xyzw, r5.xyzw
round_ne r5.xyzw, r2.xyzw
add r4.xyzw, r4.xyzw, r5.xyzw
round_ni r5.xyzw, r2.xyzw
add r4.xyzw, r4.xyzw, r5.xyzw
round_pi r5.xyzw, r2.xyzw
add r4.xyzw, r4.xyzw, r5.xyzw
round_z r5.xyzw, r2.xyzw
add r4.xyzw, r4.xyzw, r5.xyzw
add r1.xyzw, r1.xyzw, r4.xyzw

#line 103
mul r4.xyzw, v3.xyxy, v4.xxxx
add r4.xyzw, r1.xyzw, r4.xyzw
mad r1.xyzw, r2.xyzw, cb0[0].xyzw, r1.xyzw
add r1.xyzw, r1.xyzw, r4.xyzw
max r1.xyzw, r1.xyzw, l(0x00000000, 0x00000000, 0x00000000, 0x00000000)
min r1.xyzw, r1.xyzw, l(0x3f800000, 0x3f800000, 0x3f800000, 0x3f800000)
div r4.xyzw, l(0x3f800000, 0x3f800000, 0x3f800000, 0x3f800000), r2.xyzw
add r1.xyzw, r1.xyzw, r4.xyzw
mov r4.xyzw, -r2.xyzw
max r4.xyzw, r2.xyzw, r4.xyzw
sqrt r4.xyzw, r4.xyzw
add r1.xyzw, r1.xyzw, r4.xyzw  // r1.x <- o.a.x; r1.y <- o.a.y; r1.z <- o.a.z; r1.w <- o.a.w

#line 104
ftoi r3.w, v1.z  // r3.w <- o.b.w
mov r3.xy, r3.xyxx  // r3.x <- o.b.x; r3.y <- o.b.y
mov r3.z, r3.z  // r3.z <- o.b.z

#line 105
ftou r0.y, v1.w
iadd r0.x, r0.y, r0.x  // r0.x <- o.c

#line 106
mul r0.y, r2.x, l(0x358637bd)
add r0.y, r0.y, v0.z
max r0.y, r0.y, l(0x00000000)
min r0.y, r0.y, l(0x3f800000)  // r0.y <- o.d

#line 107
mov o0.xyzw, r1.xyzw
mov o2.xyzw, r3.xyzw
mov o3.x, r0.x
mov oDepth, r0.y
ret 

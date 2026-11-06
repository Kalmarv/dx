ps_5_0
dcl_globalFlags refactoringAllowed | skipOptimization
dcl_constantbuffer CB0[10], dynamicIndexed
dcl_sampler s0, mode_default
dcl_resource_texture2d (float,float,float,float) t0
dcl_input_ps linear v0.xyz
dcl_input_ps linear v1.xy
dcl_output o0.xyzw
dcl_temps 8
//
// Initial variable locations:
//   v0.x <- nrm.x; v0.y <- nrm.y; v0.z <- nrm.z; 
//   v1.x <- uv.x; v1.y <- uv.y; 
//   o0.x <- <main return value>.x; o0.y <- <main return value>.y; o0.z <- <main return value>.z; o0.w <- <main return value>.w
//
#line 42 "C:\dx-fixtures\zi_scopes.hlsl"
nop 
mov r0.xyz, v0.xyzx

#line 29
itof r1.xyz, l(0x00000000, 0x00000000, 0x00000000, 0x00000000)  // r1.x <- acc.x; r1.y <- acc.y; r1.z <- acc.z

#line 30
itof r0.w, l(0x00000000)  // r0.w <- wsum

#line 31
mov r1.w, l(0x00000000)  // r1.w <- i
mov r2.xyz, r1.xyzx  // r2.x <- acc.x; r2.y <- acc.y; r2.z <- acc.z
mov r2.w, r0.w  // r2.w <- wsum
mov r3.x, r1.w  // r3.x <- i
loop 
  ilt r3.y, r3.x, cb0[9].y
  breakc_z r3.y

#line 33
  nop 
  mov r3.yzw, r0.xxyz
  mov r4.x, r3.x

#line 19
  nop 
  mov r3.yzw, r3.yyzw
  mov r4.yzw, cb0[r4.x + 1].xxyz

#line 13
  dp3 r4.y, r3.yzwy, r4.yzwy  // r4.y <- d

#line 14
  itof r4.z, l(0x00000000)
  lt r4.z, r4.z, r4.y
  mul r4.w, r4.y, cb0[9].x
  mov r4.y, -r4.y
  movc r4.y, r4.z, r4.w, r4.y  // r4.y <- <inner return value>

#line 19
  mov r4.y, r4.y  // r4.y <- d

#line 20
  lt r4.z, l(0x3e800000), r4.y
  if_nz r4.z

#line 21
    mul r5.xyz, r4.yyyy, cb0[r4.x + 1].xyzx  // r5.x <- l.c.x; r5.y <- l.c.y; r5.z <- l.c.z
  else 

#line 23
    itof r4.x, l(0x00000001)
    mov r4.z, -r4.y
    add r4.x, r4.z, r4.x
    mul r5.xyz, r3.yzwy, r4.xxxx  // r5.x <- l.c.x; r5.y <- l.c.y; r5.z <- l.c.z
  endif 

#line 24
  nop 
  mov r5.xyz, r5.xyzx
  mov r3.yzw, r3.yyzw

#line 13
  dp3 r3.y, r5.xyzx, r3.yzwy  // r3.y <- d

#line 14
  itof r3.z, l(0x00000000)
  lt r3.z, r3.z, r3.y
  mul r3.w, r3.y, cb0[9].x
  mov r3.y, -r3.y
  movc r3.y, r3.z, r3.w, r3.y  // r3.y <- <inner return value>

#line 24
  add r5.w, r3.y, r4.y  // r5.w <- l.w

#line 25
  mov r5.xyz, r5.xyzx  // r5.x <- <middle return value>.c.x; r5.y <- <middle return value>.c.y; r5.z <- <middle return value>.c.z
  mov r5.w, r5.w  // r5.w <- <middle return value>.w

#line 33
  mov r5.xyzw, r5.xyzw  // r5.x <- l.c.x; r5.y <- l.c.y; r5.z <- l.c.z; r5.w <- l.w

#line 34
  mul r3.yzw, r5.wwww, r5.xxyz
  add r2.xyz, r2.xyzx, r3.yzwy

#line 35
  add r2.w, r2.w, r5.w

#line 36
  iadd r3.x, r3.x, l(0x00000001)
endloop 

#line 37
sample_indexable(texture2d)(float,float,float,float) r0.xyzw, v1.xyxx, t0.xyzw, s0  // r0.x <- c.x; r0.y <- c.y; r0.z <- c.z; r0.w <- c.w

#line 38
max r1.x, r2.w, l(0x3a83126f)
div r1.xyz, r2.xyzx, r1.xxxx
itof r1.w, l(0x00000001)
mul r0.xyzw, r0.xyzw, r1.xyzw  // r0.x <- <outer return value>.x; r0.y <- <outer return value>.y; r0.z <- <outer return value>.z; r0.w <- <outer return value>.w

#line 42
mov r0.xyzw, r0.xyzw  // r0.x <- x.x; r0.y <- x.y; r0.z <- x.z; r0.w <- x.w

#line 43
nop 
mov r1.xyz, v0.xyzx
mov r0.xyz, r0.xyzx

#line 13
dp3 r1.x, r1.xyzx, r0.xyzx  // r1.x <- d

#line 14
itof r1.y, l(0x00000000)
lt r1.y, r1.y, r1.x
mul r1.z, r1.x, cb0[9].x
mov r1.x, -r1.x
movc r1.x, r1.y, r1.z, r1.x  // r1.x <- <inner return value>

#line 43
mov r1.x, r1.x  // r1.x <- y

#line 44
nop 
mov r1.yzw, -v0.xxyz
mul r2.xy, r1.xxxx, v1.xyxx

#line 29
itof r3.xyz, l(0x00000000, 0x00000000, 0x00000000, 0x00000000)  // r3.x <- acc.x; r3.y <- acc.y; r3.z <- acc.z

#line 30
itof r2.z, l(0x00000000)  // r2.z <- wsum

#line 31
mov r2.w, l(0x00000000)  // r2.w <- i
mov r4.xyz, r3.xyzx  // r4.x <- acc.x; r4.y <- acc.y; r4.z <- acc.z
mov r3.w, r2.z  // r3.w <- wsum
mov r4.w, r2.w  // r4.w <- i
loop 
  ilt r5.x, r4.w, cb0[9].y
  breakc_z r5.x

#line 33
  nop 
  mov r5.xyz, r1.yzwy
  mov r5.w, r4.w

#line 19
  nop 
  mov r5.xyz, r5.xyzx
  mov r6.xyz, cb0[r5.w + 1].xyzx

#line 13
  dp3 r6.x, r5.xyzx, r6.xyzx  // r6.x <- d

#line 14
  itof r6.y, l(0x00000000)
  lt r6.y, r6.y, r6.x
  mul r6.z, r6.x, cb0[9].x
  mov r6.x, -r6.x
  movc r6.x, r6.y, r6.z, r6.x  // r6.x <- <inner return value>

#line 19
  mov r6.x, r6.x  // r6.x <- d

#line 20
  lt r6.y, l(0x3e800000), r6.x
  if_nz r6.y

#line 21
    mul r7.xyz, r6.xxxx, cb0[r5.w + 1].xyzx  // r7.x <- l.c.x; r7.y <- l.c.y; r7.z <- l.c.z
  else 

#line 23
    itof r5.w, l(0x00000001)
    mov r6.y, -r6.x
    add r5.w, r5.w, r6.y
    mul r7.xyz, r5.wwww, r5.xyzx  // r7.x <- l.c.x; r7.y <- l.c.y; r7.z <- l.c.z
  endif 

#line 24
  nop 
  mov r7.xyz, r7.xyzx
  mov r5.xyz, r5.xyzx

#line 13
  dp3 r5.x, r7.xyzx, r5.xyzx  // r5.x <- d

#line 14
  itof r5.y, l(0x00000000)
  lt r5.y, r5.y, r5.x
  mul r5.z, r5.x, cb0[9].x
  mov r5.x, -r5.x
  movc r5.x, r5.y, r5.z, r5.x  // r5.x <- <inner return value>

#line 24
  add r7.w, r5.x, r6.x  // r7.w <- l.w

#line 25
  mov r7.xyz, r7.xyzx  // r7.x <- <middle return value>.c.x; r7.y <- <middle return value>.c.y; r7.z <- <middle return value>.c.z
  mov r7.w, r7.w  // r7.w <- <middle return value>.w

#line 33
  mov r7.xyzw, r7.xyzw  // r7.x <- l.c.x; r7.y <- l.c.y; r7.z <- l.c.z; r7.w <- l.w

#line 34
  mul r5.xyz, r7.wwww, r7.xyzx
  add r4.xyz, r4.xyzx, r5.xyzx

#line 35
  add r3.w, r3.w, r7.w

#line 36
  iadd r4.w, r4.w, l(0x00000001)
endloop 

#line 37
sample_indexable(texture2d)(float,float,float,float) r2.xyzw, r2.xyxx, t0.xyzw, s0  // r2.x <- c.x; r2.y <- c.y; r2.z <- c.z; r2.w <- c.w

#line 38
max r1.y, r3.w, l(0x3a83126f)
div r3.xyz, r4.xyzx, r1.yyyy
itof r3.w, l(0x00000001)
mul r2.xyzw, r2.xyzw, r3.xyzw  // r2.x <- <outer return value>.x; r2.y <- <outer return value>.y; r2.z <- <outer return value>.z; r2.w <- <outer return value>.w

#line 44
mov r2.xyzw, r2.xyzw  // r2.x <- z.x; r2.y <- z.y; r2.z <- z.z; r2.w <- z.w

#line 45
mul r0.xyzw, r0.xyzw, cb0[0].xyzw
mul r1.xyzw, r1.xxxx, r2.xyzw
add o0.xyzw, r0.xyzw, r1.xyzw
ret 

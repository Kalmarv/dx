vs_5_0
dcl_globalFlags refactoringAllowed | enableDoublePrecisionFloatOps | skipOptimization | enableMinimumPrecision
dcl_immediateConstantBuffer { { -1, 0, 0, 0},
                              { 0, -1, 0, 0},
                              { 0, 0, -1, 0},
                              { 0, 0, 0, -1} }
dcl_constantbuffer CB0[23], dynamicIndexed
dcl_constantbuffer CB3[129], dynamicIndexed
dcl_resource_texture2d (float,float,float,float) t0
dcl_resource_buffer (uint,uint,uint,uint) t1
dcl_resource_buffer (mixed,mixed,mixed,mixed) t2
dcl_input v0.xyz
dcl_input v1.xyz
dcl_input v2.xy
dcl_input v3.xyz
dcl_input_sgv v4.x, vertex_id
dcl_input_sgv v5.x, instance_id
dcl_output_siv o0.xyzw, position
dcl_output o1.xyz
dcl_output o2.xy
dcl_output o3.xyzw
dcl_output_siv o4.x, clip_distance
dcl_output o5.x
dcl_temps 7
//
// Initial variable locations:
//   v0.x <- v.pos.x; v0.y <- v.pos.y; v0.z <- v.pos.z; 
//   v1.x <- v.n.x; v1.y <- v.n.y; v1.z <- v.n.z; 
//   v2.x <- v.uv.x; v2.y <- v.uv.y; 
//   v3.x <- v.idx.x; v3.y <- v.idx.y; v3.z <- v.idx.z; v3.w <- v.idx.w; 
//   v4.x <- v.vid; 
//   v5.x <- v.iid; 
//   o5.x <- <main return value>.id; 
//   o4.x <- <main return value>.clip; 
//   o3.x <- <main return value>.c.x; o3.y <- <main return value>.c.y; o3.z <- <main return value>.c.z; o3.w <- <main return value>.c.w; 
//   o2.x <- <main return value>.uv.x; o2.y <- <main return value>.uv.y; 
//   o1.x <- <main return value>.n.x; o1.y <- <main return value>.n.y; o1.z <- <main return value>.n.z; 
//   o0.x <- <main return value>.pos.x; o0.y <- <main return value>.pos.y; o0.z <- <main return value>.pos.z; o0.w <- <main return value>.pos.w
//
#line 46 "C:\dx-fixtures\vs_cbuffers.hlsl"
mov r0.xyz, v0.xyzx  // r0.x <- p.x; r0.y <- p.y; r0.z <- p.z

#line 47
mov r0.w, l(0)  // r0.w <- b
mov r1.xyz, r0.xyzx  // r1.x <- p.x; r1.y <- p.y; r1.z <- p.z
mov r1.w, r0.w  // r1.w <- b
loop 
  mov r2.x, l(2)
  ult r2.x, r1.w, r2.x
  breakc_z r2.x

#line 48
  and r2.xyz, v3.xyzx, icb[r1.w + 0].xyzx
  mov r2.w, l(0)
  or r2.xy, r2.ywyy, r2.xzxx
  or r2.x, r2.y, r2.x
  imul null, r2.x, r2.x, l(4)
  mov r3.xyzw, cb3[r2.x + 0].xyzw  // r3.x <- k.m._m00; r3.y <- k.m._m01; r3.z <- k.m._m02; r3.w <- k.m._m03
  mov r4.xyzw, cb3[r2.x + 1].xyzw  // r4.x <- k.m._m10; r4.y <- k.m._m11; r4.z <- k.m._m12; r4.w <- k.m._m13
  mov r5.xyzw, cb3[r2.x + 2].xyzw  // r5.x <- k.m._m20; r5.y <- k.m._m21; r5.z <- k.m._m22; r5.w <- k.m._m23
  mov r2.x, cb3[r2.x + 3].x  // r2.x <- k.weight

#line 49
  itof r6.w, l(1)
  mov r6.xyz, v0.xyzx
  dp4 r3.x, r3.xyzw, r6.xyzw
  dp4 r3.y, r4.xyzw, r6.xyzw
  dp4 r3.z, r5.xyzw, r6.xyzw
  mul r2.xyz, r2.xxxx, r3.xyzx
  add r1.xyz, r1.xyzx, r2.xyzx

#line 50
  iadd r1.w, r1.w, l(1)
endloop 

#line 51
mov r0.x, l(15)
and r0.x, r0.x, v4.x
mov r1.w, l(4)
ushr r0.y, v4.x, r1.w
mov r0.zw, l(0,0,0,0)
ld_indexable(texture2d)(float,float,float,float) r0.x, r0.xyzw, t0.xyzw
add r0.x, r0.x, r1.y  // r0.x <- p.y

#line 52
itof r0.y, l(1)
mul r2.xyzw, r1.xxxx, cb0[4].xyzw
mul r3.xyzw, r0.xxxx, cb0[5].xyzw
add r2.xyzw, r2.xyzw, r3.xyzw
mul r1.xyzw, r1.zzzz, cb0[6].xyzw
add r1.xyzw, r1.xyzw, r2.xyzw
mul r0.xyzw, r0.yyyy, cb0[7].xyzw
add r0.xyzw, r0.xyzw, r1.xyzw  // r0.x <- wp.x; r0.y <- wp.y; r0.z <- wp.z; r0.w <- wp.w

#line 53
dp4 r1.x, r0.xyzw, cb0[0].xyzw  // r1.x <- o.pos.x
dp4 r1.y, r0.xyzw, cb0[1].xyzw  // r1.y <- o.pos.y
dp4 r1.z, r0.xyzw, cb0[2].xyzw  // r1.z <- o.pos.z
dp4 r1.w, r0.xyzw, cb0[3].xyzw  // r1.w <- o.pos.w

#line 54
mul r2.xyz, cb0[8].wwww, cb0[8].xyzx
add r2.xyz, r2.xyzx, v1.xyzx
dp3 r0.w, r2.xyzx, r2.xyzx
rsq r0.w, r0.w
mul r2.xyz, r0.wwww, r2.xyzx  // r2.x <- o.n.x; r2.y <- o.n.y; r2.z <- o.n.z

#line 55
add r3.xy, v2.xyxx, cb0[9].xyxx  // r3.x <- o.uv.x; r3.y <- o.uv.y

#line 56
itof r4.xyzw, l(0, 0, 0, 0)  // r4.x <- c.x; r4.y <- c.y; r4.z <- c.z; r4.w <- c.w

#line 57
mov r0.w, l(1)
and r0.w, r0.w, cb0[9].z
dp3 r2.w, v1.xyzx, cb0[11].xyzx
max r2.w, r2.w, l(0.000000)
min r2.w, r2.w, l(1.000000)
mul r5.xyzw, r2.wwww, cb0[r0.w + 12].xyzw
add r4.xyzw, r4.xyzw, r5.xyzw
mov r0.w, l(1)
and r0.w, r0.w, cb0[9].z
dp3 r2.w, v1.xyzx, cb0[14].xyzx
max r2.w, r2.w, l(0.000000)
min r2.w, r2.w, l(1.000000)
mul r5.xyzw, r2.wwww, cb0[r0.w + 15].xyzw
add r4.xyzw, r4.xyzw, r5.xyzw
mov r0.w, l(1)
and r0.w, r0.w, cb0[9].z
dp3 r2.w, v1.xyzx, cb0[17].xyzx
max r2.w, r2.w, l(0.000000)
min r2.w, r2.w, l(1.000000)
mul r5.xyzw, r2.wwww, cb0[r0.w + 18].xyzw
add r4.xyzw, r4.xyzw, r5.xyzw
mov r0.w, l(1)
and r0.w, r0.w, cb0[9].z
dp3 r2.w, v1.xyzx, cb0[20].xyzx
max r2.w, r2.w, l(0.000000)
min r2.w, r2.w, l(1.000000)
mul r5.xyzw, r2.wwww, cb0[r0.w + 21].xyzw
add r4.xyzw, r4.xyzw, r5.xyzw

#line 58
ine r0.w, l(0, 0, 0, 0), cb0[10].x
mov r2.w, l(7)
and r2.w, r2.w, v5.x
itof r5.xyzw, l(1, 1, 1, 1)
iadd r2.w, r2.w, l(0)
ld_indexable(buffer)(mixed,mixed,mixed,mixed) r6.xyzw, r2.wwww, t2.xyzw  // r6.x <- extra[0].x; r6.y <- extra[0].y; r6.z <- extra[0].z; r6.w <- extra[0].w
movc r5.xyzw, r0.wwww, r6.xyzw, r5.xyzw
mul r4.xyzw, r4.xyzw, r5.xyzw  // r4.x <- o.c.x; r4.y <- o.c.y; r4.z <- o.c.z; r4.w <- o.c.w

#line 60
dtof r0.w, cb3[127].zwzw
mov r2.w, cb3[128].x {min16f as def32}
mul r0.w, r0.w, r2.w
mul r4.xyzw, r0.wwww, r4.xyzw

#line 62
ld_indexable(buffer)(uint,uint,uint,uint) r5.xyz, v5.xxxx, t1.xyzw
utof r5.xyz, r5.xyzx
dp3 r0.x, r0.xyzx, r5.xyzx  // r0.x <- o.clip

#line 63
xor r0.y, v4.x, v5.x  // r0.y <- o.id

#line 64
mov o0.xyzw, r1.xyzw
mov o3.xyzw, r4.xyzw
mov o1.xyz, r2.xyzx
mov o2.xy, r3.xyxx
mov o4.x, r0.x
mov o5.x, r0.y
ret 

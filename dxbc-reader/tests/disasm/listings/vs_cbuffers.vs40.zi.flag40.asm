vs_4_0
dcl_constantbuffer CB0[23], dynamicIndexed
dcl_constantbuffer CB3[128], dynamicIndexed
dcl_resource_texture2d (float,float,float,float) t0
dcl_resource_buffer (uint,uint,uint,uint) t1
dcl_resource_buffer (mixed,mixed,mixed,mixed) t2
dcl_input v0.xyz
dcl_input v1.xyz
dcl_input v2.xy
dcl_input v3.xy
dcl_input_sgv v4.x, vertex_id
dcl_input_sgv v5.x, instance_id
dcl_output_siv o0.xyzw, position
dcl_output o1.xyz
dcl_output o2.xy
dcl_output o3.xyzw
dcl_output_siv o4.x, clip_distance
dcl_output o5.x
dcl_temps 4
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
#line 51 "C:\dx-fixtures\vs_cbuffers.hlsl"
and r0.x, v4.x, l(15)
ushr r0.y, v4.x, l(4)
mov r0.zw, l(0,0,0,0)
ld r0.xyzw, r0.xyzw, t0.xyzw

#line 49
mov r1.xyz, v0.xyzx
mov r1.w, l(1.000000)

#line 48
ishl r0.yz, v3.xxyx, l(2)

#line 49
dp4 r2.x, cb3[r0.y + 0].xyzw, r1.xyzw
dp4 r2.y, cb3[r0.y + 1].xyzw, r1.xyzw
dp4 r2.z, cb3[r0.y + 2].xyzw, r1.xyzw
mad r2.xyz, r2.xyzx, cb3[r0.y + 3].xxxx, v0.xyzx  // r2.x <- p.x; r2.y <- p.y; r2.z <- p.z
dp4 r3.x, cb3[r0.z + 0].xyzw, r1.xyzw
dp4 r3.y, cb3[r0.z + 1].xyzw, r1.xyzw
dp4 r3.z, cb3[r0.z + 2].xyzw, r1.xyzw
mad r0.yzw, r3.xxyz, cb3[r0.z + 3].xxxx, r2.xxyz  // r0.y <- p.x; r0.z <- p.y; r0.w <- p.z

#line 51
add r0.x, r0.x, r0.z  // r0.x <- p.y

#line 52
mul r1.xyzw, r0.xxxx, cb0[5].xyzw
mad r1.xyzw, r0.yyyy, cb0[4].xyzw, r1.xyzw
mad r0.xyzw, r0.wwww, cb0[6].xyzw, r1.xyzw
add r0.xyzw, r0.xyzw, cb0[7].xyzw  // r0.x <- wp.x; r0.y <- wp.y; r0.z <- wp.z; r0.w <- wp.w

#line 53
dp4 o0.x, r0.xyzw, cb0[0].xyzw
dp4 o0.y, r0.xyzw, cb0[1].xyzw
dp4 o0.z, r0.xyzw, cb0[2].xyzw
dp4 o0.w, r0.xyzw, cb0[3].xyzw

#line 54
mad r1.xyz, cb0[8].xyzx, cb0[8].wwww, v1.xyzx
dp3 r0.w, r1.xyzx, r1.xyzx
rsq r0.w, r0.w
mul o1.xyz, r0.wwww, r1.xyzx

#line 55
add o2.xy, v2.xyxx, cb0[9].xyxx

#line 57
dp3_sat r0.w, v1.xyzx, cb0[11].xyzx
dp3_sat r1.x, v1.xyzx, cb0[14].xyzx
and r1.y, cb0[9].z, l(1)
mul r2.xyzw, r1.xxxx, cb0[r1.y + 15].xyzw
mad r2.xyzw, cb0[r1.y + 12].xyzw, r0.wwww, r2.xyzw  // r2.x <- c.x; r2.y <- c.y; r2.z <- c.z; r2.w <- c.w
dp3_sat r0.w, v1.xyzx, cb0[17].xyzx
mad r2.xyzw, cb0[r1.y + 18].xyzw, r0.wwww, r2.xyzw
dp3_sat r0.w, v1.xyzx, cb0[20].xyzx
mad r1.xyzw, cb0[r1.y + 21].xyzw, r0.wwww, r2.xyzw  // r1.x <- c.x; r1.y <- c.y; r1.z <- c.z; r1.w <- c.w

#line 58
and r0.w, v5.x, l(7)
ld r2.xyzw, r0.wwww, t2.xyzw  // r2.x <- extra[0].x; r2.y <- extra[0].y; r2.z <- extra[0].z; r2.w <- extra[0].w
movc r2.xyzw, cb0[10].xxxx, r2.xyzw, l(1.000000,1.000000,1.000000,1.000000)
mul o3.xyzw, r1.xyzw, r2.xyzw

#line 62
ld r1.xyzw, v5.xxxx, t1.xyzw
utof r1.xyz, r1.xyzx
dp3 o4.x, r0.xyzx, r1.xyzx

#line 63
xor o5.x, v4.x, v5.x

#line 64
ret 

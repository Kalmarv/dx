    ps_2_x
      0x0000018C:     def c2, 0x3f000000, 0x400ccccd, 0x00000000, 0x00000000
      0x000001A4:     def c3, 0x3f800000, 0x00000000, 0x80000000, 0xc0000000
      0x000001BC:     dcl t0
      0x000001C8:     dcl t1.xyz
      0x000001D4:     dcl v0
      0x000001E0:     dcl t2
      0x000001EC:     dcl_2d s0
      0x000001F8:     dcl_cube s1
      0x00000204:     dcl_volume s2
      0x00000210:     dcl_2d s3
      0x0000021C:     dcl_2d s4
   0  0x00000228:     texldp r0, t2, s4.wwxx
   0  0x00000238:     texld r1, t0, s0.x
   0  0x00000248:     add r0, r0, r1
   1  0x00000258:     mul r1, t0.xyxw, c3.xxyx
   2  0x00000268:     mov r2.xy, t0.z
   3  0x00000274:     nrm r3.xyz, t1
   6  0x00000280:     mad r3.xyz, r3.z, c3.zzww, r3
   7  0x00000294:     texldb r1, r1, s0.yzxw
   7  0x000002A4:     texld r3, r3, s1.wwxx
   7  0x000002B4:     add r0, r0, r1
   8  0x000002C4:     texld r1, t0, s2.x
   8  0x000002D4:     texld r2, r2, s3.yzxw
   8  0x000002E4:     mul r1, r1, r2.x
   9  0x000002F4:     mad r0, r0, r3, r1
  10  0x00000308:     dsx r1.xy, t0
  12  0x00000314:     dsy r1.zw, t0.xyxy
  14  0x00000320:     dp2add_sat r1.x, r1, r1.zwzw, c3.y
  16  0x00000334:     lrp r2, r1.x, v0, r0
  17  0x00000348:     add r0, r2.w, -c1.x
  18  0x00000358:     texkill r0
  19  0x00000360:     exp r0.w, r2.w
  20  0x0000036C:     abs r1.xyz, r2
  21  0x00000378:     log r3.x, r1.x
  22  0x00000384:     log r3.y, r1.y
  23  0x00000390:     log r3.z, r1.z
  24  0x0000039C:     mul r1.xyz, r3, c2.y
  25  0x000003AC:     exp r0.x, r1.x
  26  0x000003B8:     exp r0.y, r1.y
  27  0x000003C4:     exp r0.z, r1.z
  28  0x000003D0:     mov oC1, r0
  29  0x000003DC:     rcp r0.x, t2.w
  30  0x000003E8:     mul r0.x, r0.x, t2.z
  31  0x000003F8:     mov oDepth, r0.x
  32  0x00000404:     mul_pp r0, r2, c2.x
  33  0x00000414:     mad r0, r2, c0, r0
  34  0x00000428:     add r1.x, -r0.y, c2.x
  35  0x00000438:     rcp r1.y, r0.y
  36  0x00000444:     cmp r0.z, r1.x, r0.z, r1.y
  37  0x00000458:     mov oC0, r0

// approximately 44 instruction slots used (6 texture, 38 arithmetic)

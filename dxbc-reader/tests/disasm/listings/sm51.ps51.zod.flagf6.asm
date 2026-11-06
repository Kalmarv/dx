      0x00000000: ps_5_1
      0x00000008: dcl_globalFlags refactoringAllowed | skipOptimization
      0x0000000C: dcl_constantbuffer CB0[2:2][5], immediateIndexed, space=0
      0x00000028: dcl_constantbuffer CB1[0:7][2], dynamicIndexed, space=1
      0x00000044: dcl_sampler S0[1:4], mode_default, space=3
      0x0000005C: dcl_resource_texture2d (float,float,float,float) T0[4:4], space=0
      0x00000078: dcl_resource_texture2d (float,float,float,float) T1[0:*], space=2
      0x00000094: dcl_uav_typed_texture2d_rov (float,float,float,float) U0[0:0], space=0
      0x000000B0: dcl_uav_structured U1[1:2], 4, space=4
      0x000000CC: dcl_input_ps_siv linear noperspective v0.xy, position
      0x000000DC: dcl_input_ps linear v1.xy
      0x000000E8: dcl_input_ps constant v2.x
      0x000000F4: dcl_output o0.xyzw
      0x00000100: dcl_output oStencilRef
      0x00000108: dcl_temps 4
   0  0x00000110: mov r0.x, l(0x00000007)
   1  0x00000124: and r0.x, r0.x, v2.x
   2  0x00000140: mov r1.xyzw, CB1[r0.x + 0][0].xyzw
   3  0x00000160: mov r0.x, CB1[r0.x + 0][1].x
   4  0x00000180: mov r0.y, l(0x00000003)
   5  0x00000194: and r0.y, r0.y, CB0[2][4].x
   6  0x000001B8: sample r2.xyzw, v1.xyxx, T1[r0.x + 0].xyzw { nonuniform }, S0[r0.y + 1]
   7  0x000001F4: mul r1.xyzw, r1.xyzw, r2.xyzw
   8  0x00000210: mov r0.y, l(0x00000000)
   9  0x00000224: sample r2.xyzw, v1.xyxx, T0[4].xyzw, S0[r0.y + 1]
  10  0x00000258: add r1.xyzw, r1.xyzw, r2.xyzw
  11  0x00000274: ftou r2.xyzw, v0.xyyy
  12  0x00000288: ftou r3.xyzw, v0.xyyy
  13  0x0000029C: ld_uav_typed r3.xyzw, r3.xyzw, U0[0].xyzw
  14  0x000002BC: mul r3.xyzw, r3.xyzw, l(0x3f000000, 0x3f000000, 0x3f000000, 0x3f000000)
  15  0x000002E4: add r3.xyzw, r1.xyzw, r3.xyzw
  16  0x00000300: store_uav_typed U0[0].xyzw, r2.xyzw, r3.xyzw
  17  0x00000320: mov r0.y, l(0x00000001)
  18  0x00000334: and r0.y, r0.y, v2.x
  19  0x00000350: mov r2.x, l(0x00000000)
  20  0x00000364: mov r2.y, l(0x00000000)
  21  0x00000378: atomic_iadd U1[r0.y + 1], r2.xyxx, l(0x00000001)
  22  0x000003A0: mov r1.xyzw, r1.xyzw
  23  0x000003B4: mov r0.y, l(0x000000ff)
  24  0x000003C8: and r0.x, r0.y, r0.x
  25  0x000003E4: mov o0.xyzw, r1.xyzw
  26  0x000003F8: mov oStencilRef, r0.x
  27  0x00000408: ret 

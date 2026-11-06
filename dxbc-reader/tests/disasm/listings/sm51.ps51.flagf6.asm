      0x00000000: ps_5_1
      0x00000008: dcl_globalFlags refactoringAllowed
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
   0  0x00000110: and r0.xy, v2.xxxx, l(0x00000007, 0x00000001, 0x00000000, 0x00000000)
   1  0x00000138: and r0.z, CB0[2][4].x, l(0x00000003)
   2  0x0000015C: mov r0.w, CB1[r0.x + 0][1].x
   3  0x0000017C: sample r1.xyzw, v1.xyxx, T1[r0.w + 0].xyzw { nonuniform }, S0[r0.z + 1]
   4  0x000001B8: sample r2.xyzw, v1.xyxx, T0[4].xyzw, S0[1]
   5  0x000001E4: mad r1.xyzw, r1.xyzw, CB1[r0.x + 0][0].xyzw, r2.xyzw
   6  0x00000214: ftou r2.xyzw, v0.xyyy
   7  0x00000228: ld_uav_typed r3.xyzw, r2.xwww, U0[0].xyzw
   8  0x00000248: mad r3.xyzw, r3.xyzw, l(0x3f000000, 0x3f000000, 0x3f000000, 0x3f000000), r1.xyzw
   9  0x00000278: store_uav_typed U0[0].xyzw, r2.xyzw, r3.xyzw
  10  0x00000298: atomic_iadd U1[r0.y + 1], l(0x00000000, 0x00000000, 0x00000000, 0x00000000), l(0x00000001)
  11  0x000002CC: and oStencilRef, l(0x000000ff), CB1[r0.x + 0][1].x
  12  0x000002F0: mov o0.xyzw, r1.xyzw
  13  0x00000304: ret 

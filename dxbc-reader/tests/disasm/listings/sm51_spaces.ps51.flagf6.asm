      0x00000000: ps_5_1
      0x00000008: dcl_globalFlags refactoringAllowed
      0x0000000C: dcl_constantbuffer CB0[1:3][2], dynamicIndexed, space=2
      0x00000028: dcl_sampler S0[2:5], mode_default, space=3
      0x00000040: dcl_resource_texture2d (float,float,float,float) T0[0:*], space=1
      0x0000005C: dcl_uav_structured U0[0:0], 4, space=4
      0x00000078: dcl_input_ps linear v0.xy
      0x00000084: dcl_input_ps constant v1.x
      0x00000090: dcl_output o0.xyzw
      0x0000009C: dcl_temps 2
   0  0x000000A4: and r0.x, v1.x, l(0x00000003)
   1  0x000000C0: mov r0.y, v1.x
   2  0x000000D4: sample r0.xyzw, v0.xyxx, T0[r0.y + 0].xyzw { nonuniform }, S0[r0.x + 2]
   3  0x00000110: udiv null, r1.x, v1.x, l(0x00000003)
   4  0x00000130: mul o0.xyzw, r0.xyzw, CB0[r1.x + 1][0].xyzw
   5  0x0000015C: mov r0.x, CB0[1][1].x
   6  0x00000178: mov r0.y, l(0x00000000)
   7  0x0000018C: atomic_iadd U0[0], r0.xyxx, l(0x00000001)
   8  0x000001AC: ret 

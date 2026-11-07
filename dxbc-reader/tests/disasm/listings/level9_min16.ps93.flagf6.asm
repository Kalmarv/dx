      0x00000000: ps_4_0
      0x00000008: dcl_globalFlags refactoringAllowed | enableMinimumPrecision
      0x0000000C: dcl_constantbuffer CB0[2], immediateIndexed
      0x0000001C: dcl_sampler s0, mode_default
      0x00000028: dcl_resource_texture2d (float,float,float,float) t0
      0x00000038: dcl_input_ps linear v1.xy {min16f}
      0x00000048: dcl_input_ps linear v2.xyzw {min16f}
      0x00000058: dcl_output o0.xyzw {min16f}
      0x00000068: dcl_temps 2
   0  0x00000070: sample r0.xyzw, v1.xyxx {min16f}, t0.xyzw, s0
   1  0x00000098: mul r0.xyzw {min16f}, r0.yxzw {def32 as min16f}, v2.yxzw {min16f}
   2  0x000000BC: mul r1.xyzw {min16f}, r0.xyzw {min16f}, cb0[0].yxzw {min16f}
   3  0x000000E8: mad r0.xyzw {min16f}, r0.yxzw {min16f}, cb0[0].xyzw {min16f}, cb0[1].xyzw {def32 as min16f}
   4  0x00000120: add o0.xyzw {min16f}, |r1.xyzw {min16f}|, r0.xyzw {min16f}
   5  0x00000148: ret 

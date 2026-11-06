      0x00000000: ps_5_0
      0x00000008: dcl_globalFlags refactoringAllowed
      0x0000000C: dcl_sampler s0, mode_default
      0x00000018: dcl_resource_texture2d (float,float,float,float) t0
      0x00000028: dcl_resource_texture2d (float,float,float,float) t3
      0x00000038: dcl_resource_texture2d (float,float,float,float) t5
      0x00000048: dcl_input_ps_siv linear noperspective v0.xyzw, position
      0x00000058: dcl_output o0.xyzw
      0x00000064: dcl_temps 2
   0  0x0000006C: sample_indexable(texture2d)(float,float,float,float) r0.xyzw, l(0x00000000, 0x00000000, 0x00000000, 0x00000000), t0.xyzw, s0
   1  0x000000A4: mul r0.xyzw, r0.xyzw, l(0x41200000, 0x41200000, 0x41200000, 0x41200000)
   2  0x000000CC: sample_indexable(texture2d)(float,float,float,float) r1.xyzw, l(0x00000000, 0x00000000, 0x00000000, 0x00000000), t3.xyzw, s0
   3  0x00000104: mad r0.xyzw, r1.xyzw, l(0x42c80000, 0x42c80000, 0x42c80000, 0x42c80000), r0.xyzw
   4  0x00000134: sample_indexable(texture2d)(float,float,float,float) r1.xyzw, l(0x00000000, 0x00000000, 0x00000000, 0x00000000), t5.xyzw, s0
   5  0x0000016C: add r0.xyzw, r0.xyzw, r1.xyzw
   6  0x00000188: add o0.xyzw, r0.xyzw, v0.xyzw
   7  0x000001A4: ret 

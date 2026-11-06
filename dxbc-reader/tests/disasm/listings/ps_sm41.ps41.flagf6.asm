      0x00000000: ps_4_1
      0x00000008: dcl_globalFlags refactoringAllowed
      0x0000000C: dcl_sampler s0, mode_default
      0x00000018: dcl_resource_texture2dms(4) (float,float,float,float) t0
      0x00000028: dcl_resource_texturecubearray (float,float,float,float) t1
      0x00000038: dcl_input_ps linear v0.xyz
      0x00000044: dcl_input_ps_siv linear noperspective v1.xy, position
      0x00000054: dcl_input_ps_sgv constant v2.x, sampleIndex
      0x00000064: dcl_output o0.xyzw
      0x00000070: dcl_temps 2
   0  0x00000078: ftoi r0.xy, v1.xyxx
   1  0x0000008C: mov r0.zw, l(0x00000000,0x00000000,0x00000000,0x00000000)
   2  0x000000AC: ldms r0.xyzw, r0.xyzw, t0.xyzw, v2.x
   3  0x000000D0: mov r1.xyz, v0.xyzx
   4  0x000000E4: mov r1.w, l(0x3f800000)
   5  0x000000F8: gather4 r1.xyzw, r1.xyzw, t1.xyzw, s0.x
   6  0x0000011C: add r0.xyzw, r0.xyzw, r1.xyzw
   7  0x00000138: samplepos r1.xy, t0.xyxx, v2.x
   8  0x00000158: add r0.xyzw, r0.xyzw, r1.xyxy
   9  0x00000174: lod r1.x, v0.xyzx, t1.x, s0
  10  0x00000198: add o0.xyzw, r0.xyzw, r1.xxxx
  11  0x000001B4: ret 

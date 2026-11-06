0x00000000: ps_5_0
0x00000008: dcl_globalFlags refactoringAllowed | skipOptimization
0x0000000C: dcl_sampler s0, mode_default
0x00000018: dcl_resource_texture2d (float,float,float,float) t0
0x00000028: dcl_resource_texture2d (float,float,float,float) t3
0x00000038: dcl_resource_texture2d (float,float,float,float) t5
0x00000048: dcl_input_ps_siv linear noperspective v0.xyzw, position
0x00000058: dcl_output o0.xyzw
0x00000064: dcl_temps 3
//
// Initial variable locations:
//   v0.x <- input.tex[0]
// <internal error> offset overruns length for type in PDB

//
#line 17 "C:\dx-fixtures\zi_object_input.hlsl"
0x0000006C: itof r0.xyzw, l(100, 100, 100, 100)
0x0000008C: itof r1.xy, l(0, 0, 0, 0)
0x000000AC: sample_indexable(texture2d)(float,float,float,float) r1.xyzw, r1.xyxx, t3.xyzw, s0
0x000000D8: mul r0.xyzw, r0.xyzw, r1.xyzw
0x000000F4: itof r1.xyzw, l(10, 10, 10, 10)
0x00000114: itof r2.xy, l(0, 0, 0, 0)
0x00000134: sample_indexable(texture2d)(float,float,float,float) r2.xyzw, r2.xyxx, t0.xyzw, s0
0x00000160: mul r1.xyzw, r1.xyzw, r2.xyzw
0x0000017C: add r0.xyzw, r0.xyzw, r1.xyzw
0x00000198: itof r1.xy, l(0, 0, 0, 0)
0x000001B8: sample_indexable(texture2d)(float,float,float,float) r1.xyzw, r1.xyxx, t5.xyzw, s0
0x000001E4: add r0.xyzw, r0.xyzw, r1.xyzw
0x00000200: add o0.xyzw, r0.xyzw, v0.xyzw
0x0000021C: ret 

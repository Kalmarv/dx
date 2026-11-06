ps_5_0
dcl_globalFlags refactoringAllowed | skipOptimization
dcl_sampler s0, mode_default
dcl_resource_texture2d (float,float,float,float) t0
dcl_resource_texture2d (float,float,float,float) t3
dcl_resource_texture2d (float,float,float,float) t5
dcl_input_ps_siv linear noperspective v0.xyzw, position
dcl_output o0.xyzw
dcl_temps 3
//
// Initial variable locations:
//   v0.x <- input.tex[0]
// <internal error> offset overruns length for type in PDB

//
#line 17 "C:\dx-fixtures\zi_object_input.hlsl"
itof r0.xyzw, l(0x00000064, 0x00000064, 0x00000064, 0x00000064)
itof r1.xy, l(0x00000000, 0x00000000, 0x00000000, 0x00000000)
sample_indexable(texture2d)(float,float,float,float) r1.xyzw, r1.xyxx, t3.xyzw, s0
mul r0.xyzw, r0.xyzw, r1.xyzw
itof r1.xyzw, l(0x0000000a, 0x0000000a, 0x0000000a, 0x0000000a)
itof r2.xy, l(0x00000000, 0x00000000, 0x00000000, 0x00000000)
sample_indexable(texture2d)(float,float,float,float) r2.xyzw, r2.xyxx, t0.xyzw, s0
mul r1.xyzw, r1.xyzw, r2.xyzw
add r0.xyzw, r0.xyzw, r1.xyzw
itof r1.xy, l(0x00000000, 0x00000000, 0x00000000, 0x00000000)
sample_indexable(texture2d)(float,float,float,float) r1.xyzw, r1.xyxx, t5.xyzw, s0
add r0.xyzw, r0.xyzw, r1.xyzw
add o0.xyzw, r0.xyzw, v0.xyzw
ret 

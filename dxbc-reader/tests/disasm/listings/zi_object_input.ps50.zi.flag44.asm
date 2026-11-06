      ps_5_0
      dcl_globalFlags refactoringAllowed
      dcl_sampler s0, mode_default
      dcl_resource_texture2d (float,float,float,float) t0
      dcl_resource_texture2d (float,float,float,float) t3
      dcl_resource_texture2d (float,float,float,float) t5
      dcl_input_ps_siv linear noperspective v0.xyzw, position
      dcl_output o0.xyzw
      dcl_temps 2
//
// Initial variable locations:
//   v0.x <- input.tex[0]
// <internal error> offset overruns length for type in PDB

//
#line 17 "C:\dx-fixtures\zi_object_input.hlsl"
   0: sample_indexable(texture2d)(float,float,float,float) r0.xyzw, l(0.000000, 0.000000, 0.000000, 0.000000), t0.xyzw, s0
   1: mul r0.xyzw, r0.xyzw, l(10.000000, 10.000000, 10.000000, 10.000000)
   2: sample_indexable(texture2d)(float,float,float,float) r1.xyzw, l(0.000000, 0.000000, 0.000000, 0.000000), t3.xyzw, s0
   3: mad r0.xyzw, r1.xyzw, l(100.000000, 100.000000, 100.000000, 100.000000), r0.xyzw
   4: sample_indexable(texture2d)(float,float,float,float) r1.xyzw, l(0.000000, 0.000000, 0.000000, 0.000000), t5.xyzw, s0
   5: add r0.xyzw, r0.xyzw, r1.xyzw
   6: add o0.xyzw, r0.xyzw, v0.xyzw
   7: ret 

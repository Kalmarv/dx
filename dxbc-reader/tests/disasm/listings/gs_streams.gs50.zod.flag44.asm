      gs_5_0
      dcl_globalFlags refactoringAllowed | skipOptimization
      dcl_input_siv v[6][0].xyzw, position
      dcl_input v[6][1].xy
      dcl_input vGSInstanceID
      dcl_input vPrim
      dcl_temps 3
      dcl_gsinstances 3
      dcl_inputprimitive triangleadj 
      dcl_stream m0
      dcl_outputtopology pointlist 
      dcl_output_siv o0.xyzw, position
      dcl_output o1.xy
      dcl_output_siv o2.x, rendertarget_array_index
      dcl_output_siv o2.y, viewport_array_index
      dcl_output_sgv o3.x, primitive_id
      dcl_stream m1
      dcl_outputtopology pointlist 
      dcl_output o0.xyzw
      dcl_maxout 6
//
// Initial variable locations:
//   vPrim <- prim; 
//   vGSInstanceID.x <- inst; 
//   m0 <- s; m1 <- s1; 
//   v[0][0].x <- input[0].pos.x; v[0][0].y <- input[0].pos.y; v[0][0].z <- input[0].pos.z; v[0][0].w <- input[0].pos.w; 
//   v[0][1].x <- input[0].uv.x; v[0][1].y <- input[0].uv.y; 
//   v[1][0].x <- input[1].pos.x; v[1][0].y <- input[1].pos.y; v[1][0].z <- input[1].pos.z; v[1][0].w <- input[1].pos.w; 
//   v[1][1].x <- input[1].uv.x; v[1][1].y <- input[1].uv.y; 
//   v[2][0].x <- input[2].pos.x; v[2][0].y <- input[2].pos.y; v[2][0].z <- input[2].pos.z; v[2][0].w <- input[2].pos.w; 
//   v[2][1].x <- input[2].uv.x; v[2][1].y <- input[2].uv.y; 
//   v[3][0].x <- input[3].pos.x; v[3][0].y <- input[3].pos.y; v[3][0].z <- input[3].pos.z; v[3][0].w <- input[3].pos.w; 
//   v[3][1].x <- input[3].uv.x; v[3][1].y <- input[3].uv.y; 
//   v[4][0].x <- input[4].pos.x; v[4][0].y <- input[4].pos.y; v[4][0].z <- input[4].pos.z; v[4][0].w <- input[4].pos.w; 
//   v[4][1].x <- input[4].uv.x; v[4][1].y <- input[4].uv.y; 
//   v[5][0].x <- input[5].pos.x; v[5][0].y <- input[5].pos.y; v[5][0].z <- input[5].pos.z; v[5][0].w <- input[5].pos.w; 
//   v[5][1].x <- input[5].uv.x; v[5][1].y <- input[5].uv.y
//
#line 15 "C:\dx-fixtures\gs_streams.hlsl"
   0: mov r0.x, l(0)  // r0.x <- i
   1: mov r0.y, r0.x  // r0.y <- i
   2: loop 
   3:   mov r0.z, l(6)
   4:   ult r0.z, r0.y, r0.z
   5:   breakc_z r0.z

#line 17
   6:   mov r1.xyzw, v[r0.y + 0][0].xyzw  // r1.x <- g.pos.x; r1.y <- g.pos.y; r1.z <- g.pos.z; r1.w <- g.pos.w

#line 18
   7:   mov r0.zw, v[r0.y + 0][1].xxxy  // r0.z <- g.uv.x; r0.w <- g.uv.y

#line 19
   8:   mov r2.x, vGSInstanceID.x  // r2.x <- g.layer

#line 20
   9:   mov r2.y, l(2)
  10:   udiv r2.y, null, r0.y, r2.y  // r2.y <- g.vp

#line 21
  11:   mov r2.z, vPrim  // r2.z <- g.prim

#line 22
  12:   mov o0.xyzw, r1.xyzw
  13:   mov o1.xy, r0.zwzz
  14:   mov o2.x, r2.x
  15:   mov o2.y, r2.y
  16:   mov o3.x, r2.z
  17:   emit_stream m0

#line 23
  18:   mov r0.z, l(2)
  19:   iadd r0.y, r0.z, r0.y
  20: endloop 

#line 24
  21: cut_stream m0

#line 26
  22: add r0.xyzw, v[3][0].xyzw, v[1][0].xyzw  // r0.x <- d.data.x; r0.y <- d.data.y; r0.z <- d.data.z; r0.w <- d.data.w

#line 27
  23: mov o0.xyzw, r0.xyzw
  24: emit_stream m1

#line 28
  25: cut_stream m1

#line 29
  26: ret 

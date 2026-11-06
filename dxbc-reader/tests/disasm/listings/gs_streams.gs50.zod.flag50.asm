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
mov r0.x, l(0)
mov r0.y, r0.x
loop 
  mov r0.z, l(6)
  ult r0.z, r0.y, r0.z
  breakc_z r0.z
  mov r1.xyzw, v[r0.y + 0][0].xyzw
  mov r0.zw, v[r0.y + 0][1].xxxy
  mov r2.x, vGSInstanceID.x
  mov r2.y, l(2)
  udiv r2.y, null, r0.y, r2.y
  mov r2.z, vPrim
  mov o0.xyzw, r1.xyzw
  mov o1.xy, r0.zwzz
  mov o2.x, r2.x
  mov o2.y, r2.y
  mov o3.x, r2.z
  emit_stream m0
  mov r0.z, l(2)
  iadd r0.y, r0.z, r0.y
endloop 
cut_stream m0
add r0.xyzw, v[3][0].xyzw, v[1][0].xyzw
mov o0.xyzw, r0.xyzw
emit_stream m1
cut_stream m1
ret 

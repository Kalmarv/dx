gs_5_0
dcl_globalFlags refactoringAllowed
dcl_input_siv v[6][0].xyzw, position
dcl_input v[6][1].xy
dcl_input vGSInstanceID
dcl_input vPrim
dcl_temps 1
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
loop 
  uge r0.y, r0.x, l(6)
  retc_nz l(0x41200000)
  ushr r0.y, r0.x, l(1)
  mov o0.xyzw, v[r0.x + 0][0].xyzw
  mov o1.xy, v[r0.x + 0][1].xyxx
  mov o2.x, vGSInstanceID.x
  mov o2.y, r0.y
  mov o3.x, vPrim
  emit_stream m0
  iadd r0.x, r0.x, l(2)
endloop 
cut_stream m0
add r0.xyzw, v[3][0].xyzw, v[1][0].xyzw
mov o0.xyzw, r0.xyzw
emit_stream m1
cut_stream m1
ret 

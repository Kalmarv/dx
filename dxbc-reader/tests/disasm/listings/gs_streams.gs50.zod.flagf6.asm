      0x00000000: gs_5_0
      0x00000008: dcl_globalFlags refactoringAllowed | skipOptimization
      0x0000000C: dcl_input_siv v[6][0].xyzw, position
      0x00000020: dcl_input v[6][1].xy
      0x00000030: dcl_input vGSInstanceID
      0x00000038: dcl_input vPrim
      0x00000040: dcl_temps 3
      0x00000048: dcl_gsinstances 3
      0x00000050: dcl_inputprimitive triangleadj 
      0x00000054: dcl_stream m0
      0x00000060: dcl_outputtopology pointlist 
      0x00000064: dcl_output_siv o0.xyzw, position
      0x00000074: dcl_output o1.xy
      0x00000080: dcl_output_siv o2.x, rendertarget_array_index
      0x00000090: dcl_output_siv o2.y, viewport_array_index
      0x000000A0: dcl_output_sgv o3.x, primitive_id
      0x000000B0: dcl_stream m1
      0x000000BC: dcl_outputtopology pointlist 
      0x000000C0: dcl_output o0.xyzw
      0x000000CC: dcl_maxout 6
   0  0x000000D4: mov r0.x, l(0x00000000)
   1  0x000000E8: mov r0.y, r0.x
   2  0x000000FC: loop 
   3  0x00000100:   mov r0.z, l(0x00000006)
   4  0x00000114:   ult r0.z, r0.y, r0.z
   5  0x00000130:   breakc_z r0.z
   6  0x0000013C:   mov r1.xyzw, v[r0.y + 0][0].xyzw
   7  0x00000158:   mov r0.zw, v[r0.y + 0][1].xxxy
   8  0x00000174:   mov r2.x, vGSInstanceID.x
   9  0x00000184:   mov r2.y, l(0x00000002)
  10  0x00000198:   udiv r2.y, null, r0.y, r2.y
  11  0x000001B8:   mov r2.z, vPrim
  12  0x000001C8:   mov o0.xyzw, r1.xyzw
  13  0x000001DC:   mov o1.xy, r0.zwzz
  14  0x000001F0:   mov o2.x, r2.x
  15  0x00000204:   mov o2.y, r2.y
  16  0x00000218:   mov o3.x, r2.z
  17  0x0000022C:   emit_stream m0
  18  0x00000238:   mov r0.z, l(0x00000002)
  19  0x0000024C:   iadd r0.y, r0.z, r0.y
  20  0x00000268: endloop 
  21  0x0000026C: cut_stream m0
  22  0x00000278: add r0.xyzw, v[3][0].xyzw, v[1][0].xyzw
  23  0x0000029C: mov o0.xyzw, r0.xyzw
  24  0x000002B0: emit_stream m1
  25  0x000002BC: cut_stream m1
  26  0x000002C8: ret 

0x00000000: gs_5_0
0x00000008: dcl_globalFlags refactoringAllowed
0x0000000C: dcl_input_siv v[6][0].xyzw, position
0x00000020: dcl_input v[6][1].xy
0x00000030: dcl_input vGSInstanceID
0x00000038: dcl_input vPrim
0x00000040: dcl_temps 1
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
0x000000D4: mov r0.x, l(0)
0x000000E8: loop 
0x000000EC:   uge r0.y, r0.x, l(6)
0x00000108:   retc_nz l(0x41200000)
0x00000114:   ushr r0.y, r0.x, l(1)
0x00000130:   mov o0.xyzw, v[r0.x + 0][0].xyzw
0x0000014C:   mov o1.xy, v[r0.x + 0][1].xyxx
0x00000168:   mov o2.x, vGSInstanceID.x
0x00000178:   mov o2.y, r0.y
0x0000018C:   mov o3.x, vPrim
0x0000019C:   emit_stream m0
0x000001A8:   iadd r0.x, r0.x, l(2)
0x000001C4: endloop 
0x000001C8: cut_stream m0
0x000001D4: add r0.xyzw, v[3][0].xyzw, v[1][0].xyzw
0x000001F8: mov o0.xyzw, r0.xyzw
0x0000020C: emit_stream m1
0x00000218: cut_stream m1
0x00000224: ret 

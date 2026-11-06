0x00000000: gs_4_1
0x00000008: dcl_globalFlags refactoringAllowed
0x0000000C: dcl_constantbuffer CB0[24], dynamicIndexed
0x0000001C: dcl_input v[3][0].xyzw
0x0000002C: dcl_temps 3
0x00000034: dcl_inputprimitive triangle 
0x00000038: dcl_outputtopology trianglestrip 
0x0000003C: dcl_output_siv o0.xyzw, position
0x0000004C: dcl_output o1.xyzw
0x00000058: dcl_output_siv o2.x, rendertarget_array_index
0x00000068: dcl_maxout 18
0x00000070: mov r0.x, l(0)
0x00000084: loop 
0x00000088:   uge r0.y, r0.x, l(6)
0x000000A4:   breakc_nz r0.y
0x000000B0:   ishl r0.y, r0.x, l(2)
0x000000CC:   utof r0.z, r0.x
0x000000E0:   mul r0.z, r0.z, l(0.166667)
0x000000FC:   mov r0.w, l(0)
0x00000110:   loop 
0x00000114:     uge r1.x, r0.w, l(3)
0x00000130:     breakc_nz r1.x
0x0000013C:     dp4 r1.x, v[r0.w + 0][0].xyzw, cb0[r0.y + 0].xyzw
0x00000168:     dp4 r1.y, v[r0.w + 0][0].xyzw, cb0[r0.y + 1].xyzw
0x00000198:     dp4 r1.z, v[r0.w + 0][0].xyzw, cb0[r0.y + 2].xyzw
0x000001C8:     dp4 r1.w, v[r0.w + 0][0].xyzw, cb0[r0.y + 3].xyzw
0x000001F8:     utof r2.x, r0.w
0x0000020C:     mul r2.x, r2.x, l(0.333333)
0x00000228:     mov o0.x, r1.x
0x0000023C:     mov o0.y, r1.y
0x00000250:     mov o0.z, r1.z
0x00000264:     mov o0.w, r1.w
0x00000278:     mov o1.x, r0.z
0x0000028C:     mov o1.y, r2.x
0x000002A0:     mov o1.zw, l(0,0,0,1.000000)
0x000002C0:     mov o2.x, r0.x
0x000002D4:     emit 
0x000002D8:     iadd r0.w, r0.w, l(1)
0x000002F4:   endloop 
0x000002F8:   cut 
0x000002FC:   iadd r0.x, r0.x, l(1)
0x00000318: endloop 
0x0000031C: ret 

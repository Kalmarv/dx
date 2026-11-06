0x00000000: vs_4_0
0x00000008: dcl_constantbuffer CB0[5], immediateIndexed
0x00000018: dcl_input v0.xyz
0x00000024: dcl_input v1.xy
0x00000030: dcl_output_siv o0.xyzw, position
0x00000040: dcl_output o1.xy
0x0000004C: dcl_temps 1
0x00000054: mov r0.xyz, v0.xyzx
0x00000068: mov r0.w, l(1.000000)
0x0000007C: dp4 o0.x, r0.xyzw, cb0[0].xyzw
0x0000009C: dp4 o0.y, r0.xyzw, cb0[1].xyzw
0x000000BC: dp4 o0.z, r0.xyzw, cb0[2].xyzw
0x000000DC: dp4 o0.w, r0.xyzw, cb0[3].xyzw
0x000000FC: mul o1.xy, v1.xyxx, cb0[4].xyxx
0x0000011C: ret 

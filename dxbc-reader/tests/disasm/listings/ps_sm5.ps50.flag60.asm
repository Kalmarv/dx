0x00000000: ps_5_0
0x00000008: dcl_globalFlags refactoringAllowed | enableDoublePrecisionFloatOps | enableMinimumPrecision | enable11_1DoubleExtensions
0x0000000C: dcl_constantbuffer CB0[3], immediateIndexed
0x0000001C: dcl_uav_typed_texture2d (float,float,float,float) u2
0x0000002C: dcl_uav_structured u3, 4
0x0000003C: dcl_uav_raw_glc u4
0x00000048: dcl_input_ps_siv linear noperspective v0.xyz, position
0x00000058: dcl_input_ps linear v1.xyzw
0x00000064: dcl_input_ps linear sample v2.xy
0x00000070: dcl_input_ps linear noperspective centroid v3.xyz
0x0000007C: dcl_input_ps linear noperspective sample v4.x
0x00000088: dcl_input_ps linear v5.xy {min16f}
0x00000098: dcl_input_ps_sgv constant v6.x, sampleIndex
0x000000A8: dcl_input vCoverage
0x000000B0: dcl_output o0.xyzw
0x000000BC: dcl_output o1.xyzw {min16f}
0x000000CC: dcl_output oMask
0x000000D4: dcl_output oDepthGE
0x000000DC: dcl_temps 4
0x000000E4: dcl_indexableTemp x0[5], 4
0x000000F4: mov x0[0].xyzw, l(0,0,0,0)
0x00000118: mov x0[1].xyzw, v1.xyzw
0x00000130: add r0.xyzw, v1.xyzw, v1.xyzw
0x0000014C: mov x0[2].xyzw, r0.xyzw
0x00000164: mul r0.xyzw, v1.xyzw, l(3.000000, 3.000000, 3.000000, 3.000000)
0x0000018C: mov x0[3].xyzw, r0.xyzw
0x000001A4: mul r0.xyzw, v1.xyzw, l(4.000000, 4.000000, 4.000000, 4.000000)
0x000001CC: mov x0[4].xyzw, r0.xyzw
0x000001E4: mov r0.x, cb0[2].x
0x000001FC: mov r0.y, l(0)
0x00000210: imm_atomic_iadd r0.x, u3, r0.xyxx, l(1)
0x00000234: udiv null, r0.y, cb0[2].x, l(5)
0x00000258: mov r1.xyzw, x0[r0.y + 0].xyzw
0x00000274: eval_sample_index r2.xyzw, v1.xyzw, v6.x
0x00000290: eval_centroid r3.xyzw, v1.xyzw
0x000002A4: add r2.xyzw, r2.xyzw, r3.xyzw
0x000002C0: eval_snapped r3.xyzw, v1.xyzw, l(1, -1, 0, 0)
0x000002E8: add r2.xyzw, r2.xyzw, r3.xyzw
0x00000304: add r1.xyzw, r1.xyzw, r2.xyzw
0x00000320: samplepos r0.yz, rasterizer.xxyx, v6.x
0x00000338: sampleinfo r2.xy, rasterizer.x
0x00000348: mad r0.yz, r0.yyzy, r2.xxyx, v2.xxyx
0x0000036C: add r0.yz, r0.yyzy, r1.xxyx
0x00000388: ftod r2.xy, r0.y
0x0000039C: dmul r2.xy, r2.xyxy, cb0[1].xyxy
0x000003BC: dadd r2.xy, r2.xyxy, cb0[1].zwzw
0x000003DC: dfma r2.xy, r2.xyxy, cb0[1].zwzw, cb0[1].xyxy
0x00000408: dmin r2.zw, r2.xyxy, cb0[1].xyxy
0x00000428: dtof r0.w, r2.zwzw
0x0000043C: deq r2.z, r2.xyxy, cb0[1].zwzw
0x0000045C: ddiv r2.xy, r2.xyxy, cb0[1].zwzw
0x0000047C: dtof r2.x, r2.xyxy
0x00000490: add r1.x, r0.y, r2.x
0x000004AC: and r0.y, r2.z, l(0x3f800000)
0x000004C8: add r0.y, r0.y, r0.w
0x000004E4: add r1.y, r0.y, r0.z
0x00000500: ftou r2.xyzw, v0.xyyy
0x00000514: store_uav_typed u2.xyzw, r2.xyzw, r1.xyzw
0x00000530: ishl r0.y, cb0[2].x, l(2)
0x00000550: atomic_umax u4, r0.y, r0.x
0x0000056C: store_raw u4.xyz, l(16), r1.xyzx
0x00000588: add r0.xyzw, r1.xyzw, v3.xyzx
0x000005A4: add o0.xyzw, r0.xyzw, v4.xxxx
0x000005C0: mad o1.xyzw {min16f}, v5.xyxy {min16f}, cb0[0].xyxy {def32 as min16f}, l(1.500000, 1.500000, 1.500000, 1.500000) {def32 as min16f}
0x000005FC: add oDepthGE, v0.z, l(0.010000)
0x00000614: and oMask, vCoverage.x, l(5)
0x00000628: ret 

0x00000000: vs_4_0
0x00000008: dcl_constantbuffer CB0[23], dynamicIndexed
0x00000018: dcl_constantbuffer CB3[128], dynamicIndexed
0x00000028: dcl_resource_texture2d (float,float,float,float) t0
0x00000038: dcl_resource_buffer (uint,uint,uint,uint) t1
0x00000048: dcl_resource_buffer (mixed,mixed,mixed,mixed) t2
0x00000058: dcl_input v0.xyz
0x00000064: dcl_input v1.xyz
0x00000070: dcl_input v2.xy
0x0000007C: dcl_input v3.xy
0x00000088: dcl_input_sgv v4.x, vertex_id
0x00000098: dcl_input_sgv v5.x, instance_id
0x000000A8: dcl_output_siv o0.xyzw, position
0x000000B8: dcl_output o1.xyz
0x000000C4: dcl_output o2.xy
0x000000D0: dcl_output o3.xyzw
0x000000DC: dcl_output_siv o4.x, clip_distance
0x000000EC: dcl_output o5.x
0x000000F8: dcl_temps 4
0x00000100: and r0.x, v4.x, l(15)
0x0000011C: ushr r0.y, v4.x, l(4)
0x00000138: mov r0.zw, l(0,0,0,0)
0x00000158: ld r0.xyzw, r0.xyzw, t0.xyzw
0x00000174: mov r1.xyz, v0.xyzx
0x00000188: mov r1.w, l(1.000000)
0x0000019C: ishl r0.yz, v3.xxyx, l(2)
0x000001B8: dp4 r2.x, cb3[r0.y + 0].xyzw, r1.xyzw
0x000001DC: dp4 r2.y, cb3[r0.y + 1].xyzw, r1.xyzw
0x00000204: dp4 r2.z, cb3[r0.y + 2].xyzw, r1.xyzw
0x0000022C: mad r2.xyz, r2.xyzx, cb3[r0.y + 3].xxxx, v0.xyzx
0x0000025C: dp4 r3.x, cb3[r0.z + 0].xyzw, r1.xyzw
0x00000280: dp4 r3.y, cb3[r0.z + 1].xyzw, r1.xyzw
0x000002A8: dp4 r3.z, cb3[r0.z + 2].xyzw, r1.xyzw
0x000002D0: mad r0.yzw, r3.xxyz, cb3[r0.z + 3].xxxx, r2.xxyz
0x00000300: add r0.x, r0.x, r0.z
0x0000031C: mul r1.xyzw, r0.xxxx, cb0[5].xyzw
0x0000033C: mad r1.xyzw, r0.yyyy, cb0[4].xyzw, r1.xyzw
0x00000364: mad r0.xyzw, r0.wwww, cb0[6].xyzw, r1.xyzw
0x0000038C: add r0.xyzw, r0.xyzw, cb0[7].xyzw
0x000003AC: dp4 o0.x, r0.xyzw, cb0[0].xyzw
0x000003CC: dp4 o0.y, r0.xyzw, cb0[1].xyzw
0x000003EC: dp4 o0.z, r0.xyzw, cb0[2].xyzw
0x0000040C: dp4 o0.w, r0.xyzw, cb0[3].xyzw
0x0000042C: mad r1.xyz, cb0[8].xyzx, cb0[8].wwww, v1.xyzx
0x00000458: dp3 r0.w, r1.xyzx, r1.xyzx
0x00000474: rsq r0.w, r0.w
0x00000488: mul o1.xyz, r0.wwww, r1.xyzx
0x000004A4: add o2.xy, v2.xyxx, cb0[9].xyxx
0x000004C4: dp3_sat r0.w, v1.xyzx, cb0[11].xyzx
0x000004E4: dp3_sat r1.x, v1.xyzx, cb0[14].xyzx
0x00000504: and r1.y, cb0[9].z, l(1)
0x00000524: mul r2.xyzw, r1.xxxx, cb0[r1.y + 15].xyzw
0x0000054C: mad r2.xyzw, cb0[r1.y + 12].xyzw, r0.wwww, r2.xyzw
0x0000057C: dp3_sat r0.w, v1.xyzx, cb0[17].xyzx
0x0000059C: mad r2.xyzw, cb0[r1.y + 18].xyzw, r0.wwww, r2.xyzw
0x000005CC: dp3_sat r0.w, v1.xyzx, cb0[20].xyzx
0x000005EC: mad r1.xyzw, cb0[r1.y + 21].xyzw, r0.wwww, r2.xyzw
0x0000061C: and r0.w, v5.x, l(7)
0x00000638: ld r2.xyzw, r0.wwww, t2.xyzw
0x00000654: movc r2.xyzw, cb0[10].xxxx, r2.xyzw, l(1.000000,1.000000,1.000000,1.000000)
0x00000688: mul o3.xyzw, r1.xyzw, r2.xyzw
0x000006A4: ld r1.xyzw, v5.xxxx, t1.xyzw
0x000006C0: utof r1.xyz, r1.xyzx
0x000006D4: dp3 o4.x, r0.xyzx, r1.xyzx
0x000006F0: xor o5.x, v4.x, v5.x
0x0000070C: ret 

      0x00000000: vs_4_0
      0x00000008: dcl_constantbuffer CB0[68], dynamicIndexed
      0x00000018: dcl_resource_buffer (float,float,float,float) t0
      0x00000028: dcl_input v0.xyzw
      0x00000034: dcl_input v1.xyzw
      0x00000040: dcl_input v2.xyzw
      0x0000004C: dcl_input_sgv v3.x, vertex_id
      0x0000005C: dcl_output_siv o0.xyzw, position
      0x0000006C: dcl_output o1.xyzw
      0x00000078: dcl_output o2.x
      0x00000084: dcl_temps 3
   0  0x0000008C: itof r0.xyzw, l(0x00000000, 0x00000000, 0x00000000, 0x00000000)
   1  0x000000AC: mov r1.x, v1.x
   2  0x000000C0: mul r1.xyzw, v2.xxxx, cb0[r1.x + 4].xyzw
   3  0x000000E8: add r0.xyzw, r0.xyzw, r1.xyzw
   4  0x00000104: mov r1.x, v1.y
   5  0x00000118: mul r1.xyzw, v2.yyyy, cb0[r1.x + 4].xyzw
   6  0x00000140: add r0.xyzw, r0.xyzw, r1.xyzw
   7  0x0000015C: mov r1.x, v1.z
   8  0x00000170: mul r1.xyzw, v2.zzzz, cb0[r1.x + 4].xyzw
   9  0x00000198: add r0.xyzw, r0.xyzw, r1.xyzw
  10  0x000001B4: mov r1.x, v1.w
  11  0x000001C8: mul r1.xyzw, v2.wwww, cb0[r1.x + 4].xyzw
  12  0x000001F0: add r0.xyzw, r0.xyzw, r1.xyzw
  13  0x0000020C: add r0.xyzw, r0.xyzw, v0.xyzw
  14  0x00000228: dp4 r1.x, r0.xyzw, cb0[0].xyzw
  15  0x00000248: dp4 r1.y, r0.xyzw, cb0[1].xyzw
  16  0x00000268: dp4 r1.z, r0.xyzw, cb0[2].xyzw
  17  0x00000288: dp4 r1.w, r0.xyzw, cb0[3].xyzw
  18  0x000002A8: mov r0.x, v3.x
  19  0x000002BC: ld r0.xyzw, r0.xxxx, t0.xyzw
  20  0x000002D8: mov r2.x, l(0x00000003)
  21  0x000002EC: udiv null, r2.x, v3.x, r2.x
  22  0x0000030C: mov r2.y, l(0x00000000)
  23  0x00000320: ieq r2.x, r2.y, r2.x
  24  0x0000033C: itof r2.y, l(0x00000002)
  25  0x00000350: movc r2.x, r2.x, r2.y, l(0x3f000000)
  26  0x00000374: mul r0.xyzw, r0.xyzw, r2.xxxx
  27  0x00000390: div r2.x, r1.z, r1.w
  28  0x000003AC: mov o0.xyzw, r1.xyzw
  29  0x000003C0: mov o1.xyzw, r0.xyzw
  30  0x000003D4: mov o2.x, r2.x
  31  0x000003E8: ret 

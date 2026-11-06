    vs_3_0
      0x00000004:   + mov r0.xyz, v0
   1  0x00000010:     mov r0, r0
   2  0x0000001C:     mov r0, r1
   3  0x00000028:     mov r0, v0
   4  0x00000034:     mov v0, r1
   5  0x00000040:     mov r0, c0
   6  0x0000004C:     mov c0, r1
   7  0x00000058:     mov r0, a0
   8  0x00000064:     mov a0, r1
   9  0x00000070:     mov r0, oD0
  10  0x0000007C:     mov oD0, r1
  11  0x00000088:     mov r0, o0
  12  0x00000094:     mov o0, r1
  13  0x000000A0:     mov r0, i0
  14  0x000000AC:     mov i0, r1
  15  0x000000B8:     mov r0, oC0
  16  0x000000C4:     mov oC0, r1
  17  0x000000D0:     mov r0, oDepth
  18  0x000000DC:     mov oDepth, r1
  19  0x000000E8:     mov r0, s0
  20  0x000000F4:     mov s0, r1
  21  0x00000100:     mov r0, c2048
  22  0x0000010C:     mov c2048, r1
  23  0x00000118:     mov r0, c4096
  24  0x00000124:     mov c4096, r1
  25  0x00000130:     mov r0, c6144
  26  0x0000013C:     mov c6144, r1
  27  0x00000148:     mov r0, b0
  28  0x00000154:     mov b0, r1
  29  0x00000160:     mov r0, aL
  30  0x0000016C:     mov aL, r1
  31  0x00000178:     mov r0, oPos
  32  0x00000184:     mov oPos, r1
  33  0x00000190:     mov r0, oFog
  34  0x0000019C:     mov oFog, r1
  35  0x000001A8:     mov r0, oPts
  36  0x000001B4:     mov oPts, r1
  37  0x000001C0:     mov r0, vPos
  38  0x000001CC:     mov vPos, r1
  39  0x000001D8:     mov r0, vFace
  40  0x000001E4:     mov vFace, r1
  41  0x000001F0:     mov r0, l0
  42  0x000001FC:     mov l0, r1
  43  0x00000208:     mov r0, p0
  44  0x00000214:     mov p0, r1
      0x00000220:     dcl_position v0
      0x0000022C:     dcl_position1 v1
      0x00000238:     dcl_blendweight v2
      0x00000244:     dcl_blendweight1 v3
      0x00000250:     dcl_blendindices v4
      0x0000025C:     dcl_blendindices1 v5
      0x00000268:     dcl_normal v6
      0x00000274:     dcl_normal1 v7
      0x00000280:     dcl_psize v8
      0x0000028C:     dcl_psize1 v9
      0x00000298:     dcl_texcoord v10
      0x000002A4:     dcl_texcoord1 v11
      0x000002B0:     dcl_tangent v12
      0x000002BC:     dcl_tangent1 v13
      0x000002C8:     dcl_binormal v14
      0x000002D4:     dcl_binormal1 v15
      0x000002E0:     dcl_tessfactor v16
      0x000002EC:     dcl_tessfactor1 v17
      0x000002F8:     dcl_positiont v18
      0x00000304:     dcl_positiont1 v19
      0x00000310:     dcl_color v20
      0x0000031C:     dcl_color1 v21
      0x00000328:     dcl_fog v22
      0x00000334:     dcl_fog1 v23
      0x00000340:     dcl_depth v24
      0x0000034C:     dcl_depth1 v25
      0x00000358:     dcl_sample v26
      0x00000364:     dcl_sample1 v27
  45  0x00000370:     mov_x2 r0, v0
  46  0x0000037C:     mov_x4 r0, v0
  47  0x00000388:     mov_x8 r0, v0
  48  0x00000394:     mov_d8 r0, v0
  49  0x000003A0:     mov_d4 r0, v0
  50  0x000003AC:     mov_d2 r0, v0
  51  0x000003B8:     mov r0[a0.x], v0
  52  0x000003C8:     mov r0, c0[a0.x]
  53  0x000003D8:     mov r0.xyz, v0
      0x000003E4:   + mov r1.w, v1
  54  0x000003F0:     (p0) mov r0, v0
  56  0x00000400:     (!p0.x) add r0, v0, v1

// approximately 58 instruction slots used

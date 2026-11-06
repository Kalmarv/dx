      0x00000000: ps_4_1
      0x00000008: dcl_globalFlags refactoringAllowed
      0x0000000C: dcl_immediateConstantBuffer { { 0x3f800000, 0x00000000, 0x00000000, 0x3f800000},
                              { 0x00000000, 0x3f800000, 0x00000000, 0x3f800000},
                              { 0x00000000, 0x00000000, 0x3f800000, 0x3f800000},
                              { 0x3f000000, 0x3e800000, 0x322bcc77, 0xe0ad78ec},
                              { 0x7f7fffff, 0x00000000, 0x3eaaaaab, 0x47c35000},
                              { 0x7f800000, 0xff800000, 0x00000000, 0x00000000},
                              { 0x00000001, 0x00000000, 0x00000000, 0x00000000},
                              { 0xffffffff, 0x00000000, 0x00000000, 0x00000000},
                              { 0x80000000, 0x00000000, 0x00000000, 0x00000000},
                              { 0x00bc614e, 0x00000000, 0x00000000, 0x00000000},
                              { 0x00002710, 0x00000000, 0x00000000, 0x00000000} }
      0x000000C4: dcl_constantbuffer CB0[3], immediateIndexed
      0x000000D4: dcl_sampler s0, mode_default
      0x000000E0: dcl_sampler s1, mode_comparison
      0x000000EC: dcl_sampler s3, mode_default
      0x000000F8: dcl_resource_texture1d (float,float,float,float) t0
      0x00000108: dcl_resource_texture1darray (float,float,float,float) t1
      0x00000118: dcl_resource_texture2d (float,float,float,float) t2
      0x00000128: dcl_resource_texture2darray (float,float,float,float) t3
      0x00000138: dcl_resource_texture3d (float,float,float,float) t4
      0x00000148: dcl_resource_texturecube (float,float,float,float) t5
      0x00000158: dcl_resource_texture2dms(4) (float,float,float,float) t6
      0x00000168: dcl_resource_buffer (sint,sint,sint,sint) t7
      0x00000178: dcl_resource_texture2d (uint,uint,uint,uint) t8
      0x00000188: dcl_resource_texture2dmsarray(0) (snorm,snorm,snorm,snorm) t9
      0x00000198: dcl_resource_texture2d (unorm,unorm,unorm,unorm) t10
      0x000001A8: dcl_resource_texturecubearray (float,float,float,float) t11
      0x000001B8: dcl_input_ps_siv linear noperspective v0.z, position
      0x000001C8: dcl_input_ps linear v1.xyzw
      0x000001D4: dcl_input_ps constant v2.xyzw
      0x000001E0: dcl_input_ps linear noperspective v3.xy
      0x000001EC: dcl_input_ps linear centroid v4.x
      0x000001F8: dcl_input_ps_sgv constant v5.x, primitive_id
      0x00000208: dcl_input_ps_sgv constant v6.x, is_front_face
      0x00000218: dcl_output o0.xyzw
      0x00000224: dcl_output o2.xyzw
      0x00000230: dcl_output o3.x
      0x0000023C: dcl_output oDepth
      0x00000244: dcl_temps 6
   0  0x0000024C: sample r0.xyzw, v1.xxxx, t0.xyzw, s0
   1  0x00000270: sample_l r1.xyzw, v1.xyxx, t1.xyzw, s0, l(0x40000000)
   2  0x0000029C: add r0.xyzw, r0.xyzw, r1.xyzw
   3  0x000002B8: sample_aoffimmi(1,-2,0) r1.xyzw, v1.xyxx, t2.xyzw, s0
   4  0x000002E0: add r0.xyzw, r0.xyzw, r1.xyzw
   5  0x000002FC: sample_b r1.xyzw, v1.xyzx, t3.xyzw, s0, cb0[0].x
   6  0x0000032C: deriv_rtx r2.xyz, v1.xyzx
   7  0x00000340: deriv_rty r3.xyz, v1.xyzx
   8  0x00000354: sample_d r2.xyzw, v1.xyzx, t4.xyzw, s0, r2.xyzx, r3.xyzx
   9  0x00000388: add r1.xyzw, r1.xyzw, r2.xyzw
  10  0x000003A4: add r0.xyzw, r0.xyzw, r1.xyzw
  11  0x000003C0: sample r1.xyzw, v1.xyzx, t5.xyzw, s3
  12  0x000003E4: add r0.xyzw, r0.xyzw, r1.xyzw
  13  0x00000400: sample_c r1.x, v1.xyxx, t2.xxxx, s1, cb0[0].y
  14  0x00000430: sample_c_lz_aoffimmi(3,4,0) r1.y, v1.zwzz, t2.xxxx, s1, cb0[0].z
  15  0x00000464: add r1.x, r1.y, r1.x
  16  0x00000480: add r0.x, r0.x, r1.x
  17  0x0000049C: mov r1.xy, v2.xyxx
  18  0x000004B0: mov r1.zw, l(0x00000000,0x00000000,0x00000000,0x00000000)
  19  0x000004D0: ldms r1.xyzw, r1.xyzw, t6.xyzw, v2.z
  20  0x000004F4: mov r2.xyz, v2.xyzx
  21  0x00000508: mov r2.w, l(0x00000000)
  22  0x0000051C: ldms r3.xyzw, r2.xyzw, t9.xyzw, l(0x00000001)
  23  0x00000540: add r1.xyzw, r1.xyzw, r3.xyzw
  24  0x0000055C: ld_aoffimmi(-1,1,0) r3.xyzw, r2.xyww, t10.xyzw
  25  0x0000057C: add r1.xyzw, r1.xyzw, r3.xyzw
  26  0x00000598: add r0.xyzw, r0.xyzw, r1.xyzw
  27  0x000005B4: ld r1.xyzw, v2.xyww, t2.xyzw
  28  0x000005D0: ld r3.xyzw, v2.xyzw, t4.xyzw
  29  0x000005EC: add r1.xyzw, r1.xyzw, r3.xyzw
  30  0x00000608: add r0.xyzw, r0.xyzw, r1.xyzw
  31  0x00000624: resinfo_uint r1.xyz, l(0x00000001), t2.xywz
  32  0x00000640: resinfo r3.xy, l(0x00000000), t10.xyzw
  33  0x0000065C: utof r1.xyz, r1.xyzx
  34  0x00000670: mad r1.xy, r1.xyxx, r1.zzzz, r3.xyxx
  35  0x00000694: add r0.xy, r0.xyxx, r1.xyxx
  36  0x000006B0: and r1.x, v2.x, l(0x80000000)
  37  0x000006CC: imax r1.y, v2.x, -v2.x
  38  0x000006EC: udiv null, r1.y, r1.y, l(0x00000006)
  39  0x0000070C: ineg r1.z, r1.y
  40  0x00000720: movc r1.x, r1.x, r1.z, r1.y
  41  0x00000744: mov r1.y, cb0[1].y
  42  0x0000075C: mad r0.xyzw, icb[r1.x + 0].xyzw, icb[r1.y + 0].xyzw, r0.xyzw
  43  0x00000788: sample_l r1.xyzw, v1.xyzw, t11.xyzw, s0, l(0x00000000)
  44  0x000007B4: add r0.xyzw, r0.xyzw, r1.xyzw
  45  0x000007D0: lod r1.x, v1.xyxx, t2.x, s0
  46  0x000007F4: add r0.xyzw, r0.xyzw, r1.xxxx
  47  0x00000810: ld r1.xy, v2.xxxx, t7.xyzw
  48  0x0000082C: ld r1.zw, r2.yzww, t8.zwxy
  49  0x00000848: iadd r1.xy, r1.zwzz, r1.xyxx
  50  0x00000864: mov r1.zw, r1.xxxy
  51  0x00000878: mov r3.x, cb0[1].z
  52  0x00000890: mov r2.xyzw, r0.xyzw
  53  0x000008A4: mov r3.y, l(0x00000000)
  54  0x000008B8: loop 
  55  0x000008BC:   ige r3.z, r3.y, cb0[1].x
  56  0x000008DC:   breakc_nz r3.z
  57  0x000008E8:   itof r3.z, r3.y
  58  0x000008FC:   lt r3.z, r3.z, r2.x
  59  0x00000918:   if_nz r3.z
  60  0x00000924:     break 
  61  0x00000928:   endif 
  62  0x0000092C:   mad r4.xyzw, r2.xyzw, l(0x3f000000, 0x3f000000, 0x3f000000, 0x3f000000), l(0x3e800000, 0x3e800000, 0x3e800000, 0x3e800000)
  63  0x00000968:   ieq r3.z, r3.x, r3.y
  64  0x00000984:   if_nz r3.z
  65  0x00000990:     iadd r3.z, r3.y, l(0x00000001)
  66  0x000009AC:     mov r2.xyzw, r4.xyzw
  67  0x000009C0:     mov r3.y, r3.z
  68  0x000009D4:     continue 
  69  0x000009D8:   endif 
  70  0x000009DC:   iadd r1.zw, r1.zzzw, r3.yyyy
  71  0x000009F8:   mov r2.xyzw, r4.xyzw
  72  0x00000A0C:   iadd r3.y, r3.y, l(0x00000001)
  73  0x00000A28: endloop 
  74  0x00000A2C: mov o2.xy, r1.zwzz
  75  0x00000A40: switch cb0[1].w
  76  0x00000A50:   case l(0x00000000)
  77  0x00000A5C:   mov r2.x, l(0x3f800000)
  78  0x00000A70:   break 
  79  0x00000A74:   case l(0x00000003)
  80  0x00000A80:   mov r2.y, l(0x40000000)
  81  0x00000A94:   break 
  82  0x00000A98:   case l(0x00000007)
  83  0x00000AA4:   mov r2.z, l(0x40400000)
  84  0x00000AB8:   break 
  85  0x00000ABC:   default 
  86  0x00000AC0:   mov r2.w, l(0xc0800000)
  87  0x00000AD4:   break 
  88  0x00000AD8: endswitch 
  89  0x00000ADC: lt r0.x, r2.w, l(0xc47a0000)
  90  0x00000AF8: discard_nz r0.x
  91  0x00000B04: xor r0.x, r2.y, cb0[2].x
  92  0x00000B24: ishl r0.y, r0.x, l(0x00000003)
  93  0x00000B40: ushr r0.x, r0.x, cb0[2].y
  94  0x00000B60: not r0.z, cb0[2].z
  95  0x00000B78: and r0.x, r0.z, r0.x
  96  0x00000B94: or r0.x, r0.x, r0.y
  97  0x00000BB0: udiv null, r0.y, v5.x, l(0x00000005)
  98  0x00000BD0: iadd r0.x, r0.x, icb[r0.y + 6].x
  99  0x00000BF4: udiv r0.y, null, r0.x, cb0[2].w
 100  0x00000C18: iadd r0.z, cb0[2].w, l(0x00000001)
 101  0x00000C38: udiv null, r0.x, r0.x, r0.z
 102  0x00000C58: iadd r0.x, r0.x, r0.y
 103  0x00000C74: ishr r0.y, r0.x, l(0x00000002)
 104  0x00000C90: imin r0.z, r0.x, cb0[1].y
 105  0x00000CB0: imad r0.y, r0.y, cb0[1].x, r0.z
 106  0x00000CD8: imax r0.z, r0.x, -cb0[1].z
 107  0x00000CFC: iadd r0.y, -r0.z, r0.y
 108  0x00000D1C: imax r0.z, -r0.x, r0.x
 109  0x00000D3C: iadd r0.y, r0.z, r0.y
 110  0x00000D58: xor r0.w, r0.x, cb0[1].w
 111  0x00000D78: imax r1.x, cb0[1].w, -cb0[1].w
 112  0x00000DA0: udiv r0.z, null, r0.z, r1.x
 113  0x00000DC0: ineg r1.x, r0.z
 114  0x00000DD4: and r0.w, r0.w, l(0x80000000)
 115  0x00000DF0: movc r0.z, r0.w, r1.x, r0.z
 116  0x00000E14: iadd o2.z, -r0.z, r0.y
 117  0x00000E34: movc r1.xyzw, v6.xxxx, r2.xyzw, -r2.wzyx
 118  0x00000E5C: and r3.xyzw, r1.xyzw, l(0x7fffffff, 0x7fffffff, 0x7fffffff, 0x7fffffff)
 119  0x00000E84: ieq r3.xyzw, r3.xyzw, l(0x7f800000, 0x7f800000, 0x7f800000, 0x7f800000)
 120  0x00000EAC: movc r1.xyzw, r3.xyzw, l(0x3f800000,0x3f800000,0x3f800000,0x3f800000), r1.xyzw
 121  0x00000EDC: sincos r3.xyzw, null, r2.xyzw
 122  0x00000EF4: sincos null, r4.xyzw, r2.yxwz
 123  0x00000F0C: rsq r5.xyzw, |r2.xyzw|
 124  0x00000F24: mad r3.xyzw, r3.xyzw, r4.xyzw, r5.xyzw
 125  0x00000F48: exp r4.xyzw, r2.xyzw
 126  0x00000F5C: add r3.xyzw, r3.xyzw, r4.xyzw
 127  0x00000F78: log r4.xyzw, |r2.xyzw|
 128  0x00000F90: add r3.xyzw, r3.xyzw, r4.xyzw
 129  0x00000FAC: frc r4.xyzw, r2.xyzw
 130  0x00000FC0: add r3.xyzw, r3.xyzw, r4.xyzw
 131  0x00000FDC: round_ne r4.xyzw, r2.xyzw
 132  0x00000FF0: add r3.xyzw, r3.xyzw, r4.xyzw
 133  0x0000100C: round_ni r4.xyzw, r2.xyzw
 134  0x00001020: add r3.xyzw, r3.xyzw, r4.xyzw
 135  0x0000103C: round_pi r4.xyzw, r2.xyzw
 136  0x00001050: add r3.xyzw, r3.xyzw, r4.xyzw
 137  0x0000106C: round_z r4.xyzw, r2.xyzw
 138  0x00001080: add r3.xyzw, r3.xyzw, r4.xyzw
 139  0x0000109C: add r1.xyzw, r1.xyzw, r3.xyzw
 140  0x000010B8: mad r3.xyzw, v3.xyxy, v4.xxxx, r1.xyzw
 141  0x000010DC: mad r1.xyzw, r2.xyzw, cb0[0].xyzw, r1.xyzw
 142  0x00001104: add_sat r1.xyzw, r1.xyzw, r3.xyzw
 143  0x00001120: div r3.xyzw, l(0x3f800000, 0x3f800000, 0x3f800000, 0x3f800000), r2.xyzw
 144  0x00001148: add r1.xyzw, r1.xyzw, r3.xyzw
 145  0x00001164: sqrt r3.xyzw, |r2.xyzw|
 146  0x0000117C: add o0.xyzw, r1.xyzw, r3.xyzw
 147  0x00001198: ftoi o2.w, v1.z
 148  0x000011AC: ftou r0.y, v1.w
 149  0x000011C0: iadd o3.x, r0.y, r0.x
 150  0x000011DC: mad_sat oDepth, r2.x, l(0x358637bd), v0.z
 151  0x000011FC: ret 

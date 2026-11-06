      0x00000000: ps_4_0
      0x00000008: dcl_immediateConstantBuffer { { 0x3f800000, 0x00000000, 0x00000000, 0x3f800000},
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
      0x000000C0: dcl_constantbuffer CB0[3], immediateIndexed
      0x000000D0: dcl_sampler s0, mode_default
      0x000000DC: dcl_sampler s1, mode_comparison
      0x000000E8: dcl_sampler s3, mode_default
      0x000000F4: dcl_resource_texture1d (float,float,float,float) t0
      0x00000104: dcl_resource_texture1darray (float,float,float,float) t1
      0x00000114: dcl_resource_texture2d (float,float,float,float) t2
      0x00000124: dcl_resource_texture2darray (float,float,float,float) t3
      0x00000134: dcl_resource_texture3d (float,float,float,float) t4
      0x00000144: dcl_resource_texturecube (float,float,float,float) t5
      0x00000154: dcl_resource_texture2dms(4) (float,float,float,float) t6
      0x00000164: dcl_resource_buffer (sint,sint,sint,sint) t7
      0x00000174: dcl_resource_texture2d (uint,uint,uint,uint) t8
      0x00000184: dcl_resource_texture2dmsarray(2) (snorm,snorm,snorm,snorm) t9
      0x00000194: dcl_resource_texture2d (unorm,unorm,unorm,unorm) t10
      0x000001A4: dcl_input_ps_siv linear noperspective v0.z, position
      0x000001B4: dcl_input_ps linear v1.xyzw
      0x000001C0: dcl_input_ps constant v2.xyzw
      0x000001CC: dcl_input_ps linear noperspective v3.xy
      0x000001D8: dcl_input_ps linear centroid v4.x
      0x000001E4: dcl_input_ps_sgv constant v5.x, primitive_id
      0x000001F4: dcl_input_ps_sgv constant v6.x, is_front_face
      0x00000204: dcl_output o0.xyzw
      0x00000210: dcl_output o2.xyzw
      0x0000021C: dcl_output o3.x
      0x00000228: dcl_output oDepth
      0x00000230: dcl_temps 6
   0  0x00000238: sample r0.xyzw, v1.xxxx, t0.xyzw, s0
   1  0x0000025C: sample_l r1.xyzw, v1.xyxx, t1.xyzw, s0, l(0x40000000)
   2  0x00000288: add r0.xyzw, r0.xyzw, r1.xyzw
   3  0x000002A4: sample_aoffimmi(1,-2,0) r1.xyzw, v1.xyxx, t2.xyzw, s0
   4  0x000002CC: add r0.xyzw, r0.xyzw, r1.xyzw
   5  0x000002E8: sample_b r1.xyzw, v1.xyzx, t3.xyzw, s0, cb0[0].x
   6  0x00000318: deriv_rtx r2.xyz, v1.xyzx
   7  0x0000032C: deriv_rty r3.xyz, v1.xyzx
   8  0x00000340: sample_d r2.xyzw, v1.xyzx, t4.xyzw, s0, r2.xyzx, r3.xyzx
   9  0x00000374: add r1.xyzw, r1.xyzw, r2.xyzw
  10  0x00000390: add r0.xyzw, r0.xyzw, r1.xyzw
  11  0x000003AC: sample r1.xyzw, v1.xyzx, t5.xyzw, s3
  12  0x000003D0: add r0.xyzw, r0.xyzw, r1.xyzw
  13  0x000003EC: sample_c r1.x, v1.xyxx, t2.xxxx, s1, cb0[0].y
  14  0x0000041C: sample_c_lz_aoffimmi(3,4,0) r1.y, v1.zwzz, t2.xxxx, s1, cb0[0].z
  15  0x00000450: add r1.x, r1.y, r1.x
  16  0x0000046C: add r0.x, r0.x, r1.x
  17  0x00000488: mov r1.xy, v2.xyxx
  18  0x0000049C: mov r1.zw, l(0x00000000,0x00000000,0x00000000,0x00000000)
  19  0x000004BC: ldms r1.xyzw, r1.xyzw, t6.xyzw, l(0x00000003)
  20  0x000004E0: mov r2.xyz, v2.xyzx
  21  0x000004F4: mov r2.w, l(0x00000000)
  22  0x00000508: ldms r3.xyzw, r2.xyzw, t9.xyzw, l(0x00000001)
  23  0x0000052C: add r1.xyzw, r1.xyzw, r3.xyzw
  24  0x00000548: ld_aoffimmi(-1,1,0) r3.xyzw, r2.xyww, t10.xyzw
  25  0x00000568: add r1.xyzw, r1.xyzw, r3.xyzw
  26  0x00000584: add r0.xyzw, r0.xyzw, r1.xyzw
  27  0x000005A0: ld r1.xyzw, v2.xyww, t2.xyzw
  28  0x000005BC: ld r3.xyzw, v2.xyzw, t4.xyzw
  29  0x000005D8: add r1.xyzw, r1.xyzw, r3.xyzw
  30  0x000005F4: add r0.xyzw, r0.xyzw, r1.xyzw
  31  0x00000610: resinfo_uint r1.xyzw, l(0x00000001), t2.xyzw
  32  0x0000062C: resinfo r3.xyzw, l(0x00000000), t10.xyzw
  33  0x00000648: utof r1.xyz, r1.xywx
  34  0x0000065C: mad r1.xy, r1.xyxx, r1.zzzz, r3.xyxx
  35  0x00000680: add r0.xy, r0.xyxx, r1.xyxx
  36  0x0000069C: and r1.x, v2.x, l(0x80000000)
  37  0x000006B8: imax r1.y, v2.x, -v2.x
  38  0x000006D8: udiv null, r1.y, r1.y, l(0x00000006)
  39  0x000006F8: ineg r1.z, r1.y
  40  0x0000070C: movc r1.x, r1.x, r1.z, r1.y
  41  0x00000730: mov r1.y, cb0[1].y
  42  0x00000748: mad r0.xyzw, icb[r1.x + 0].xyzw, icb[r1.y + 0].xyzw, r0.xyzw
  43  0x00000774: ld r1.xyzw, v2.xxxx, t7.xyzw
  44  0x00000790: ld r2.xyzw, r2.yzww, t8.xyzw
  45  0x000007AC: iadd r1.xy, r1.xyxx, r2.xyxx
  46  0x000007C8: mov r1.zw, r1.xxxy
  47  0x000007DC: mov r3.x, cb0[1].z
  48  0x000007F4: mov r2.xyzw, r0.xyzw
  49  0x00000808: mov r3.y, l(0x00000000)
  50  0x0000081C: loop 
  51  0x00000820:   ige r3.z, r3.y, cb0[1].x
  52  0x00000840:   breakc_nz r3.z
  53  0x0000084C:   itof r3.z, r3.y
  54  0x00000860:   lt r3.z, r3.z, r2.x
  55  0x0000087C:   if_nz r3.z
  56  0x00000888:     break 
  57  0x0000088C:   endif 
  58  0x00000890:   mad r4.xyzw, r2.xyzw, l(0x3f000000, 0x3f000000, 0x3f000000, 0x3f000000), l(0x3e800000, 0x3e800000, 0x3e800000, 0x3e800000)
  59  0x000008CC:   ieq r3.z, r3.x, r3.y
  60  0x000008E8:   if_nz r3.z
  61  0x000008F4:     iadd r3.z, r3.y, l(0x00000001)
  62  0x00000910:     mov r2.xyzw, r4.xyzw
  63  0x00000924:     mov r3.y, r3.z
  64  0x00000938:     continue 
  65  0x0000093C:   endif 
  66  0x00000940:   iadd r1.zw, r1.zzzw, r3.yyyy
  67  0x0000095C:   mov r2.xyzw, r4.xyzw
  68  0x00000970:   iadd r3.y, r3.y, l(0x00000001)
  69  0x0000098C: endloop 
  70  0x00000990: mov o2.xy, r1.zwzz
  71  0x000009A4: switch cb0[1].w
  72  0x000009B4:   case l(0x00000000)
  73  0x000009C0:   mov r2.x, l(0x3f800000)
  74  0x000009D4:   break 
  75  0x000009D8:   case l(0x00000003)
  76  0x000009E4:   mov r2.y, l(0x40000000)
  77  0x000009F8:   break 
  78  0x000009FC:   case l(0x00000007)
  79  0x00000A08:   mov r2.z, l(0x40400000)
  80  0x00000A1C:   break 
  81  0x00000A20:   default 
  82  0x00000A24:   mov r2.w, l(0xc0800000)
  83  0x00000A38:   break 
  84  0x00000A3C: endswitch 
  85  0x00000A40: lt r0.x, r2.w, l(0xc47a0000)
  86  0x00000A5C: discard_nz r0.x
  87  0x00000A68: xor r0.x, r2.y, cb0[2].x
  88  0x00000A88: ishl r0.y, r0.x, l(0x00000003)
  89  0x00000AA4: ushr r0.x, r0.x, cb0[2].y
  90  0x00000AC4: not r0.z, cb0[2].z
  91  0x00000ADC: and r0.x, r0.z, r0.x
  92  0x00000AF8: or r0.x, r0.x, r0.y
  93  0x00000B14: udiv null, r0.y, v5.x, l(0x00000005)
  94  0x00000B34: iadd r0.x, r0.x, icb[r0.y + 6].x
  95  0x00000B58: udiv r0.y, null, r0.x, cb0[2].w
  96  0x00000B7C: iadd r0.z, cb0[2].w, l(0x00000001)
  97  0x00000B9C: udiv null, r0.x, r0.x, r0.z
  98  0x00000BBC: iadd r0.x, r0.x, r0.y
  99  0x00000BD8: ishr r0.y, r0.x, l(0x00000002)
 100  0x00000BF4: imin r0.z, r0.x, cb0[1].y
 101  0x00000C14: imad r0.y, r0.y, cb0[1].x, r0.z
 102  0x00000C3C: imax r0.z, r0.x, -cb0[1].z
 103  0x00000C60: iadd r0.y, -r0.z, r0.y
 104  0x00000C80: imax r0.z, -r0.x, r0.x
 105  0x00000CA0: iadd r0.y, r0.z, r0.y
 106  0x00000CBC: xor r0.w, r0.x, cb0[1].w
 107  0x00000CDC: imax r1.x, cb0[1].w, -cb0[1].w
 108  0x00000D04: udiv r0.z, null, r0.z, r1.x
 109  0x00000D24: ineg r1.x, r0.z
 110  0x00000D38: and r0.w, r0.w, l(0x80000000)
 111  0x00000D54: movc r0.z, r0.w, r1.x, r0.z
 112  0x00000D78: iadd o2.z, -r0.z, r0.y
 113  0x00000D98: movc r1.xyzw, v6.xxxx, r2.xyzw, -r2.wzyx
 114  0x00000DC0: and r3.xyzw, r1.xyzw, l(0x7fffffff, 0x7fffffff, 0x7fffffff, 0x7fffffff)
 115  0x00000DE8: ieq r3.xyzw, r3.xyzw, l(0x7f800000, 0x7f800000, 0x7f800000, 0x7f800000)
 116  0x00000E10: movc r1.xyzw, r3.xyzw, l(0x3f800000,0x3f800000,0x3f800000,0x3f800000), r1.xyzw
 117  0x00000E40: sincos r3.xyzw, null, r2.xyzw
 118  0x00000E58: sincos null, r4.xyzw, r2.yxwz
 119  0x00000E70: rsq r5.xyzw, |r2.xyzw|
 120  0x00000E88: mad r3.xyzw, r3.xyzw, r4.xyzw, r5.xyzw
 121  0x00000EAC: exp r4.xyzw, r2.xyzw
 122  0x00000EC0: add r3.xyzw, r3.xyzw, r4.xyzw
 123  0x00000EDC: log r4.xyzw, |r2.xyzw|
 124  0x00000EF4: add r3.xyzw, r3.xyzw, r4.xyzw
 125  0x00000F10: frc r4.xyzw, r2.xyzw
 126  0x00000F24: add r3.xyzw, r3.xyzw, r4.xyzw
 127  0x00000F40: round_ne r4.xyzw, r2.xyzw
 128  0x00000F54: add r3.xyzw, r3.xyzw, r4.xyzw
 129  0x00000F70: round_ni r4.xyzw, r2.xyzw
 130  0x00000F84: add r3.xyzw, r3.xyzw, r4.xyzw
 131  0x00000FA0: round_pi r4.xyzw, r2.xyzw
 132  0x00000FB4: add r3.xyzw, r3.xyzw, r4.xyzw
 133  0x00000FD0: round_z r4.xyzw, r2.xyzw
 134  0x00000FE4: add r3.xyzw, r3.xyzw, r4.xyzw
 135  0x00001000: add r1.xyzw, r1.xyzw, r3.xyzw
 136  0x0000101C: mad r3.xyzw, v3.xyxy, v4.xxxx, r1.xyzw
 137  0x00001040: mad r1.xyzw, r2.xyzw, cb0[0].xyzw, r1.xyzw
 138  0x00001068: add_sat r1.xyzw, r1.xyzw, r3.xyzw
 139  0x00001084: div r3.xyzw, l(0x3f800000, 0x3f800000, 0x3f800000, 0x3f800000), r2.xyzw
 140  0x000010AC: add r1.xyzw, r1.xyzw, r3.xyzw
 141  0x000010C8: sqrt r3.xyzw, |r2.xyzw|
 142  0x000010E0: add o0.xyzw, r1.xyzw, r3.xyzw
 143  0x000010FC: ftoi o2.w, v1.z
 144  0x00001110: ftou r0.y, v1.w
 145  0x00001124: iadd o3.x, r0.y, r0.x
 146  0x00001140: mad_sat oDepth, r2.x, l(0x358637bd), v0.z
 147  0x00001160: ret 

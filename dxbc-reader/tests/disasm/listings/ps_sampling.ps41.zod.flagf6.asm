      0x00000000: ps_4_1
      0x00000008: dcl_globalFlags refactoringAllowed | skipOptimization
      0x0000000C: dcl_constantbuffer CB0[3], immediateIndexed
      0x0000001C: dcl_sampler s0, mode_default
      0x00000028: dcl_sampler s1, mode_comparison
      0x00000034: dcl_sampler s3, mode_default
      0x00000040: dcl_resource_texture1d (float,float,float,float) t0
      0x00000050: dcl_resource_texture1darray (float,float,float,float) t1
      0x00000060: dcl_resource_texture2d (float,float,float,float) t2
      0x00000070: dcl_resource_texture2darray (float,float,float,float) t3
      0x00000080: dcl_resource_texture3d (float,float,float,float) t4
      0x00000090: dcl_resource_texturecube (float,float,float,float) t5
      0x000000A0: dcl_resource_texture2dms(4) (float,float,float,float) t6
      0x000000B0: dcl_resource_buffer (sint,sint,sint,sint) t7
      0x000000C0: dcl_resource_texture2d (uint,uint,uint,uint) t8
      0x000000D0: dcl_resource_texture2dmsarray(0) (snorm,snorm,snorm,snorm) t9
      0x000000E0: dcl_resource_texture2d (unorm,unorm,unorm,unorm) t10
      0x000000F0: dcl_resource_texturecubearray (float,float,float,float) t11
      0x00000100: dcl_input_ps_siv linear noperspective v0.z, position
      0x00000110: dcl_input_ps linear v1.xyzw
      0x0000011C: dcl_input_ps constant v2.xyzw
      0x00000128: dcl_input_ps linear noperspective v3.xy
      0x00000134: dcl_input_ps linear centroid v4.x
      0x00000140: dcl_input_ps_sgv constant v5.x, primitive_id
      0x00000150: dcl_input_ps_sgv constant v6.x, is_front_face
      0x00000160: dcl_output o0.xyzw
      0x0000016C: dcl_output o2.xyzw
      0x00000178: dcl_output o3.x
      0x00000184: dcl_output oDepth
      0x0000018C: dcl_temps 6
      0x00000194: dcl_indexableTemp x0[6], 4
      0x000001A4: dcl_indexableTemp x1[5], 4
   0  0x000001B4: itof r0.xyzw, l(0x00000001, 0x00000000, 0x00000000, 0x00000001)
   1  0x000001D4: itof r1.xyzw, l(0x00000000, 0x00000001, 0x00000000, 0x00000001)
   2  0x000001F4: itof r2.xyzw, l(0x00000000, 0x00000000, 0x00000001, 0x00000001)
   3  0x00000214: itof r3.yw, l(0x00000000, 0x00000000, 0x00000000, 0x000186a0)
   4  0x00000234: mov r4.x, l(0x7f800000)
   5  0x00000248: mov r4.y, l(0xff800000)
   6  0x0000025C: mov r4.z, l(0x00000001)
   7  0x00000270: mov r4.w, l(0x80000001)
   8  0x00000284: mov x0[0].xyzw, r0.xyzw
   9  0x0000029C: mov x0[1].xyzw, r1.xyzw
  10  0x000002B4: mov x0[2].xyzw, r2.xyzw
  11  0x000002CC: mov x0[3].xyzw, l(0x3f000000,0x3e800000,0x322bcc77,0xe0ad78ec)
  12  0x000002F0: mov r3.xz, l(0x7f7fffff,0x00000000,0x3eaaaaab,0x00000000)
  13  0x00000310: mov x0[4].xyzw, r3.xyzw
  14  0x00000328: mov x0[5].xyzw, r4.xyzw
  15  0x00000340: mov r0.xyz, l(0x00000001,0x00bc614e,0x00002710,0x00000000)
  16  0x00000360: mov x1[0].x, r0.x
  17  0x00000378: mov x1[1].x, l(0xffffffff)
  18  0x00000390: mov x1[2].x, l(0x80000000)
  19  0x000003A8: mov x1[3].x, r0.y
  20  0x000003C0: mov x1[4].x, r0.z
  21  0x000003D8: sample r0.xyzw, v1.xxxx, t0.xyzw, s0
  22  0x000003FC: itof r1.x, l(0x00000002)
  23  0x00000410: sample_l r1.xyzw, v1.xyxx, t1.xyzw, s0, r1.x
  24  0x0000043C: add r0.xyzw, r0.xyzw, r1.xyzw
  25  0x00000458: sample_aoffimmi(1,-2,0) r1.xyzw, v1.xyxx, t2.xyzw, s0
  26  0x00000480: add r0.xyzw, r0.xyzw, r1.xyzw
  27  0x0000049C: sample_b r1.xyzw, v1.xyzx, t3.xyzw, s0, cb0[0].x
  28  0x000004CC: deriv_rtx r2.xyz, v1.xyzx
  29  0x000004E0: deriv_rty r3.xyz, v1.xyzx
  30  0x000004F4: sample_d r2.xyzw, v1.xyzx, t4.xyzw, s0, r2.xyzx, r3.xyzx
  31  0x00000528: add r1.xyzw, r1.xyzw, r2.xyzw
  32  0x00000544: add r0.xyzw, r0.xyzw, r1.xyzw
  33  0x00000560: sample r1.xyzw, v1.xyzx, t5.xyzw, s3
  34  0x00000584: add r0.xyzw, r0.xyzw, r1.xyzw
  35  0x000005A0: sample_c r1.x, v1.xyxx, t2.xxxx, s1, cb0[0].y
  36  0x000005D0: sample_c_lz_aoffimmi(3,4,0) r1.y, v1.zwzz, t2.xxxx, s1, cb0[0].z
  37  0x00000604: add r1.x, r1.y, r1.x
  38  0x00000620: add r0.x, r0.x, r1.x
  39  0x0000063C: mov r1.xy, v2.xyxx
  40  0x00000650: mov r1.zw, l(0x00000000,0x00000000,0x00000000,0x00000000)
  41  0x00000670: ldms r1.xyzw, r1.xyzw, t6.xyzw, v2.z
  42  0x00000694: mov r2.xyz, v2.xyzx
  43  0x000006A8: mov r2.w, l(0x00000000)
  44  0x000006BC: ldms r3.xyzw, r2.xyzw, t9.xyzw, l(0x00000001)
  45  0x000006E0: add r1.xyzw, r1.xyzw, r3.xyzw
  46  0x000006FC: ld_aoffimmi(-1,1,0) r3.xyzw, r2.xyww, t10.xyzw
  47  0x0000071C: add r1.xyzw, r1.xyzw, r3.xyzw
  48  0x00000738: add r0.xyzw, r0.xyzw, r1.xyzw
  49  0x00000754: ld r1.xyzw, v2.xyww, t2.xyzw
  50  0x00000770: ld r3.xyzw, v2.xyzw, t4.xyzw
  51  0x0000078C: add r1.xyzw, r1.xyzw, r3.xyzw
  52  0x000007A8: add r0.xyzw, r0.xyzw, r1.xyzw
  53  0x000007C4: resinfo_uint r1.xyz, l(0x00000001), t2.xywz
  54  0x000007E0: mov r1.x, r1.x
  55  0x000007F4: mov r1.y, r1.y
  56  0x00000808: mov r1.z, r1.z
  57  0x0000081C: resinfo r3.xy, l(0x00000000), t10.xyzw
  58  0x00000838: mov r3.x, r3.x
  59  0x0000084C: mov r3.y, r3.y
  60  0x00000860: utof r4.x, r1.x
  61  0x00000874: utof r4.y, r1.y
  62  0x00000888: utof r1.xy, r1.zzzz
  63  0x0000089C: mul r1.xy, r1.xyxx, r4.xyxx
  64  0x000008B8: add r1.xy, r3.xyxx, r1.xyxx
  65  0x000008D4: add r0.xy, r0.xyxx, r1.xyxx
  66  0x000008F0: ineg r1.x, v2.x
  67  0x00000904: ineg r1.y, l(0x00000006)
  68  0x00000918: and r1.z, v2.x, l(0x80000000)
  69  0x00000934: imax r1.x, r1.x, v2.x
  70  0x00000950: imax r1.y, r1.y, l(0x00000006)
  71  0x0000096C: udiv null, r1.x, r1.x, r1.y
  72  0x0000098C: ineg r1.y, r1.x
  73  0x000009A0: ine r1.z, l(0x00000000, 0x00000000, 0x00000000, 0x00000000), r1.z
  74  0x000009C8: movc r1.x, r1.z, r1.y, r1.x
  75  0x000009EC: mov r1.xyzw, x0[r1.x + 0].xyzw
  76  0x00000A08: mov r2.x, cb0[1].y
  77  0x00000A20: mov r3.xyzw, x0[r2.x + 0].xyzw
  78  0x00000A3C: mul r1.xyzw, r1.xyzw, r3.xyzw
  79  0x00000A58: add r0.xyzw, r0.xyzw, r1.xyzw
  80  0x00000A74: itof r1.x, l(0x00000000)
  81  0x00000A88: sample_l r1.xyzw, v1.xyzw, t11.xyzw, s0, r1.x
  82  0x00000AB4: add r0.xyzw, r0.xyzw, r1.xyzw
  83  0x00000AD0: lod r1.x, v1.xyxx, t2.x, s0
  84  0x00000AF4: add r0.xyzw, r0.xyzw, r1.xxxx
  85  0x00000B10: ld r1.xy, v2.xxxx, t7.xyzw
  86  0x00000B2C: ld r1.zw, r2.yzww, t8.zwxy
  87  0x00000B48: iadd r1.xy, r1.zwzz, r1.xyxx
  88  0x00000B64: mov r1.z, l(0x00000000)
  89  0x00000B78: mov r2.yzw, r0.yyzw
  90  0x00000B8C: mov r3.xy, r1.xyxx
  91  0x00000BA0: mov r1.w, cb0[1].z
  92  0x00000BB8: mov r2.x, r0.x
  93  0x00000BCC: mov r4.x, r1.z
  94  0x00000BE0: loop 
  95  0x00000BE4:   ilt r4.y, r4.x, cb0[1].x
  96  0x00000C04:   breakc_z r4.y
  97  0x00000C10:   itof r4.y, r4.x
  98  0x00000C24:   lt r4.y, r4.y, r2.x
  99  0x00000C40:   if_nz r4.y
 100  0x00000C4C:     mov r4.y, r2.x
 101  0x00000C60:     mov r2.x, r4.y
 102  0x00000C74:     break 
 103  0x00000C78:   endif 
 104  0x00000C7C:   mul r5.xyzw, r2.xyzw, l(0x3f000000, 0x3f000000, 0x3f000000, 0x3f000000)
 105  0x00000CA4:   add r5.xyzw, r5.xyzw, l(0x3e800000, 0x3e800000, 0x3e800000, 0x3e800000)
 106  0x00000CCC:   ieq r4.y, r1.w, r4.x
 107  0x00000CE8:   if_nz r4.y
 108  0x00000CF4:     iadd r4.x, r4.x, l(0x00000001)
 109  0x00000D10:     mov r2.yzw, r5.yyzw
 110  0x00000D24:     mov r2.x, r5.x
 111  0x00000D38:     continue 
 112  0x00000D3C:   endif 
 113  0x00000D40:   iadd r3.xy, r3.xyxx, r4.xxxx
 114  0x00000D5C:   mov r2.yzw, r5.yyzw
 115  0x00000D70:   mov r2.x, r5.x
 116  0x00000D84:   iadd r4.x, r4.x, l(0x00000001)
 117  0x00000DA0: endloop 
 118  0x00000DA4: mov r0.x, cb0[1].w
 119  0x00000DBC: switch r0.x
 120  0x00000DC8:   case l(0x00000000)
 121  0x00000DD4:   itof r2.x, l(0x00000001)
 122  0x00000DE8:   break 
 123  0x00000DEC:   case l(0x00000003)
 124  0x00000DF8:   itof r2.y, l(0x00000002)
 125  0x00000E0C:   mov r2.xyzw, r2.xyzw
 126  0x00000E20:   break 
 127  0x00000E24:   case l(0x00000007)
 128  0x00000E30:   itof r2.z, l(0x00000003)
 129  0x00000E44:   mov r2.xyzw, r2.xyzw
 130  0x00000E58:   break 
 131  0x00000E5C:   default 
 132  0x00000E60:   itof r2.w, l(0xfffffffc)
 133  0x00000E74:   mov r2.xyzw, r2.xyzw
 134  0x00000E88:   break 
 135  0x00000E8C: endswitch 
 136  0x00000E90: itof r0.x, l(0xfffffc18)
 137  0x00000EA4: lt r0.x, r2.w, r0.x
 138  0x00000EC0: if_nz r0.x
 139  0x00000ECC:   discard_nz l(0xffffffff)
 140  0x00000ED8: endif 
 141  0x00000EDC: xor r0.x, r2.y, cb0[2].x
 142  0x00000EFC: mov r0.y, l(0x00000003)
 143  0x00000F10: ishl r0.y, r0.x, r0.y
 144  0x00000F2C: ushr r0.x, r0.x, cb0[2].y
 145  0x00000F4C: not r0.z, cb0[2].z
 146  0x00000F64: and r0.x, r0.z, r0.x
 147  0x00000F80: or r0.x, r0.x, r0.y
 148  0x00000F9C: mov r0.y, l(0x00000005)
 149  0x00000FB0: udiv null, r0.y, v5.x, r0.y
 150  0x00000FD0: mov r0.y, x1[r0.y + 0].x
 151  0x00000FEC: iadd r0.x, r0.y, r0.x
 152  0x00001008: udiv r0.y, null, r0.x, cb0[2].w
 153  0x0000102C: mov r0.z, l(0x00000001)
 154  0x00001040: iadd r0.z, r0.z, cb0[2].w
 155  0x00001060: udiv null, r0.x, r0.x, r0.z
 156  0x00001080: iadd r0.x, r0.x, r0.y
 157  0x0000109C: mov r0.x, r0.x
 158  0x000010B0: ishr r0.y, r0.x, l(0x00000002)
 159  0x000010CC: imul null, r0.y, r0.y, cb0[1].x
 160  0x000010F0: imin r0.z, r0.x, cb0[1].y
 161  0x00001110: iadd r0.y, r0.z, r0.y
 162  0x0000112C: ineg r0.z, r1.w
 163  0x00001140: imax r0.z, r0.z, r0.x
 164  0x0000115C: ineg r0.z, r0.z
 165  0x00001170: iadd r0.y, r0.z, r0.y
 166  0x0000118C: ineg r0.z, r0.x
 167  0x000011A0: imax r0.z, r0.z, r0.x
 168  0x000011BC: iadd r0.y, r0.z, r0.y
 169  0x000011D8: ineg r0.z, r0.x
 170  0x000011EC: ineg r0.w, cb0[1].w
 171  0x00001204: xor r1.x, r0.x, cb0[1].w
 172  0x00001224: imax r0.z, r0.x, r0.z
 173  0x00001240: imax r0.w, r0.w, cb0[1].w
 174  0x00001260: udiv r0.z, null, r0.z, r0.w
 175  0x00001280: ineg r0.w, r0.z
 176  0x00001294: and r1.x, r1.x, l(0x80000000)
 177  0x000012B0: ine r1.x, l(0x00000000, 0x00000000, 0x00000000, 0x00000000), r1.x
 178  0x000012D8: movc r0.z, r1.x, r0.w, r0.z
 179  0x000012FC: ineg r0.z, r0.z
 180  0x00001310: iadd r3.z, r0.z, r0.y
 181  0x0000132C: mov r1.xyzw, -r2.wzyx
 182  0x00001344: movc r1.xyzw, v6.xxxx, r2.xyzw, r1.xyzw
 183  0x00001368: and r4.xyzw, r1.xyzw, l(0x7fffffff, 0x7fffffff, 0x7fffffff, 0x7fffffff)
 184  0x00001390: ieq r4.xyzw, r4.xyzw, l(0x7f800000, 0x7f800000, 0x7f800000, 0x7f800000)
 185  0x000013B8: itof r5.xyzw, l(0x00000001, 0x00000001, 0x00000001, 0x00000001)
 186  0x000013D8: movc r1.xyzw, r4.xyzw, r5.xyzw, r1.xyzw
 187  0x000013FC: sincos r4.xyzw, null, r2.xyzw
 188  0x00001414: sincos null, r5.xyzw, r2.yxwz
 189  0x0000142C: mul r4.xyzw, r4.xyzw, r5.xyzw
 190  0x00001448: mov r5.xyzw, -r2.xyzw
 191  0x00001460: max r5.xyzw, r2.xyzw, r5.xyzw
 192  0x0000147C: rsq r5.xyzw, r5.xyzw
 193  0x00001490: add r4.xyzw, r4.xyzw, r5.xyzw
 194  0x000014AC: exp r5.xyzw, r2.xyzw
 195  0x000014C0: add r4.xyzw, r4.xyzw, r5.xyzw
 196  0x000014DC: mov r5.xyzw, -r2.xyzw
 197  0x000014F4: max r5.xyzw, r2.xyzw, r5.xyzw
 198  0x00001510: log r5.xyzw, r5.xyzw
 199  0x00001524: add r4.xyzw, r4.xyzw, r5.xyzw
 200  0x00001540: frc r5.xyzw, r2.xyzw
 201  0x00001554: add r4.xyzw, r4.xyzw, r5.xyzw
 202  0x00001570: round_ne r5.xyzw, r2.xyzw
 203  0x00001584: add r4.xyzw, r4.xyzw, r5.xyzw
 204  0x000015A0: round_ni r5.xyzw, r2.xyzw
 205  0x000015B4: add r4.xyzw, r4.xyzw, r5.xyzw
 206  0x000015D0: round_pi r5.xyzw, r2.xyzw
 207  0x000015E4: add r4.xyzw, r4.xyzw, r5.xyzw
 208  0x00001600: round_z r5.xyzw, r2.xyzw
 209  0x00001614: add r4.xyzw, r4.xyzw, r5.xyzw
 210  0x00001630: add r1.xyzw, r1.xyzw, r4.xyzw
 211  0x0000164C: mul r4.xyzw, v3.xyxy, v4.xxxx
 212  0x00001668: add r4.xyzw, r1.xyzw, r4.xyzw
 213  0x00001684: mad r1.xyzw, r2.xyzw, cb0[0].xyzw, r1.xyzw
 214  0x000016AC: add r1.xyzw, r1.xyzw, r4.xyzw
 215  0x000016C8: max r1.xyzw, r1.xyzw, l(0x00000000, 0x00000000, 0x00000000, 0x00000000)
 216  0x000016F0: min r1.xyzw, r1.xyzw, l(0x3f800000, 0x3f800000, 0x3f800000, 0x3f800000)
 217  0x00001718: div r4.xyzw, l(0x3f800000, 0x3f800000, 0x3f800000, 0x3f800000), r2.xyzw
 218  0x00001740: add r1.xyzw, r1.xyzw, r4.xyzw
 219  0x0000175C: mov r4.xyzw, -r2.xyzw
 220  0x00001774: max r4.xyzw, r2.xyzw, r4.xyzw
 221  0x00001790: sqrt r4.xyzw, r4.xyzw
 222  0x000017A4: add r1.xyzw, r1.xyzw, r4.xyzw
 223  0x000017C0: ftoi r3.w, v1.z
 224  0x000017D4: mov r3.xy, r3.xyxx
 225  0x000017E8: mov r3.z, r3.z
 226  0x000017FC: ftou r0.y, v1.w
 227  0x00001810: iadd r0.x, r0.y, r0.x
 228  0x0000182C: mul r0.y, r2.x, l(0x358637bd)
 229  0x00001848: add r0.y, r0.y, v0.z
 230  0x00001864: max r0.y, r0.y, l(0x00000000)
 231  0x00001880: min r0.y, r0.y, l(0x3f800000)
 232  0x0000189C: mov o0.xyzw, r1.xyzw
 233  0x000018B0: mov o2.xyzw, r3.xyzw
 234  0x000018C4: mov o3.x, r0.x
 235  0x000018D8: mov oDepth, r0.y
 236  0x000018E8: ret 

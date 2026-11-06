      0x00000000: ps_5_0
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
  21  0x000003D8: sample_indexable(texture1d)(float,float,float,float) r0.xyzw, v1.xxxx, t0.xyzw, s0
  22  0x00000404: itof r1.x, l(0x00000002)
  23  0x00000418: sample_l_indexable(texture1darray)(float,float,float,float) r1.xyzw, v1.xyxx, t1.xyzw, s0, r1.x
  24  0x0000044C: add r0.xyzw, r0.xyzw, r1.xyzw
  25  0x00000468: sample_aoffimmi_indexable(1,-2,0)(texture2d)(float,float,float,float) r1.xyzw, v1.xyxx, t2.xyzw, s0
  26  0x00000498: add r0.xyzw, r0.xyzw, r1.xyzw
  27  0x000004B4: sample_b_indexable(texture2darray)(float,float,float,float) r1.xyzw, v1.xyzx, t3.xyzw, s0, cb0[0].x
  28  0x000004EC: deriv_rtx_coarse r2.xyz, v1.xyzx
  29  0x00000500: deriv_rty_coarse r3.xyz, v1.xyzx
  30  0x00000514: sample_d_indexable(texture3d)(float,float,float,float) r2.xyzw, v1.xyzx, t4.xyzw, s0, r2.xyzx, r3.xyzx
  31  0x00000550: add r1.xyzw, r1.xyzw, r2.xyzw
  32  0x0000056C: add r0.xyzw, r0.xyzw, r1.xyzw
  33  0x00000588: sample_indexable(texturecube)(float,float,float,float) r1.xyzw, v1.xyzx, t5.xyzw, s3
  34  0x000005B4: add r0.xyzw, r0.xyzw, r1.xyzw
  35  0x000005D0: sample_c_indexable(texture2d)(float,float,float,float) r1.x, v1.xyxx, t2.xxxx, s1, cb0[0].y
  36  0x00000608: sample_c_lz_aoffimmi_indexable(3,4,0)(texture2d)(float,float,float,float) r1.y, v1.zwzz, t2.xxxx, s1, cb0[0].z
  37  0x00000644: add r1.x, r1.y, r1.x
  38  0x00000660: add r0.x, r0.x, r1.x
  39  0x0000067C: mov r1.xy, v2.xyxx
  40  0x00000690: mov r1.zw, l(0x00000000,0x00000000,0x00000000,0x00000000)
  41  0x000006B0: ldms_indexable(texture2dms)(float,float,float,float) r1.xyzw, r1.xyzw, t6.xyzw, v2.z
  42  0x000006DC: mov r2.xyz, v2.xyzx
  43  0x000006F0: mov r2.w, l(0x00000000)
  44  0x00000704: ldms_indexable(texture2dmsarray)(snorm,snorm,snorm,snorm) r3.xyzw, r2.xyzw, t9.xyzw, l(0x00000001)
  45  0x00000730: add r1.xyzw, r1.xyzw, r3.xyzw
  46  0x0000074C: ld_aoffimmi_indexable(-1,1,0)(texture2d)(unorm,unorm,unorm,unorm) r3.xyzw, r2.xyww, t10.xyzw
  47  0x00000774: add r1.xyzw, r1.xyzw, r3.xyzw
  48  0x00000790: add r0.xyzw, r0.xyzw, r1.xyzw
  49  0x000007AC: ld_indexable(texture2d)(float,float,float,float) r1.xyzw, v2.xyww, t2.xyzw
  50  0x000007D0: ld_indexable(texture3d)(float,float,float,float) r3.xyzw, v2.xyzw, t4.xyzw
  51  0x000007F4: add r1.xyzw, r1.xyzw, r3.xyzw
  52  0x00000810: add r0.xyzw, r0.xyzw, r1.xyzw
  53  0x0000082C: resinfo_indexable(texture2d)(float,float,float,float)_uint r1.xyz, l(0x00000001), t2.xywz
  54  0x00000850: mov r1.x, r1.x
  55  0x00000864: mov r1.y, r1.y
  56  0x00000878: mov r1.z, r1.z
  57  0x0000088C: resinfo_indexable(texture2d)(unorm,unorm,unorm,unorm) r3.xy, l(0x00000000), t10.xyzw
  58  0x000008B0: mov r3.x, r3.x
  59  0x000008C4: mov r3.y, r3.y
  60  0x000008D8: utof r4.x, r1.x
  61  0x000008EC: utof r4.y, r1.y
  62  0x00000900: utof r1.xy, r1.zzzz
  63  0x00000914: mul r1.xy, r1.xyxx, r4.xyxx
  64  0x00000930: add r1.xy, r3.xyxx, r1.xyxx
  65  0x0000094C: add r0.xy, r0.xyxx, r1.xyxx
  66  0x00000968: ineg r1.x, v2.x
  67  0x0000097C: ineg r1.y, l(0x00000006)
  68  0x00000990: and r1.z, v2.x, l(0x80000000)
  69  0x000009AC: imax r1.x, r1.x, v2.x
  70  0x000009C8: imax r1.y, r1.y, l(0x00000006)
  71  0x000009E4: udiv null, r1.x, r1.x, r1.y
  72  0x00000A04: ineg r1.y, r1.x
  73  0x00000A18: ine r1.z, l(0x00000000, 0x00000000, 0x00000000, 0x00000000), r1.z
  74  0x00000A40: movc r1.x, r1.z, r1.y, r1.x
  75  0x00000A64: mov r1.xyzw, x0[r1.x + 0].xyzw
  76  0x00000A80: mov r2.x, cb0[1].y
  77  0x00000A98: mov r3.xyzw, x0[r2.x + 0].xyzw
  78  0x00000AB4: mul r1.xyzw, r1.xyzw, r3.xyzw
  79  0x00000AD0: add r0.xyzw, r0.xyzw, r1.xyzw
  80  0x00000AEC: itof r1.x, l(0x00000000)
  81  0x00000B00: sample_l_indexable(texturecubearray)(float,float,float,float) r1.xyzw, v1.xyzw, t11.xyzw, s0, r1.x
  82  0x00000B34: add r0.xyzw, r0.xyzw, r1.xyzw
  83  0x00000B50: lod r1.x, v1.xyxx, t2.x, s0
  84  0x00000B74: add r0.xyzw, r0.xyzw, r1.xxxx
  85  0x00000B90: gather4_indexable(texture2d)(float,float,float,float) r1.xyzw, v1.xyxx, t2.xyzw, s0.x
  86  0x00000BBC: gather4_aoffimmi_indexable(1,1,0)(texture2d)(float,float,float,float) r3.xyzw, v1.xyxx, t2.xyzw, s0.x
  87  0x00000BEC: add r1.xyzw, r1.xyzw, r3.xyzw
  88  0x00000C08: gather4_po_indexable(texture2d)(float,float,float,float) r3.xyzw, v1.xyxx, v2.zwzz, t2.xyzw, s0.y
  89  0x00000C3C: add r1.xyzw, r1.xyzw, r3.xyzw
  90  0x00000C58: add r0.xyzw, r0.xyzw, r1.xyzw
  91  0x00000C74: gather4_c_indexable(texture2d)(float,float,float,float) r1.xyzw, v1.xyxx, t2.xyzw, s1.x, cb0[0].w
  92  0x00000CAC: gather4_po_c_indexable(texture2d)(float,float,float,float) r3.xyzw, v1.xyxx, v2.xyxx, t2.xyzw, s1.z, cb0[0].x
  93  0x00000CEC: add r1.xyzw, r1.xyzw, r3.xyzw
  94  0x00000D08: add r0.xyzw, r0.xyzw, r1.xyzw
  95  0x00000D24: sample_cl_s_indexable(texture2d)(float,float,float,float) r1.xyzw, r2.x, v1.xyxx, t2.xyzw, s0, l(0x3fc00000)
  96  0x00000D64: check_access_fully_mapped r2.x, r2.x
  97  0x00000D78: add r0.xyzw, r0.xyzw, r1.xyzw
  98  0x00000D94: and r1.x, r2.x, l(0x3f800000)
  99  0x00000DB0: add r0.w, r0.w, r1.x
 100  0x00000DCC: deriv_rtx_fine r1.x, v1.x
 101  0x00000DE0: deriv_rty_coarse r1.y, v1.y
 102  0x00000DF4: add r1.x, r1.y, r1.x
 103  0x00000E10: add r0.x, r0.x, r1.x
 104  0x00000E2C: ld_indexable(buffer)(sint,sint,sint,sint) r1.xy, v2.xxxx, t7.xyzw
 105  0x00000E50: ld_indexable(texture2d)(uint,uint,uint,uint) r1.zw, r2.yzww, t8.zwxy
 106  0x00000E74: iadd r1.xy, r1.zwzz, r1.xyxx
 107  0x00000E90: mov r1.z, l(0x00000000)
 108  0x00000EA4: mov r2.yz, r0.yyzy
 109  0x00000EB8: mov r2.w, r0.w
 110  0x00000ECC: mov r3.xy, r1.xyxx
 111  0x00000EE0: mov r1.w, cb0[1].z
 112  0x00000EF8: mov r2.x, r0.x
 113  0x00000F0C: mov r4.x, r1.z
 114  0x00000F20: loop 
 115  0x00000F24:   ilt r4.y, r4.x, cb0[1].x
 116  0x00000F44:   breakc_z r4.y
 117  0x00000F50:   itof r4.y, r4.x
 118  0x00000F64:   lt r4.y, r4.y, r2.x
 119  0x00000F80:   if_nz r4.y
 120  0x00000F8C:     mov r4.y, r2.x
 121  0x00000FA0:     mov r2.x, r4.y
 122  0x00000FB4:     break 
 123  0x00000FB8:   endif 
 124  0x00000FBC:   mul r5.xyzw, r2.xyzw, l(0x3f000000, 0x3f000000, 0x3f000000, 0x3f000000)
 125  0x00000FE4:   add r5.xyzw, r5.xyzw, l(0x3e800000, 0x3e800000, 0x3e800000, 0x3e800000)
 126  0x0000100C:   ieq r4.y, r1.w, r4.x
 127  0x00001028:   if_nz r4.y
 128  0x00001034:     iadd r4.x, r4.x, l(0x00000001)
 129  0x00001050:     mov r2.yzw, r5.yyzw
 130  0x00001064:     mov r2.x, r5.x
 131  0x00001078:     continue 
 132  0x0000107C:   endif 
 133  0x00001080:   iadd r3.xy, r3.xyxx, r4.xxxx
 134  0x0000109C:   mov r2.yzw, r5.yyzw
 135  0x000010B0:   mov r2.x, r5.x
 136  0x000010C4:   iadd r4.x, r4.x, l(0x00000001)
 137  0x000010E0: endloop 
 138  0x000010E4: mov r0.x, cb0[1].w
 139  0x000010FC: switch r0.x
 140  0x00001108:   case l(0x00000000)
 141  0x00001114:   itof r2.x, l(0x00000001)
 142  0x00001128:   break 
 143  0x0000112C:   case l(0x00000003)
 144  0x00001138:   itof r2.y, l(0x00000002)
 145  0x0000114C:   mov r2.xyzw, r2.xyzw
 146  0x00001160:   break 
 147  0x00001164:   case l(0x00000007)
 148  0x00001170:   itof r2.z, l(0x00000003)
 149  0x00001184:   mov r2.xyzw, r2.xyzw
 150  0x00001198:   break 
 151  0x0000119C:   default 
 152  0x000011A0:   itof r2.w, l(0xfffffffc)
 153  0x000011B4:   mov r2.xyzw, r2.xyzw
 154  0x000011C8:   break 
 155  0x000011CC: endswitch 
 156  0x000011D0: itof r0.x, l(0xfffffc18)
 157  0x000011E4: lt r0.x, r2.w, r0.x
 158  0x00001200: if_nz r0.x
 159  0x0000120C:   discard_nz l(0xffffffff)
 160  0x00001218: endif 
 161  0x0000121C: xor r0.x, r2.y, cb0[2].x
 162  0x0000123C: mov r0.y, l(0x00000003)
 163  0x00001250: ishl r0.y, r0.x, r0.y
 164  0x0000126C: ushr r0.x, r0.x, cb0[2].y
 165  0x0000128C: not r0.z, cb0[2].z
 166  0x000012A4: and r0.x, r0.z, r0.x
 167  0x000012C0: or r0.x, r0.x, r0.y
 168  0x000012DC: mov r0.y, l(0x00000005)
 169  0x000012F0: udiv null, r0.y, v5.x, r0.y
 170  0x00001310: mov r0.y, x1[r0.y + 0].x
 171  0x0000132C: iadd r0.x, r0.y, r0.x
 172  0x00001348: bfrev r0.y, r0.x
 173  0x0000135C: countbits r0.z, r0.x
 174  0x00001370: iadd r0.y, r0.z, r0.y
 175  0x0000138C: firstbit_hi r0.z, r0.x
 176  0x000013A0: ieq r0.w, r0.z, l(0xffffffff)
 177  0x000013BC: ineg r0.z, r0.z
 178  0x000013D0: iadd r0.z, r0.z, l(0x0000001f)
 179  0x000013EC: movc r0.z, r0.w, l(0xffffffff), r0.z
 180  0x00001410: iadd r0.y, r0.z, r0.y
 181  0x0000142C: firstbit_lo r0.z, r0.x
 182  0x00001440: iadd r0.y, r0.z, r0.y
 183  0x0000145C: firstbit_shi r0.z, r0.x
 184  0x00001470: ieq r0.w, r0.z, l(0xffffffff)
 185  0x0000148C: ineg r0.z, r0.z
 186  0x000014A0: iadd r0.z, r0.z, l(0x0000001f)
 187  0x000014BC: movc r0.z, r0.w, l(0xffffffff), r0.z
 188  0x000014E0: iadd r0.y, r0.z, r0.y
 189  0x000014FC: iadd r0.x, r0.y, r0.x
 190  0x00001518: f32tof16 r0.y, r2.x
 191  0x0000152C: f16tof32 r0.z, r0.x
 192  0x00001540: ftou r0.z, r0.z
 193  0x00001554: iadd r0.y, r0.z, r0.y
 194  0x00001570: iadd r0.x, r0.y, r0.x
 195  0x0000158C: udiv r0.y, null, r0.x, cb0[2].w
 196  0x000015B0: mov r0.z, l(0x00000001)
 197  0x000015C4: iadd r0.z, r0.z, cb0[2].w
 198  0x000015E4: udiv null, r0.x, r0.x, r0.z
 199  0x00001604: iadd r0.x, r0.x, r0.y
 200  0x00001620: mov r0.x, r0.x
 201  0x00001634: ishr r0.y, r0.x, l(0x00000002)
 202  0x00001650: imul null, r0.y, r0.y, cb0[1].x
 203  0x00001674: imin r0.z, r0.x, cb0[1].y
 204  0x00001694: iadd r0.y, r0.z, r0.y
 205  0x000016B0: ineg r0.z, r1.w
 206  0x000016C4: imax r0.z, r0.z, r0.x
 207  0x000016E0: ineg r0.z, r0.z
 208  0x000016F4: iadd r0.y, r0.z, r0.y
 209  0x00001710: ineg r0.z, r0.x
 210  0x00001724: imax r0.z, r0.z, r0.x
 211  0x00001740: iadd r0.y, r0.z, r0.y
 212  0x0000175C: ineg r0.z, r0.x
 213  0x00001770: ineg r0.w, cb0[1].w
 214  0x00001788: xor r1.x, r0.x, cb0[1].w
 215  0x000017A8: imax r0.z, r0.x, r0.z
 216  0x000017C4: imax r0.w, r0.w, cb0[1].w
 217  0x000017E4: udiv r0.z, null, r0.z, r0.w
 218  0x00001804: ineg r0.w, r0.z
 219  0x00001818: and r1.x, r1.x, l(0x80000000)
 220  0x00001834: ine r1.x, l(0x00000000, 0x00000000, 0x00000000, 0x00000000), r1.x
 221  0x0000185C: movc r0.z, r1.x, r0.w, r0.z
 222  0x00001880: ineg r0.z, r0.z
 223  0x00001894: iadd r3.z, r0.z, r0.y
 224  0x000018B0: mov r1.xyzw, -r2.wzyx
 225  0x000018C8: movc r1.xyzw, v6.xxxx, r2.xyzw, r1.xyzw
 226  0x000018EC: and r4.xyzw, r1.xyzw, l(0x7fffffff, 0x7fffffff, 0x7fffffff, 0x7fffffff)
 227  0x00001914: ieq r4.xyzw, r4.xyzw, l(0x7f800000, 0x7f800000, 0x7f800000, 0x7f800000)
 228  0x0000193C: itof r5.xyzw, l(0x00000001, 0x00000001, 0x00000001, 0x00000001)
 229  0x0000195C: movc r1.xyzw, r4.xyzw, r5.xyzw, r1.xyzw
 230  0x00001980: sincos r4.xyzw, null, r2.xyzw
 231  0x00001998: sincos null, r5.xyzw, r2.yxwz
 232  0x000019B0: mul r4.xyzw, r4.xyzw, r5.xyzw
 233  0x000019CC: mov r5.xyzw, -r2.xyzw
 234  0x000019E4: max r5.xyzw, r2.xyzw, r5.xyzw
 235  0x00001A00: rsq r5.xyzw, r5.xyzw
 236  0x00001A14: add r4.xyzw, r4.xyzw, r5.xyzw
 237  0x00001A30: exp r5.xyzw, r2.xyzw
 238  0x00001A44: add r4.xyzw, r4.xyzw, r5.xyzw
 239  0x00001A60: mov r5.xyzw, -r2.xyzw
 240  0x00001A78: max r5.xyzw, r2.xyzw, r5.xyzw
 241  0x00001A94: log r5.xyzw, r5.xyzw
 242  0x00001AA8: add r4.xyzw, r4.xyzw, r5.xyzw
 243  0x00001AC4: frc r5.xyzw, r2.xyzw
 244  0x00001AD8: add r4.xyzw, r4.xyzw, r5.xyzw
 245  0x00001AF4: round_ne r5.xyzw, r2.xyzw
 246  0x00001B08: add r4.xyzw, r4.xyzw, r5.xyzw
 247  0x00001B24: round_ni r5.xyzw, r2.xyzw
 248  0x00001B38: add r4.xyzw, r4.xyzw, r5.xyzw
 249  0x00001B54: round_pi r5.xyzw, r2.xyzw
 250  0x00001B68: add r4.xyzw, r4.xyzw, r5.xyzw
 251  0x00001B84: round_z r5.xyzw, r2.xyzw
 252  0x00001B98: add r4.xyzw, r4.xyzw, r5.xyzw
 253  0x00001BB4: add r1.xyzw, r1.xyzw, r4.xyzw
 254  0x00001BD0: mul r4.xyzw, v3.xyxy, v4.xxxx
 255  0x00001BEC: add r4.xyzw, r1.xyzw, r4.xyzw
 256  0x00001C08: mad r1.xyzw, r2.xyzw, cb0[0].xyzw, r1.xyzw
 257  0x00001C30: add r1.xyzw, r1.xyzw, r4.xyzw
 258  0x00001C4C: max r1.xyzw, r1.xyzw, l(0x00000000, 0x00000000, 0x00000000, 0x00000000)
 259  0x00001C74: min r1.xyzw, r1.xyzw, l(0x3f800000, 0x3f800000, 0x3f800000, 0x3f800000)
 260  0x00001C9C: rcp r4.xyzw, r2.xyzw
 261  0x00001CB0: add r1.xyzw, r1.xyzw, r4.xyzw
 262  0x00001CCC: mov r4.xyzw, -r2.xyzw
 263  0x00001CE4: max r4.xyzw, r2.xyzw, r4.xyzw
 264  0x00001D00: sqrt r4.xyzw, r4.xyzw
 265  0x00001D14: add r1.xyzw, r1.xyzw, r4.xyzw
 266  0x00001D30: ftoi r3.w, v1.z
 267  0x00001D44: mov r3.xy, r3.xyxx
 268  0x00001D58: mov r3.z, r3.z
 269  0x00001D6C: ftou r0.y, v1.w
 270  0x00001D80: iadd r0.x, r0.y, r0.x
 271  0x00001D9C: mul r0.y, r2.x, l(0x358637bd)
 272  0x00001DB8: add r0.y, r0.y, v0.z
 273  0x00001DD4: max r0.y, r0.y, l(0x00000000)
 274  0x00001DF0: min r0.y, r0.y, l(0x3f800000)
 275  0x00001E0C: mov o0.xyzw, r1.xyzw
 276  0x00001E20: mov o2.xyzw, r3.xyzw
 277  0x00001E34: mov o3.x, r0.x
 278  0x00001E48: mov oDepth, r0.y
 279  0x00001E58: ret 

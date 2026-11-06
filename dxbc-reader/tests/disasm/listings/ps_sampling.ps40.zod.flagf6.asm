      0x00000000: ps_4_0
      0x00000008: dcl_constantbuffer CB0[3], immediateIndexed
      0x00000018: dcl_sampler s0, mode_default
      0x00000024: dcl_sampler s1, mode_comparison
      0x00000030: dcl_sampler s3, mode_default
      0x0000003C: dcl_resource_texture1d (float,float,float,float) t0
      0x0000004C: dcl_resource_texture1darray (float,float,float,float) t1
      0x0000005C: dcl_resource_texture2d (float,float,float,float) t2
      0x0000006C: dcl_resource_texture2darray (float,float,float,float) t3
      0x0000007C: dcl_resource_texture3d (float,float,float,float) t4
      0x0000008C: dcl_resource_texturecube (float,float,float,float) t5
      0x0000009C: dcl_resource_texture2dms(4) (float,float,float,float) t6
      0x000000AC: dcl_resource_buffer (sint,sint,sint,sint) t7
      0x000000BC: dcl_resource_texture2d (uint,uint,uint,uint) t8
      0x000000CC: dcl_resource_texture2dmsarray(2) (snorm,snorm,snorm,snorm) t9
      0x000000DC: dcl_resource_texture2d (unorm,unorm,unorm,unorm) t10
      0x000000EC: dcl_input_ps_siv linear noperspective v0.z, position
      0x000000FC: dcl_input_ps linear v1.xyzw
      0x00000108: dcl_input_ps constant v2.xyzw
      0x00000114: dcl_input_ps linear noperspective v3.xy
      0x00000120: dcl_input_ps linear centroid v4.x
      0x0000012C: dcl_input_ps_sgv constant v5.x, primitive_id
      0x0000013C: dcl_input_ps_sgv constant v6.x, is_front_face
      0x0000014C: dcl_output o0.xyzw
      0x00000158: dcl_output o2.xyzw
      0x00000164: dcl_output o3.x
      0x00000170: dcl_output oDepth
      0x00000178: dcl_temps 6
      0x00000180: dcl_indexableTemp x0[6], 4
      0x00000190: dcl_indexableTemp x1[5], 4
   0  0x000001A0: itof r0.xyzw, l(0x00000001, 0x00000000, 0x00000000, 0x00000001)
   1  0x000001C0: itof r1.xyzw, l(0x00000000, 0x00000001, 0x00000000, 0x00000001)
   2  0x000001E0: itof r2.xyzw, l(0x00000000, 0x00000000, 0x00000001, 0x00000001)
   3  0x00000200: itof r3.yw, l(0x00000000, 0x00000000, 0x00000000, 0x000186a0)
   4  0x00000220: mov r4.x, l(0x7f800000)
   5  0x00000234: mov r4.y, l(0xff800000)
   6  0x00000248: mov r4.z, l(0x00000001)
   7  0x0000025C: mov r4.w, l(0x80000001)
   8  0x00000270: mov x0[0].xyzw, r0.xyzw
   9  0x00000288: mov x0[1].xyzw, r1.xyzw
  10  0x000002A0: mov x0[2].xyzw, r2.xyzw
  11  0x000002B8: mov x0[3].xyzw, l(0x3f000000,0x3e800000,0x322bcc77,0xe0ad78ec)
  12  0x000002DC: mov r3.xz, l(0x7f7fffff,0x00000000,0x3eaaaaab,0x00000000)
  13  0x000002FC: mov x0[4].xyzw, r3.xyzw
  14  0x00000314: mov x0[5].xyzw, r4.xyzw
  15  0x0000032C: mov r0.xyz, l(0x00000001,0x00bc614e,0x00002710,0x00000000)
  16  0x0000034C: mov x1[0].x, r0.x
  17  0x00000364: mov x1[1].x, l(0xffffffff)
  18  0x0000037C: mov x1[2].x, l(0x80000000)
  19  0x00000394: mov x1[3].x, r0.y
  20  0x000003AC: mov x1[4].x, r0.z
  21  0x000003C4: sample r0.xyzw, v1.xxxx, t0.xyzw, s0
  22  0x000003E8: itof r1.x, l(0x00000002)
  23  0x000003FC: sample_l r1.xyzw, v1.xyxx, t1.xyzw, s0, r1.x
  24  0x00000428: add r0.xyzw, r0.xyzw, r1.xyzw
  25  0x00000444: sample_aoffimmi(1,-2,0) r1.xyzw, v1.xyxx, t2.xyzw, s0
  26  0x0000046C: add r0.xyzw, r0.xyzw, r1.xyzw
  27  0x00000488: sample_b r1.xyzw, v1.xyzx, t3.xyzw, s0, cb0[0].x
  28  0x000004B8: deriv_rtx r2.xyz, v1.xyzx
  29  0x000004CC: deriv_rty r3.xyz, v1.xyzx
  30  0x000004E0: sample_d r2.xyzw, v1.xyzx, t4.xyzw, s0, r2.xyzx, r3.xyzx
  31  0x00000514: add r1.xyzw, r1.xyzw, r2.xyzw
  32  0x00000530: add r0.xyzw, r0.xyzw, r1.xyzw
  33  0x0000054C: sample r1.xyzw, v1.xyzx, t5.xyzw, s3
  34  0x00000570: add r0.xyzw, r0.xyzw, r1.xyzw
  35  0x0000058C: sample_c r1.x, v1.xyxx, t2.xxxx, s1, cb0[0].y
  36  0x000005BC: sample_c_lz_aoffimmi(3,4,0) r1.y, v1.zwzz, t2.xxxx, s1, cb0[0].z
  37  0x000005F0: add r1.x, r1.y, r1.x
  38  0x0000060C: add r0.x, r0.x, r1.x
  39  0x00000628: mov r1.xy, v2.xyxx
  40  0x0000063C: mov r1.zw, l(0x00000000,0x00000000,0x00000000,0x00000000)
  41  0x0000065C: ldms r1.xyzw, r1.xyzw, t6.xyzw, l(0x00000003)
  42  0x00000680: mov r2.xyz, v2.xyzx
  43  0x00000694: mov r2.w, l(0x00000000)
  44  0x000006A8: ldms r3.xyzw, r2.xyzw, t9.xyzw, l(0x00000001)
  45  0x000006CC: add r1.xyzw, r1.xyzw, r3.xyzw
  46  0x000006E8: ld_aoffimmi(-1,1,0) r3.xyzw, r2.xyww, t10.xyzw
  47  0x00000708: add r1.xyzw, r1.xyzw, r3.xyzw
  48  0x00000724: add r0.xyzw, r0.xyzw, r1.xyzw
  49  0x00000740: ld r1.xyzw, v2.xyww, t2.xyzw
  50  0x0000075C: ld r3.xyzw, v2.xyzw, t4.xyzw
  51  0x00000778: add r1.xyzw, r1.xyzw, r3.xyzw
  52  0x00000794: add r0.xyzw, r0.xyzw, r1.xyzw
  53  0x000007B0: resinfo_uint r1.xyzw, l(0x00000001), t2.xyzw
  54  0x000007CC: mov r1.x, r1.x
  55  0x000007E0: mov r1.y, r1.y
  56  0x000007F4: mov r1.w, r1.w
  57  0x00000808: resinfo r3.xyzw, l(0x00000000), t10.xyzw
  58  0x00000824: mov r3.x, r3.x
  59  0x00000838: mov r3.y, r3.y
  60  0x0000084C: utof r4.x, r1.x
  61  0x00000860: utof r4.y, r1.y
  62  0x00000874: utof r1.xy, r1.wwww
  63  0x00000888: mul r1.xy, r1.xyxx, r4.xyxx
  64  0x000008A4: add r1.xy, r3.xyxx, r1.xyxx
  65  0x000008C0: add r0.xy, r0.xyxx, r1.xyxx
  66  0x000008DC: ineg r1.x, v2.x
  67  0x000008F0: ineg r1.y, l(0x00000006)
  68  0x00000904: and r1.z, v2.x, l(0x80000000)
  69  0x00000920: imax r1.x, r1.x, v2.x
  70  0x0000093C: imax r1.y, r1.y, l(0x00000006)
  71  0x00000958: udiv null, r1.x, r1.x, r1.y
  72  0x00000978: ineg r1.y, r1.x
  73  0x0000098C: ine r1.z, l(0x00000000, 0x00000000, 0x00000000, 0x00000000), r1.z
  74  0x000009B4: movc r1.x, r1.z, r1.y, r1.x
  75  0x000009D8: mov r1.xyzw, x0[r1.x + 0].xyzw
  76  0x000009F4: mov r2.x, cb0[1].y
  77  0x00000A0C: mov r3.xyzw, x0[r2.x + 0].xyzw
  78  0x00000A28: mul r1.xyzw, r1.xyzw, r3.xyzw
  79  0x00000A44: add r0.xyzw, r0.xyzw, r1.xyzw
  80  0x00000A60: ld r1.xyzw, v2.xxxx, t7.xyzw
  81  0x00000A7C: ld r2.xyzw, r2.yzww, t8.xyzw
  82  0x00000A98: iadd r1.xy, r1.xyxx, r2.xyxx
  83  0x00000AB4: mov r1.z, l(0x00000000)
  84  0x00000AC8: mov r2.yzw, r0.yyzw
  85  0x00000ADC: mov r3.xy, r1.xyxx
  86  0x00000AF0: mov r1.w, cb0[1].z
  87  0x00000B08: mov r2.x, r0.x
  88  0x00000B1C: mov r4.x, r1.z
  89  0x00000B30: loop 
  90  0x00000B34:   ilt r4.y, r4.x, cb0[1].x
  91  0x00000B54:   breakc_z r4.y
  92  0x00000B60:   itof r4.y, r4.x
  93  0x00000B74:   lt r4.y, r4.y, r2.x
  94  0x00000B90:   if_nz r4.y
  95  0x00000B9C:     mov r4.y, r2.x
  96  0x00000BB0:     mov r2.x, r4.y
  97  0x00000BC4:     break 
  98  0x00000BC8:   endif 
  99  0x00000BCC:   mul r5.xyzw, r2.xyzw, l(0x3f000000, 0x3f000000, 0x3f000000, 0x3f000000)
 100  0x00000BF4:   add r5.xyzw, r5.xyzw, l(0x3e800000, 0x3e800000, 0x3e800000, 0x3e800000)
 101  0x00000C1C:   ieq r4.y, r1.w, r4.x
 102  0x00000C38:   if_nz r4.y
 103  0x00000C44:     iadd r4.x, r4.x, l(0x00000001)
 104  0x00000C60:     mov r2.yzw, r5.yyzw
 105  0x00000C74:     mov r2.x, r5.x
 106  0x00000C88:     continue 
 107  0x00000C8C:   endif 
 108  0x00000C90:   iadd r3.xy, r3.xyxx, r4.xxxx
 109  0x00000CAC:   mov r2.yzw, r5.yyzw
 110  0x00000CC0:   mov r2.x, r5.x
 111  0x00000CD4:   iadd r4.x, r4.x, l(0x00000001)
 112  0x00000CF0: endloop 
 113  0x00000CF4: mov r0.x, cb0[1].w
 114  0x00000D0C: switch r0.x
 115  0x00000D18:   case l(0x00000000)
 116  0x00000D24:   itof r2.x, l(0x00000001)
 117  0x00000D38:   break 
 118  0x00000D3C:   case l(0x00000003)
 119  0x00000D48:   itof r2.y, l(0x00000002)
 120  0x00000D5C:   mov r2.xyzw, r2.xyzw
 121  0x00000D70:   break 
 122  0x00000D74:   case l(0x00000007)
 123  0x00000D80:   itof r2.z, l(0x00000003)
 124  0x00000D94:   mov r2.xyzw, r2.xyzw
 125  0x00000DA8:   break 
 126  0x00000DAC:   default 
 127  0x00000DB0:   itof r2.w, l(0xfffffffc)
 128  0x00000DC4:   mov r2.xyzw, r2.xyzw
 129  0x00000DD8:   break 
 130  0x00000DDC: endswitch 
 131  0x00000DE0: itof r0.x, l(0xfffffc18)
 132  0x00000DF4: lt r0.x, r2.w, r0.x
 133  0x00000E10: if_nz r0.x
 134  0x00000E1C:   discard_nz l(0xffffffff)
 135  0x00000E28: endif 
 136  0x00000E2C: xor r0.x, r2.y, cb0[2].x
 137  0x00000E4C: mov r0.y, l(0x00000003)
 138  0x00000E60: ishl r0.y, r0.x, r0.y
 139  0x00000E7C: ushr r0.x, r0.x, cb0[2].y
 140  0x00000E9C: not r0.z, cb0[2].z
 141  0x00000EB4: and r0.x, r0.z, r0.x
 142  0x00000ED0: or r0.x, r0.x, r0.y
 143  0x00000EEC: mov r0.y, l(0x00000005)
 144  0x00000F00: udiv null, r0.y, v5.x, r0.y
 145  0x00000F20: mov r0.y, x1[r0.y + 0].x
 146  0x00000F3C: iadd r0.x, r0.y, r0.x
 147  0x00000F58: udiv r0.y, null, r0.x, cb0[2].w
 148  0x00000F7C: mov r0.z, l(0x00000001)
 149  0x00000F90: iadd r0.z, r0.z, cb0[2].w
 150  0x00000FB0: udiv null, r0.x, r0.x, r0.z
 151  0x00000FD0: iadd r0.x, r0.x, r0.y
 152  0x00000FEC: mov r0.x, r0.x
 153  0x00001000: ishr r0.y, r0.x, l(0x00000002)
 154  0x0000101C: imul null, r0.y, r0.y, cb0[1].x
 155  0x00001040: imin r0.z, r0.x, cb0[1].y
 156  0x00001060: iadd r0.y, r0.z, r0.y
 157  0x0000107C: ineg r0.z, r1.w
 158  0x00001090: imax r0.z, r0.z, r0.x
 159  0x000010AC: ineg r0.z, r0.z
 160  0x000010C0: iadd r0.y, r0.z, r0.y
 161  0x000010DC: ineg r0.z, r0.x
 162  0x000010F0: imax r0.z, r0.z, r0.x
 163  0x0000110C: iadd r0.y, r0.z, r0.y
 164  0x00001128: ineg r0.z, r0.x
 165  0x0000113C: ineg r0.w, cb0[1].w
 166  0x00001154: xor r1.x, r0.x, cb0[1].w
 167  0x00001174: imax r0.z, r0.x, r0.z
 168  0x00001190: imax r0.w, r0.w, cb0[1].w
 169  0x000011B0: udiv r0.z, null, r0.z, r0.w
 170  0x000011D0: ineg r0.w, r0.z
 171  0x000011E4: and r1.x, r1.x, l(0x80000000)
 172  0x00001200: ine r1.x, l(0x00000000, 0x00000000, 0x00000000, 0x00000000), r1.x
 173  0x00001228: movc r0.z, r1.x, r0.w, r0.z
 174  0x0000124C: ineg r0.z, r0.z
 175  0x00001260: iadd r3.z, r0.z, r0.y
 176  0x0000127C: mov r1.xyzw, -r2.wzyx
 177  0x00001294: movc r1.xyzw, v6.xxxx, r2.xyzw, r1.xyzw
 178  0x000012B8: and r4.xyzw, r1.xyzw, l(0x7fffffff, 0x7fffffff, 0x7fffffff, 0x7fffffff)
 179  0x000012E0: ieq r4.xyzw, r4.xyzw, l(0x7f800000, 0x7f800000, 0x7f800000, 0x7f800000)
 180  0x00001308: itof r5.xyzw, l(0x00000001, 0x00000001, 0x00000001, 0x00000001)
 181  0x00001328: movc r1.xyzw, r4.xyzw, r5.xyzw, r1.xyzw
 182  0x0000134C: sincos r4.xyzw, null, r2.xyzw
 183  0x00001364: sincos null, r5.xyzw, r2.yxwz
 184  0x0000137C: mul r4.xyzw, r4.xyzw, r5.xyzw
 185  0x00001398: mov r5.xyzw, -r2.xyzw
 186  0x000013B0: max r5.xyzw, r2.xyzw, r5.xyzw
 187  0x000013CC: rsq r5.xyzw, r5.xyzw
 188  0x000013E0: add r4.xyzw, r4.xyzw, r5.xyzw
 189  0x000013FC: exp r5.xyzw, r2.xyzw
 190  0x00001410: add r4.xyzw, r4.xyzw, r5.xyzw
 191  0x0000142C: mov r5.xyzw, -r2.xyzw
 192  0x00001444: max r5.xyzw, r2.xyzw, r5.xyzw
 193  0x00001460: log r5.xyzw, r5.xyzw
 194  0x00001474: add r4.xyzw, r4.xyzw, r5.xyzw
 195  0x00001490: frc r5.xyzw, r2.xyzw
 196  0x000014A4: add r4.xyzw, r4.xyzw, r5.xyzw
 197  0x000014C0: round_ne r5.xyzw, r2.xyzw
 198  0x000014D4: add r4.xyzw, r4.xyzw, r5.xyzw
 199  0x000014F0: round_ni r5.xyzw, r2.xyzw
 200  0x00001504: add r4.xyzw, r4.xyzw, r5.xyzw
 201  0x00001520: round_pi r5.xyzw, r2.xyzw
 202  0x00001534: add r4.xyzw, r4.xyzw, r5.xyzw
 203  0x00001550: round_z r5.xyzw, r2.xyzw
 204  0x00001564: add r4.xyzw, r4.xyzw, r5.xyzw
 205  0x00001580: add r1.xyzw, r1.xyzw, r4.xyzw
 206  0x0000159C: mul r4.xyzw, v3.xyxy, v4.xxxx
 207  0x000015B8: add r4.xyzw, r1.xyzw, r4.xyzw
 208  0x000015D4: mad r1.xyzw, r2.xyzw, cb0[0].xyzw, r1.xyzw
 209  0x000015FC: add r1.xyzw, r1.xyzw, r4.xyzw
 210  0x00001618: max r1.xyzw, r1.xyzw, l(0x00000000, 0x00000000, 0x00000000, 0x00000000)
 211  0x00001640: min r1.xyzw, r1.xyzw, l(0x3f800000, 0x3f800000, 0x3f800000, 0x3f800000)
 212  0x00001668: div r4.xyzw, l(0x3f800000, 0x3f800000, 0x3f800000, 0x3f800000), r2.xyzw
 213  0x00001690: add r1.xyzw, r1.xyzw, r4.xyzw
 214  0x000016AC: mov r4.xyzw, -r2.xyzw
 215  0x000016C4: max r4.xyzw, r2.xyzw, r4.xyzw
 216  0x000016E0: sqrt r4.xyzw, r4.xyzw
 217  0x000016F4: add r1.xyzw, r1.xyzw, r4.xyzw
 218  0x00001710: ftoi r3.w, v1.z
 219  0x00001724: mov r3.xy, r3.xyxx
 220  0x00001738: mov r3.z, r3.z
 221  0x0000174C: ftou r0.y, v1.w
 222  0x00001760: iadd r0.x, r0.y, r0.x
 223  0x0000177C: mul r0.y, r2.x, l(0x358637bd)
 224  0x00001798: add r0.y, r0.y, v0.z
 225  0x000017B4: max r0.y, r0.y, l(0x00000000)
 226  0x000017D0: min r0.y, r0.y, l(0x3f800000)
 227  0x000017EC: mov o0.xyzw, r1.xyzw
 228  0x00001800: mov o2.xyzw, r3.xyzw
 229  0x00001814: mov o3.x, r0.x
 230  0x00001828: mov oDepth, r0.y
 231  0x00001838: ret 

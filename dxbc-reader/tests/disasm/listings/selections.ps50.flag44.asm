      ps_5_0
      dcl_globalFlags refactoringAllowed
      dcl_immediateConstantBuffer { { 1.000000, 0, 0, 1.000000},
                              { 0, 1.000000, 0, 1.000000},
                              { 0, 0, 1.000000, 1.000000},
                              { 0.500000, 0.250000, 0.000000, -100000002004087734272.000000},
                              { 340282346638528859811704183484516925440.000000, 0, 0.333333, 100000.000000},
                              { 0x7f800000, 0xff800000, 0, 0},
                              { 1, 0, 0, 0},
                              { -1, 0, 0, 0},
                              { -0.000000, 0, 0, 0},
                              { 0.000000, 0, 0, 0},
                              { 10000, 0, 0, 0} }
      dcl_constantbuffer CB0[3], immediateIndexed
      dcl_sampler s0.z, mode_default
      dcl_sampler s1, mode_comparison
      dcl_sampler s3, mode_default
      dcl_resource_texture1d (float,float,float,float) t0.wyxx
      dcl_resource_texture1darray (float,float,float,float) t1
      dcl_resource_texture2d (float,float,float,float) t2
      dcl_resource_texture2darray (float,float,float,float) t3
      dcl_resource_texture3d (float,float,float,float) t4
      dcl_resource_texturecube (float,float,float,float) t5
      dcl_resource_texture2dms(4) (float,float,float,float) t6
      dcl_resource_buffer (sint,sint,sint,sint) t7
      dcl_resource_texture2d (uint,uint,uint,uint) t8
      dcl_resource_texture2dmsarray(0) (snorm,snorm,snorm,snorm) t9
      dcl_resource_texture2d (unorm,unorm,unorm,unorm) t10
      dcl_resource_texturecubearray (float,float,float,float) t11
      dcl_input_ps_siv linear noperspective v0.z, position
      dcl_input_ps linear v1.xyzw
      dcl_input_ps constant v2.xyzw
      dcl_input_ps linear noperspective v3.xy
      dcl_input_ps linear centroid v4.x
      dcl_input_ps_sgv constant v5.x, primitive_id
      dcl_input_ps_sgv constant v6.x, is_front_face
      dcl_output o0.xyzw
      dcl_output o2.xyzw
      dcl_output o3.x
      dcl_output oDepth
      dcl_temps 6
   0: sample_indexable(texture1d)(float,float,float,float) r0.xyzw, v1.xxxx, t0.xyzw, s0
   1: sample_l_indexable(texture1darray)(float,float,float,float) r1.xyzw, v1.xyxx, t1.xyzw, s0, l(2.000000)
   2: add r0.xyzw, r0.xyzw, r1.xyzw
   3: sample_aoffimmi_indexable(1,-2,0)(texture2d)(float,float,float,float) r1.xyzw, v1.xyxx, t2.xyzw, s0
   4: add r0.xyzw, r0.xyzw, r1.xyzw
   5: sample_b_indexable(texture2darray)(float,float,float,float) r1.xyzw, v1.xyzx, t3.xyzw, s0, cb0[0].x
   6: deriv_rtx_coarse r2.xyz, v1.xyzx
   7: deriv_rty_coarse r3.xyz, v1.xyzx
   8: sample_d_indexable(texture3d)(float,float,float,float) r2.xyzw, v1.xyzx, t4.xyzw, s0, r2.xyzx, r3.xyzx
   9: add r1.xyzw, r1.xyzw, r2.xyzw
  10: add r0.xyzw, r0.xyzw, r1.xyzw
  11: sample_indexable(texturecube)(float,float,float,float) r1.xyzw, v1.xyzx, t5.xyzw, s3
  12: add r0.xyzw, r0.xyzw, r1.xyzw
  13: sample_c_indexable(texture2d)(float,float,float,float) r1.x, v1.xyxx, t2.xxxx, s1, cb0[0].y
  14: sample_c_lz_aoffimmi_indexable(3,4,0)(texture2d)(float,float,float,float) r1.y, v1.zwzz, t2.xxxx, s1, cb0[0].z
  15: add r1.x, r1.y, r1.x
  16: add r0.x, r0.x, r1.x
  17: mov r1.xy, v2.xyxx
  18: mov r1.zw, l(0,0,0,0)
  19: ldms_indexable(texture2dms)(float,float,float,float) r1.xyzw, r1.xyzw, t6.xyzw, v2.z
  20: mov r2.xyz, v2.xyzx
  21: mov r2.w, l(0)
  22: ldms_indexable(texture2dmsarray)(snorm,snorm,snorm,snorm) r4.xyzw, r2.xyzw, t9.xyzw, l(1)
  23: add r1.xyzw, r1.xyzw, r4.xyzw
  24: ld_aoffimmi_indexable(-1,1,0)(texture2d)(unorm,unorm,unorm,unorm) r4.xyzw, r2.xyww, t10.xyzw
  25: add r1.xyzw, r1.xyzw, r4.xyzw
  26: add r0.xyzw, r0.xyzw, r1.xyzw
  27: ld_indexable(texture2d)(float,float,float,float) r1.xyzw, v2.xyww, t2.xyzw
  28: ld_indexable(texture3d)(float,float,float,float) r4.xyzw, v2.xyzw, t4.xyzw
  29: add r1.xyzw, r1.xyzw, r4.xyzw
  30: add r0.xyzw, r0.xyzw, r1.xyzw
  31: resinfo_indexable(texture2d)(float,float,float,float)_uint r1.xyz, l(1), t2.xywz
  32: resinfo_indexable(texture2d)(unorm,unorm,unorm,unorm) r3.xz, l(0), t10.xzyw
  33: utof r1.xyz, r1.xyzx
  34: mad r1.xy, r1.xyxx, r1.zzzz, r3.xzxx
  35: add r0.xy, r0.xyxx, r1.xyxx
  36: and r1.x, v2.x, l(0x80000000)
  37: imax r1.y, v2.x, -v2.x
  38: udiv null, r1.y, r1.y, l(6)
  39: ineg r1.z, r1.y
  40: movc r1.x, r1.x, r1.z, r1.y
  41: mov r1.y, cb0[1].y
  42: mad r0.xyzw, icb[r1.x + 0].xyzw, icb[r1.y + 0].xyzw, r0.xyzw
  43: sample_l_indexable(texturecubearray)(float,float,float,float) r1.xyzw, v1.xyzw, t11.xyzw, s0, l(0.000000)
  44: add r0.xyzw, r0.xyzw, r1.xyzw
  45: lod r1.x, v1.xyxx, t2.x, s0
  46: add r0.xyzw, r0.xyzw, r1.xxxx
  47: gather4_indexable(texture2d)(float,float,float,float) r1.xyzw, v1.xyxx, t2.xyzw, s0.x
  48: gather4_aoffimmi_indexable(1,1,0)(texture2d)(float,float,float,float) r4.xyzw, v1.xyxx, t2.xyzw, s0.x
  49: add r1.xyzw, r1.xyzw, r4.xyzw
  50: gather4_po_indexable(texture2d)(float,float,float,float) r4.xyzw, v1.xyxx, v2.zwzz, t2.xyzw, s0.y
  51: add r1.xyzw, r1.xyzw, r4.xyzw
  52: add r0.xyzw, r0.xyzw, r1.xyzw
  53: gather4_c_indexable(texture2d)(float,float,float,float) r1.xyzw, v1.xyxx, t2.xyzw, s1.x, cb0[0].w
  54: gather4_po_c_indexable(texture2d)(float,float,float,float) r4.xyzw, v1.xyxx, v2.xyxx, t2.xyzw, s1.z, cb0[0].x
  55: add r1.xyzw, r1.xyzw, r4.xyzw
  56: add r0.xyzw, r0.xyzw, r1.xyzw
  57: sample_cl_s_indexable(texture2d)(float,float,float,float) r1.xyzw, r2.x, v1.xyxx, t2.xyzw, s0, l(1.500000)
  58: check_access_fully_mapped r2.x, r2.x
  59: add r0.xyzw, r0.xyzw, r1.xyzw
  60: movc r1.x, r2.x, l(1.000000), l(0)
  61: add r0.w, r0.w, r1.x
  62: deriv_rtx_fine r1.x, v1.x
  63: add r1.x, r3.y, r1.x
  64: add r0.x, r0.x, r1.x
  65: ld_indexable(buffer)(sint,sint,sint,sint) r1.xy, v2.xxxx, t7.xyzw
  66: ld_indexable(texture2d)(uint,uint,uint,uint) r1.zw, r2.yzww, t8.zwxy
  67: iadd r1.xy, r1.zwzz, r1.xyxx
  68: mov r1.zw, r1.xxxy
  69: mov r3.x, cb0[1].z
  70: mov r2.xyzw, r0.xyzw
  71: mov r3.y, l(0)
  72: loop 
  73:   ige r3.z, r3.y, cb0[1].x
  74:   breakc_nz r3.z
  75:   itof r3.z, r3.y
  76:   lt r3.z, r3.z, r2.x
  77:   if_nz r3.z
  78:     break 
  79:   endif 
  80:   mad r4.xyzw, r2.xyzw, l(0.500000, 0.500000, 0.500000, 0.500000), l(0.250000, 0.250000, 0.250000, 0.250000)
  81:   ieq r3.z, r3.x, r3.y
  82:   if_nz r3.z
  83:     iadd r3.z, r3.y, l(1)
  84:     mov r2.xyzw, r4.xyzw
  85:     mov r3.y, r3.z
  86:     continue 
  87:   endif 
  88:   iadd r1.zw, r1.zzzw, r3.yyyy
  89:   mov r2.xyzw, r4.xyzw
  90:   iadd r3.y, r3.y, l(1)
  91: endloop 
  92: mov o2.xy, r1.zwzz
  93: switch cb0[1].w
  94:   case l(0)
  95:   mov r2.x, l(1.000000)
  96:   break 
  97:   case l(3)
  98:   mov r2.y, l(2.000000)
  99:   break 
 100:   case l(7)
 101:   mov r2.z, l(3.000000)
 102:   break 
 103:   default 
 104:   mov r2.w, l(-4.000000)
 105:   break 
 106: endswitch 
 107: lt r0.x, r2.w, l(-1000.000000)
 108: discard_nz r0.x
 109: xor r0.x, r2.y, cb0[2].x
 110: ishl r0.y, r0.x, l(3)
 111: ushr r0.x, r0.x, cb0[2].y
 112: not r0.z, cb0[2].z
 113: and r0.x, r0.z, r0.x
 114: or r0.x, r0.x, r0.y
 115: udiv null, r0.y, v5.x, l(5)
 116: iadd r0.x, r0.x, icb[r0.y + 6].x
 117: bfrev r0.y, r0.x
 118: countbits r0.z, r0.x
 119: iadd r0.y, r0.z, r0.y
 120: firstbit_hi r0.z, r0.x
 121: iadd r0.z, -r0.z, l(31)
 122: movc r0.z, r0.x, r0.z, l(-1)
 123: iadd r0.y, r0.z, r0.y
 124: firstbit_lo r0.z, r0.x
 125: iadd r0.y, r0.z, r0.y
 126: firstbit_shi r0.z, r0.x
 127: ieq r0.w, r0.z, l(-1)
 128: iadd r0.z, -r0.z, l(31)
 129: movc r0.z, r0.w, l(-1), r0.z
 130: iadd r0.y, r0.z, r0.y
 131: iadd r0.x, r0.y, r0.x
 132: f32tof16 r0.y, r2.x
 133: f16tof32 r0.z, r0.x
 134: ftou r0.z, r0.z
 135: iadd r0.y, r0.z, r0.y
 136: iadd r0.x, r0.y, r0.x
 137: udiv r0.y, null, r0.x, cb0[2].w
 138: iadd r0.z, cb0[2].w, l(1)
 139: udiv null, r0.x, r0.x, r0.z
 140: iadd r0.x, r0.x, r0.y
 141: ishr r0.y, r0.x, l(2)
 142: imin r0.z, r0.x, cb0[1].y
 143: imad r0.y, r0.y, cb0[1].x, r0.z
 144: imax r0.z, r0.x, -cb0[1].z
 145: iadd r0.y, -r0.z, r0.y
 146: imax r0.z, -r0.x, r0.x
 147: iadd r0.y, r0.z, r0.y
 148: xor r0.w, r0.x, cb0[1].w
 149: imax r1.x, cb0[1].w, -cb0[1].w
 150: udiv r0.z, null, r0.z, r1.x
 151: ineg r1.x, r0.z
 152: and r0.w, r0.w, l(0x80000000)
 153: movc r0.z, r0.w, r1.x, r0.z
 154: iadd o2.z, -r0.z, r0.y
 155: movc r1.xyzw, v6.xxxx, r2.xyzw, -r2.wzyx
 156: and r3.xyzw, r1.xyzw, l(0x7fffffff, 0x7fffffff, 0x7fffffff, 0x7fffffff)
 157: ieq r3.xyzw, r3.xyzw, l(0x7f800000, 0x7f800000, 0x7f800000, 0x7f800000)
 158: movc r1.xyzw, r3.xyzw, l(1.000000,1.000000,1.000000,1.000000), r1.xyzw
 159: sincos r3.xyzw, null, r2.xyzw
 160: sincos null, r4.xyzw, r2.yxwz
 161: rsq r5.xyzw, |r2.xyzw|
 162: mad r3.xyzw, r3.xyzw, r4.xyzw, r5.xyzw
 163: exp r4.xyzw, r2.xyzw
 164: add r3.xyzw, r3.xyzw, r4.xyzw
 165: log r4.xyzw, |r2.xyzw|
 166: add r3.xyzw, r3.xyzw, r4.xyzw
 167: frc r4.xyzw, r2.xyzw
 168: add r3.xyzw, r3.xyzw, r4.xyzw
 169: round_ne r4.xyzw, r2.xyzw
 170: add r3.xyzw, r3.xyzw, r4.xyzw
 171: round_ni r4.xyzw, r2.xyzw
 172: add r3.xyzw, r3.xyzw, r4.xyzw
 173: round_pi r4.xyzw, r2.xyzw
 174: add r3.xyzw, r3.xyzw, r4.xyzw
 175: round_z r4.xyzw, r2.xyzw
 176: add r3.xyzw, r3.xyzw, r4.xyzw
 177: add r1.xyzw, r1.xyzw, r3.xyzw
 178: mad r3.xyzw, v3.xyxy, v4.xxxx, r1.xyzw
 179: mad r1.xyzw, r2.xyzw, cb0[0].xyzw, r1.xyzw
 180: add_sat r1.xyzw, r1.xyzw, r3.xyzw
 181: rcp r3.xyzw, r2.xyzw
 182: add r1.xyzw, r1.xyzw, r3.xyzw
 183: sqrt r3.xyzw, |r2.xyzw|
 184: add o0.xyzw, r1.xyzw, r3.xyzw
 185: ftoi o2.w, v1.z
 186: ftou r0.y, v1.w
 187: iadd o3.x, r0.y, r0.x
 188: mad_sat oDepth, r2.x, l(0.000001), v0.z
 189: ret 

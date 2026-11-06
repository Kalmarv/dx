    vs_2_0
          def c72, 3, 0, 1, 2
          def c73, 0.159154937, 0.5, 6.28318548, -3.14159274
          def c74, 1.44269502, 1, 0, 0.693147182
          def c75, 0.00999999978, 0.25, 0, 0
          def c76, -1.55009923e-006, -2.17013894e-005, 0.00260416674, 0.00026041668
          def c77, -0.020833334, -0.125, 1, 0.5
          dcl_position v0
          dcl_normal v1
          dcl_texcoord v2
          dcl_blendweight v3
          dcl_blendindices v4
   0:     mul r0.xy, v4, c72.x
   1:     mova a0.xy, r0.yxzw
   2:     mul r0, v0.y, c1[a0.x]
   3:     mad r0, v0.x, c0[a0.x], r0
   4:     mad r0, v0.z, c2[a0.x], r0
   5:     mad r0, v0.w, c72.yyyz, r0
   6:     mul r0, r0, v3.y
   7:     mul r1, v0.y, c1[a0.y]
   8:     mad r1, v0.x, c0[a0.y], r1
   9:     mad r1, v0.z, c2[a0.y], r1
  10:     mad r1, v0.w, c72.yyyz, r1
  11:     mad r0, r1, v3.x, r0
  12:     dp4 oPos.x, r0, c59
  13:     dp4 oPos.y, r0, c60
  14:     dp4 oPos.z, r0, c61
  15:     dp4 oPos.w, r0, c62
  16:     dp3 r1.x, v1, c67
  17:     dp3 r1.y, v1, c68
  18:     dp3 r1.z, v1, c69
  19:     nrm r2.xyz, r1
  22:     dp3 r1.x, r2, -c48
  23:     max r1.x, r1.x, c72.y
  24:     min r1.x, r1.x, c72.z
  25:     mul r1.x, r1.x, r1.x
  26:     mul r1.x, r1.x, r1.x
  27:     mul r1.x, r1.x, r1.x
  28:     mul r1, r1.x, c49
  29:     dp3 r2.w, r2, -c50
  30:     max r2.w, r2.w, c72.y
  31:     min r2.w, r2.w, c72.z
  32:     mul r2.w, r2.w, r2.w
  33:     mul r2.w, r2.w, r2.w
  34:     mul r2.w, r2.w, r2.w
  35:     mul r3, r2.w, c51
  36:     mov r4.y, c72.y
  37:     slt r2.w, r4.y, c70.x
  38:     slt r4.x, r2.w, c70.x
  39:     mul r3, r3, r4.x
  40:     mad r1, r2.w, r1, r3
  41:     lrp r3.x, r4.x, c72.w, r2.w
  42:     slt r2.w, r3.x, c70.x
  43:     mul r2.w, r2.w, r4.x
  44:     dp3 r3.x, r2, -c52
  45:     max r3.x, r3.x, c72.y
  46:     min r3.x, r3.x, c72.z
  47:     mul r3.x, r3.x, r3.x
  48:     mul r3.x, r3.x, r3.x
  49:     mul r3.x, r3.x, r3.x
  50:     mul r3, r3.x, c53
  51:     mad r1, r2.w, r3, r1
  52:     mad r3, r1.xyzx, c74.yyyz, c74.zzzw
  53:     mul r1.xyz, r0.y, c64
  54:     mad r1.xyz, r0.x, c63, r1
  55:     mad r0.xyz, r0.z, c65, r1
  56:     mad r0.xyz, r0.w, c66, r0
  57:     abs r1.xy, r0.yzzw
  58:     add r1.xy, r1, c72.z
  59:     log r0.w, r1.x
  60:     rsq r4.w, r1.y
  61:     mul r1.w, r0.w, r1.w
  62:     mul r0.w, r0.x, c74.x
  63:     exp r1.z, r0.w
  64:     mov r5.xy, c73
  65:     mad r0.w, c90.x, r5.x, r5.y
  66:     frc r0.w, r0.w
  67:     mad r0.w, r0.w, c73.z, c73.w
  68:     sincos r5.xy, r0.w, c76, c77
  76:     mov r1.xy, r5.yxzw
  77:     lrp r6.y, r0.x, r5.x, r5.y
  78:     mul oD0, r1, r3
  79:     dp3 r0.w, r0, r0
  80:     rsq r0.w, r0.w
  81:     rcp r0.w, r0.w
  82:     mul r0.w, r0.w, c71.x
  83:     mul oFog, r0.w, c75.x
  84:     slt r0.w, -r0.z, r0.z
  85:     slt r1.x, r0.z, -r0.z
  86:     add r6.x, r0.w, -r1.x
  87:     frc r0.w, c90.x
  88:     mad r1.xy, v2, r0.w, r6
  89:     mul r1.zw, r1.xyxy, c57.xyxy
  90:     mul r1.xy, r1, c58
  91:     add oT0.xy, r1.wyzw, r1.zxzw
  92:     mul r1.xyz, r2.yzxw, r0.zxyw
  93:     mad r4.xyz, r0.yzxw, r2.zxyw, -r1
  94:     dp3 r0.x, c55, r0
  95:     mul r0, r0.x, c56
  96:     mad r0, r4, c54, r0
  97:     mov oT1.xyz, r2
  98:     min r1, r0.wzyx, c72.z
  99:     max r1, r0, r1
 100:     sge r2, r0, c73.y
 101:     slt r0, c73.y, r0
 102:     mad r0, r1, r2, r0
 103:     rcp r1.x, r0.x
 104:     add r1.x, -r0.y, r1.x
 105:     slt r1.y, c75.y, r0.x
 106:     mad oT2.y, r1.y, r1.x, r0.y
 107:     mov oT2.xzw, r0

// approximately 108 instruction slots used

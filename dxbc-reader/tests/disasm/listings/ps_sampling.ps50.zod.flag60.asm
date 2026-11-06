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
//
// Initial variable locations:
//   v0.x <- p.pos.x; v0.y <- p.pos.y; v0.z <- p.pos.z; v0.w <- p.pos.w; 
//   v1.x <- p.uv.x; v1.y <- p.uv.y; v1.z <- p.uv.z; v1.w <- p.uv.w; 
//   v2.x <- p.i.x; v2.y <- p.i.y; v2.z <- p.i.z; v2.w <- p.i.w; 
//   v3.x <- p.np.x; v3.y <- p.np.y; 
//   v4.x <- p.c; 
//   v5.x <- p.prim; 
//   v6.x <- p.front; 
//   oDepth <- <main return value>.d; 
//   o3.x <- <main return value>.c; 
//   o2.x <- <main return value>.b.x; o2.y <- <main return value>.b.y; o2.z <- <main return value>.b.z; o2.w <- <main return value>.b.w; 
//   o0.x <- <main return value>.a.x; o0.y <- <main return value>.a.y; o0.z <- <main return value>.a.z; o0.w <- <main return value>.a.w
//
#line 44 "C:\dx-fixtures\ps_sampling.hlsl"
0x000001B4: itof r0.xyzw, l(1, 0, 0, 1)
0x000001D4: itof r1.xyzw, l(0, 1, 0, 1)
0x000001F4: itof r2.xyzw, l(0, 0, 1, 1)
0x00000214: itof r3.yw, l(0, 0, 0, 0x000186a0)
0x00000234: mov r4.x, l(0x7f800000)
0x00000248: mov r4.y, l(0xff800000)
0x0000025C: mov r4.z, l(1)
0x00000270: mov r4.w, l(0x80000001)
0x00000284: mov x0[0].xyzw, r0.xyzw
0x0000029C: mov x0[1].xyzw, r1.xyzw
0x000002B4: mov x0[2].xyzw, r2.xyzw
0x000002CC: mov x0[3].xyzw, l(0.500000,0.250000,0.000000,-100000002004087734272.000000)
0x000002F0: mov r3.xz, l(340282346638528859811704183484516925440.000000,0,0.333333,0)
0x00000310: mov x0[4].xyzw, r3.xyzw
0x00000328: mov x0[5].xyzw, r4.xyzw

#line 45
0x00000340: mov r0.xyz, l(1,0.000000,10000,0)
0x00000360: mov x1[0].x, r0.x
0x00000378: mov x1[1].x, l(-1)
0x00000390: mov x1[2].x, l(-0.000000)
0x000003A8: mov x1[3].x, r0.y
0x000003C0: mov x1[4].x, r0.z

#line 52
0x000003D8: sample_indexable(texture1d)(float,float,float,float) r0.xyzw, v1.xxxx, t0.xyzw, s0
0x00000404: itof r1.x, l(2)
0x00000418: sample_l_indexable(texture1darray)(float,float,float,float) r1.xyzw, v1.xyxx, t1.xyzw, s0, r1.x
0x0000044C: add r0.xyzw, r0.xyzw, r1.xyzw
0x00000468: sample_aoffimmi_indexable(1,-2,0)(texture2d)(float,float,float,float) r1.xyzw, v1.xyxx, t2.xyzw, s0
0x00000498: add r0.xyzw, r0.xyzw, r1.xyzw  // r0.x <- c.x; r0.y <- c.y; r0.z <- c.z; r0.w <- c.w

#line 53
0x000004B4: sample_b_indexable(texture2darray)(float,float,float,float) r1.xyzw, v1.xyzx, t3.xyzw, s0, cb0[0].x
0x000004EC: deriv_rtx_coarse r2.xyz, v1.xyzx
0x00000500: deriv_rty_coarse r3.xyz, v1.xyzx
0x00000514: sample_d_indexable(texture3d)(float,float,float,float) r2.xyzw, v1.xyzx, t4.xyzw, s0, r2.xyzx, r3.xyzx
0x00000550: add r1.xyzw, r1.xyzw, r2.xyzw
0x0000056C: add r0.xyzw, r0.xyzw, r1.xyzw

#line 54
0x00000588: sample_indexable(texturecube)(float,float,float,float) r1.xyzw, v1.xyzx, t5.xyzw, s3
0x000005B4: add r0.xyzw, r0.xyzw, r1.xyzw

#line 55
0x000005D0: sample_c_indexable(texture2d)(float,float,float,float) r1.x, v1.xyxx, t2.xxxx, s1, cb0[0].y
0x00000608: sample_c_lz_aoffimmi_indexable(3,4,0)(texture2d)(float,float,float,float) r1.y, v1.zwzz, t2.xxxx, s1, cb0[0].z
0x00000644: add r1.x, r1.y, r1.x
0x00000660: add r0.x, r0.x, r1.x

#line 56
0x0000067C: mov r1.xy, v2.xyxx
0x00000690: mov r1.zw, l(0,0,0,0)
0x000006B0: ldms_indexable(texture2dms)(float,float,float,float) r1.xyzw, r1.xyzw, t6.xyzw, v2.z
0x000006DC: mov r2.xyz, v2.xyzx
0x000006F0: mov r2.w, l(0)
0x00000704: ldms_indexable(texture2dmsarray)(snorm,snorm,snorm,snorm) r3.xyzw, r2.xyzw, t9.xyzw, l(1)
0x00000730: add r1.xyzw, r1.xyzw, r3.xyzw
0x0000074C: ld_aoffimmi_indexable(-1,1,0)(texture2d)(unorm,unorm,unorm,unorm) r3.xyzw, r2.xyww, t10.xyzw
0x00000774: add r1.xyzw, r1.xyzw, r3.xyzw
0x00000790: add r0.xyzw, r0.xyzw, r1.xyzw

#line 57
0x000007AC: ld_indexable(texture2d)(float,float,float,float) r1.xyzw, v2.xyww, t2.xyzw
0x000007D0: ld_indexable(texture3d)(float,float,float,float) r3.xyzw, v2.xyzw, t4.xyzw
0x000007F4: add r1.xyzw, r1.xyzw, r3.xyzw
0x00000810: add r0.xyzw, r0.xyzw, r1.xyzw

#line 59
0x0000082C: resinfo_indexable(texture2d)(float,float,float,float)_uint r1.xyz, l(1), t2.xywz
0x00000850: mov r1.x, r1.x  // r1.x <- w
0x00000864: mov r1.y, r1.y  // r1.y <- h
0x00000878: mov r1.z, r1.z  // r1.z <- levels

#line 61
0x0000088C: resinfo_indexable(texture2d)(unorm,unorm,unorm,unorm) r3.xy, l(0), t10.xyzw
0x000008B0: mov r3.x, r3.x  // r3.x <- fw
0x000008C4: mov r3.y, r3.y  // r3.y <- fh

#line 62
0x000008D8: utof r4.x, r1.x
0x000008EC: utof r4.y, r1.y
0x00000900: utof r1.xy, r1.zzzz
0x00000914: mul r1.xy, r1.xyxx, r4.xyxx
0x00000930: add r1.xy, r3.xyxx, r1.xyxx
0x0000094C: add r0.xy, r0.xyxx, r1.xyxx

#line 63
0x00000968: ineg r1.x, v2.x
0x0000097C: ineg r1.y, l(6)
0x00000990: and r1.z, v2.x, l(0x80000000)
0x000009AC: imax r1.x, r1.x, v2.x
0x000009C8: imax r1.y, r1.y, l(6)
0x000009E4: udiv null, r1.x, r1.x, r1.y
0x00000A04: ineg r1.y, r1.x
0x00000A18: ine r1.z, l(0, 0, 0, 0), r1.z
0x00000A40: movc r1.x, r1.z, r1.y, r1.x
0x00000A64: mov r1.xyzw, x0[r1.x + 0].xyzw
0x00000A80: mov r2.x, cb0[1].y
0x00000A98: mov r3.xyzw, x0[r2.x + 0].xyzw
0x00000AB4: mul r1.xyzw, r1.xyzw, r3.xyzw
0x00000AD0: add r0.xyzw, r0.xyzw, r1.xyzw

#line 65
0x00000AEC: itof r1.x, l(0)
0x00000B00: sample_l_indexable(texturecubearray)(float,float,float,float) r1.xyzw, v1.xyzw, t11.xyzw, s0, r1.x
0x00000B34: add r0.xyzw, r0.xyzw, r1.xyzw

#line 66
0x00000B50: lod r1.x, v1.xyxx, t2.x, s0
0x00000B74: add r0.xyzw, r0.xyzw, r1.xxxx

#line 69
0x00000B90: gather4_indexable(texture2d)(float,float,float,float) r1.xyzw, v1.xyxx, t2.xyzw, s0.x
0x00000BBC: gather4_aoffimmi_indexable(1,1,0)(texture2d)(float,float,float,float) r3.xyzw, v1.xyxx, t2.xyzw, s0.x
0x00000BEC: add r1.xyzw, r1.xyzw, r3.xyzw
0x00000C08: gather4_po_indexable(texture2d)(float,float,float,float) r3.xyzw, v1.xyxx, v2.zwzz, t2.xyzw, s0.y
0x00000C3C: add r1.xyzw, r1.xyzw, r3.xyzw
0x00000C58: add r0.xyzw, r0.xyzw, r1.xyzw

#line 70
0x00000C74: gather4_c_indexable(texture2d)(float,float,float,float) r1.xyzw, v1.xyxx, t2.xyzw, s1.x, cb0[0].w
0x00000CAC: gather4_po_c_indexable(texture2d)(float,float,float,float) r3.xyzw, v1.xyxx, v2.xyxx, t2.xyzw, s1.z, cb0[0].x
0x00000CEC: add r1.xyzw, r1.xyzw, r3.xyzw
0x00000D08: add r0.xyzw, r0.xyzw, r1.xyzw

#line 72
0x00000D24: sample_cl_s_indexable(texture2d)(float,float,float,float) r1.xyzw, r2.x, v1.xyxx, t2.xyzw, s0, l(1.500000)
0x00000D64: check_access_fully_mapped r2.x, r2.x  // r2.x <- status
0x00000D78: add r0.xyzw, r0.xyzw, r1.xyzw

#line 73
0x00000D94: and r1.x, r2.x, l(0x3f800000)
0x00000DB0: add r0.w, r0.w, r1.x

#line 74
0x00000DCC: deriv_rtx_fine r1.x, v1.x
0x00000DE0: deriv_rty_coarse r1.y, v1.y
0x00000DF4: add r1.x, r1.y, r1.x
0x00000E10: add r0.x, r0.x, r1.x

#line 76
0x00000E2C: ld_indexable(buffer)(sint,sint,sint,sint) r1.xy, v2.xxxx, t7.xyzw
0x00000E50: ld_indexable(texture2d)(uint,uint,uint,uint) r1.zw, r2.yzww, t8.zwxy
0x00000E74: iadd r1.xy, r1.zwzz, r1.xyxx  // r1.x <- b.x; r1.y <- b.y

#line 77
0x00000E90: mov r1.z, l(0)  // r1.z <- i
0x00000EA4: mov r2.yz, r0.yyzy  // r2.y <- c.y; r2.z <- c.z
0x00000EB8: mov r2.w, r0.w  // r2.w <- c.w
0x00000ECC: mov r3.xy, r1.xyxx  // r3.x <- b.x; r3.y <- b.y
0x00000EE0: mov r1.w, cb0[1].z  // r1.w <- n.z
0x00000EF8: mov r2.x, r0.x  // r2.x <- c.x
0x00000F0C: mov r4.x, r1.z  // r4.x <- i
0x00000F20: loop 
0x00000F24:   ilt r4.y, r4.x, cb0[1].x
0x00000F44:   breakc_z r4.y

#line 78
0x00000F50:   itof r4.y, r4.x
0x00000F64:   lt r4.y, r4.y, r2.x
0x00000F80:   if_nz r4.y
0x00000F8C:     mov r4.y, r2.x  // r4.y <- c.x
0x00000FA0:     mov r2.x, r4.y  // r2.x <- c.x
0x00000FB4:     break 
0x00000FB8:   endif 

#line 79
0x00000FBC:   mul r5.xyzw, r2.xyzw, l(0.500000, 0.500000, 0.500000, 0.500000)
0x00000FE4:   add r5.xyzw, r5.xyzw, l(0.250000, 0.250000, 0.250000, 0.250000)  // r5.x <- c.x; r5.y <- c.y; r5.z <- c.z; r5.w <- c.w

#line 80
0x0000100C:   ieq r4.y, r1.w, r4.x
0x00001028:   if_nz r4.y
0x00001034:     iadd r4.x, r4.x, l(1)
0x00001050:     mov r2.yzw, r5.yyzw  // r2.y <- c.y; r2.z <- c.z; r2.w <- c.w
0x00001064:     mov r2.x, r5.x  // r2.x <- c.x
0x00001078:     continue 
0x0000107C:   endif   // r5.x <- c.x; r5.y <- c.y; r5.z <- c.z; r5.w <- c.w

#line 81
0x00001080:   iadd r3.xy, r3.xyxx, r4.xxxx
0x0000109C:   mov r2.yzw, r5.yyzw  // r2.y <- c.y; r2.z <- c.z; r2.w <- c.w
0x000010B0:   mov r2.x, r5.x  // r2.x <- c.x

#line 77
0x000010C4:   iadd r4.x, r4.x, l(1)

#line 82
0x000010E0: endloop 

#line 83
0x000010E4: mov r0.x, cb0[1].w
0x000010FC: switch r0.x

#line 84
0x00001108:   case l(0)
0x00001114:   itof r2.x, l(1)
0x00001128:   break 

#line 85
0x0000112C:   case l(3)
0x00001138:   itof r2.y, l(2)
0x0000114C:   mov r2.xyzw, r2.xyzw
0x00001160:   break 

#line 86
0x00001164:   case l(7)
0x00001170:   itof r2.z, l(3)
0x00001184:   mov r2.xyzw, r2.xyzw
0x00001198:   break 

#line 87
0x0000119C:   default 
0x000011A0:   itof r2.w, l(-4)
0x000011B4:   mov r2.xyzw, r2.xyzw
0x000011C8:   break 

#line 88
0x000011CC: endswitch 

#line 89
0x000011D0: itof r0.x, l(-1000)
0x000011E4: lt r0.x, r2.w, r0.x
0x00001200: if_nz r0.x
0x0000120C:   discard_nz l(-1)
0x00001218: endif 

#line 90
0x0000121C: xor r0.x, r2.y, cb0[2].x  // r0.x <- x

#line 91
0x0000123C: mov r0.y, l(3)
0x00001250: ishl r0.y, r0.x, r0.y
0x0000126C: ushr r0.x, r0.x, cb0[2].y
0x0000128C: not r0.z, cb0[2].z
0x000012A4: and r0.x, r0.z, r0.x
0x000012C0: or r0.x, r0.x, r0.y  // r0.x <- x

#line 92
0x000012DC: mov r0.y, l(5)
0x000012F0: udiv null, r0.y, v5.x, r0.y
0x00001310: mov r0.y, x1[r0.y + 0].x
0x0000132C: iadd r0.x, r0.y, r0.x

#line 94
0x00001348: bfrev r0.y, r0.x
0x0000135C: countbits r0.z, r0.x
0x00001370: iadd r0.y, r0.z, r0.y
0x0000138C: firstbit_hi r0.z, r0.x
0x000013A0: ieq r0.w, r0.z, l(-1)
0x000013BC: ineg r0.z, r0.z
0x000013D0: iadd r0.z, r0.z, l(31)
0x000013EC: movc r0.z, r0.w, l(-1), r0.z
0x00001410: iadd r0.y, r0.z, r0.y
0x0000142C: firstbit_lo r0.z, r0.x
0x00001440: iadd r0.y, r0.z, r0.y
0x0000145C: firstbit_shi r0.z, r0.x
0x00001470: ieq r0.w, r0.z, l(-1)
0x0000148C: ineg r0.z, r0.z
0x000014A0: iadd r0.z, r0.z, l(31)
0x000014BC: movc r0.z, r0.w, l(-1), r0.z
0x000014E0: iadd r0.y, r0.z, r0.y
0x000014FC: iadd r0.x, r0.y, r0.x

#line 95
0x00001518: f32tof16 r0.y, r2.x
0x0000152C: f16tof32 r0.z, r0.x
0x00001540: ftou r0.z, r0.z
0x00001554: iadd r0.y, r0.z, r0.y
0x00001570: iadd r0.x, r0.y, r0.x

#line 97
0x0000158C: udiv r0.y, null, r0.x, cb0[2].w
0x000015B0: mov r0.z, l(1)
0x000015C4: iadd r0.z, r0.z, cb0[2].w
0x000015E4: udiv null, r0.x, r0.x, r0.z
0x00001604: iadd r0.x, r0.x, r0.y  // r0.x <- x

#line 98
0x00001620: mov r0.x, r0.x  // r0.x <- sx

#line 99
0x00001634: ishr r0.y, r0.x, l(2)
0x00001650: imul null, r0.y, r0.y, cb0[1].x
0x00001674: imin r0.z, r0.x, cb0[1].y
0x00001694: iadd r0.y, r0.z, r0.y
0x000016B0: ineg r0.z, r1.w
0x000016C4: imax r0.z, r0.z, r0.x
0x000016E0: ineg r0.z, r0.z
0x000016F4: iadd r0.y, r0.z, r0.y
0x00001710: ineg r0.z, r0.x
0x00001724: imax r0.z, r0.z, r0.x
0x00001740: iadd r0.y, r0.z, r0.y
0x0000175C: ineg r0.z, r0.x
0x00001770: ineg r0.w, cb0[1].w
0x00001788: xor r1.x, r0.x, cb0[1].w
0x000017A8: imax r0.z, r0.x, r0.z
0x000017C4: imax r0.w, r0.w, cb0[1].w
0x000017E4: udiv r0.z, null, r0.z, r0.w
0x00001804: ineg r0.w, r0.z
0x00001818: and r1.x, r1.x, l(0x80000000)
0x00001834: ine r1.x, l(0, 0, 0, 0), r1.x
0x0000185C: movc r0.z, r1.x, r0.w, r0.z
0x00001880: ineg r0.z, r0.z
0x00001894: iadd r3.z, r0.z, r0.y  // r3.z <- sx

#line 100
0x000018B0: mov r1.xyzw, -r2.wzyx
0x000018C8: movc r1.xyzw, v6.xxxx, r2.xyzw, r1.xyzw  // r1.x <- o.a.x; r1.y <- o.a.y; r1.z <- o.a.z; r1.w <- o.a.w

#line 101
0x000018EC: and r4.xyzw, r1.xyzw, l(0x7fffffff, 0x7fffffff, 0x7fffffff, 0x7fffffff)
0x00001914: ieq r4.xyzw, r4.xyzw, l(0x7f800000, 0x7f800000, 0x7f800000, 0x7f800000)
0x0000193C: itof r5.xyzw, l(1, 1, 1, 1)
0x0000195C: movc r1.xyzw, r4.xyzw, r5.xyzw, r1.xyzw

#line 102
0x00001980: sincos r4.xyzw, null, r2.xyzw
0x00001998: sincos null, r5.xyzw, r2.yxwz
0x000019B0: mul r4.xyzw, r4.xyzw, r5.xyzw
0x000019CC: mov r5.xyzw, -r2.xyzw
0x000019E4: max r5.xyzw, r2.xyzw, r5.xyzw
0x00001A00: rsq r5.xyzw, r5.xyzw
0x00001A14: add r4.xyzw, r4.xyzw, r5.xyzw
0x00001A30: exp r5.xyzw, r2.xyzw
0x00001A44: add r4.xyzw, r4.xyzw, r5.xyzw
0x00001A60: mov r5.xyzw, -r2.xyzw
0x00001A78: max r5.xyzw, r2.xyzw, r5.xyzw
0x00001A94: log r5.xyzw, r5.xyzw
0x00001AA8: add r4.xyzw, r4.xyzw, r5.xyzw
0x00001AC4: frc r5.xyzw, r2.xyzw
0x00001AD8: add r4.xyzw, r4.xyzw, r5.xyzw
0x00001AF4: round_ne r5.xyzw, r2.xyzw
0x00001B08: add r4.xyzw, r4.xyzw, r5.xyzw
0x00001B24: round_ni r5.xyzw, r2.xyzw
0x00001B38: add r4.xyzw, r4.xyzw, r5.xyzw
0x00001B54: round_pi r5.xyzw, r2.xyzw
0x00001B68: add r4.xyzw, r4.xyzw, r5.xyzw
0x00001B84: round_z r5.xyzw, r2.xyzw
0x00001B98: add r4.xyzw, r4.xyzw, r5.xyzw
0x00001BB4: add r1.xyzw, r1.xyzw, r4.xyzw

#line 103
0x00001BD0: mul r4.xyzw, v3.xyxy, v4.xxxx
0x00001BEC: add r4.xyzw, r1.xyzw, r4.xyzw
0x00001C08: mad r1.xyzw, r2.xyzw, cb0[0].xyzw, r1.xyzw
0x00001C30: add r1.xyzw, r1.xyzw, r4.xyzw
0x00001C4C: max r1.xyzw, r1.xyzw, l(0.000000, 0.000000, 0.000000, 0.000000)
0x00001C74: min r1.xyzw, r1.xyzw, l(1.000000, 1.000000, 1.000000, 1.000000)
0x00001C9C: rcp r4.xyzw, r2.xyzw
0x00001CB0: add r1.xyzw, r1.xyzw, r4.xyzw
0x00001CCC: mov r4.xyzw, -r2.xyzw
0x00001CE4: max r4.xyzw, r2.xyzw, r4.xyzw
0x00001D00: sqrt r4.xyzw, r4.xyzw
0x00001D14: add r1.xyzw, r1.xyzw, r4.xyzw  // r1.x <- o.a.x; r1.y <- o.a.y; r1.z <- o.a.z; r1.w <- o.a.w

#line 104
0x00001D30: ftoi r3.w, v1.z  // r3.w <- o.b.w
0x00001D44: mov r3.xy, r3.xyxx  // r3.x <- o.b.x; r3.y <- o.b.y
0x00001D58: mov r3.z, r3.z  // r3.z <- o.b.z

#line 105
0x00001D6C: ftou r0.y, v1.w
0x00001D80: iadd r0.x, r0.y, r0.x  // r0.x <- o.c

#line 106
0x00001D9C: mul r0.y, r2.x, l(0.000001)
0x00001DB8: add r0.y, r0.y, v0.z
0x00001DD4: max r0.y, r0.y, l(0.000000)
0x00001DF0: min r0.y, r0.y, l(1.000000)  // r0.y <- o.d

#line 107
0x00001E0C: mov o0.xyzw, r1.xyzw
0x00001E20: mov o2.xyzw, r3.xyzw
0x00001E34: mov o3.x, r0.x
0x00001E48: mov oDepth, r0.y
0x00001E58: ret 

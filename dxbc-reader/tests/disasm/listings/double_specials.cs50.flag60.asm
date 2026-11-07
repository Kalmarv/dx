0x00000000: cs_5_0
0x00000008: dcl_globalFlags refactoringAllowed | enableDoublePrecisionFloatOps
0x0000000C: dcl_uav_raw u0
0x00000018: dcl_input vThreadID.xyz
0x00000020: dcl_temps 2
0x00000028: dcl_thread_group 1, 1, 1
0x00000038: mov r0.xy, vThreadID.xyxx
0x00000048: dmul r1.xyzw, r0.xyxy, d(-1.#INF00l, 1.#INF00l)
0x00000070: store_raw u0.xyzw, l(0), r1.xyzw
0x0000008C: dmovc r1.xyzw, vThreadID.zzzz, r0.xyxy, d(1.#SNAN0l, -1.#SNAN0l)
0x000000B8: store_raw u0.xyzw, l(16), r1.xyzw
0x000000D4: dmovc r1.xyzw, vThreadID.zzzz, r0.xyxy, d(-1.#IND00l, 1.#QNAN0l)
0x00000100: dmovc r0.xy, vThreadID.zzzz, r0.xyxy, d(-1.#QNAN0l, 0.000000l)
0x0000012C: store_raw u0.xyzw, l(32), r1.xyzw
0x00000148: store_raw u0.xy, l(48), r0.xyxx
0x00000164: ret 

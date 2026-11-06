    ps_2_x
    defi i0, 4, 0, 0, 0
    mov r1, c1
    rep i0
      setp_ge p0, c0, r1
      break_sat_pp_centroid p0
    endrep
    mov oC0, c0

// approximately 11 instruction slots used

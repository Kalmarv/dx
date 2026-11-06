    ps_1_1
    nop
    mov r0, r1
    add r0, r1, r2
    sub r0, r1, r2
    mad r0, r1, r2, r3
    mul r0, r1, r2
    rcp r0, r1
    rsq r0, r1
    dp3 r0, r1, r2
    dp4 r0, r1, r2
    min r0, r1, r2
    max r0, r1, r2
    slt r0, r1, r2
    sge r0, r1, r2
    exp r0, r1
    log r0, r1
    lit r0, r1
    dst r0, r1, r2
    lrp r0, r1, r2, r3
    frc r0, r1
    m4x4 r0, r1, r2
    m4x3 r0, r1, r2
    m3x4 r0, r1, r2
    m3x3 r0, r1, r2
    m3x2 r0, r1, r2
    call r1
    callnz r1, r2
    loop r1, r2
      ret
    endloop
    label r1
    dcl_texcoord v0
    pow r0, r1, r2
    crs r0, r1, r2
    sgn r0, r1, r2, r3
    abs r0, r1
    nrm r0, r1
    sincos r0, r1, r2, r3
    rep r1
    endrep
    if r1
      if_gt r1, r2
      else
      endif
      break
      break_gt r1, r2
      mova r0, r1
      defb b0, true
      defi i0, 1, 2, 3, 4
      texcoord r0
      texkill r0
      tex r0
      texbem r0, r1
      texbeml r0, r1
      texreg2ar r0, r1
      texreg2gb r0, r1
      texm3x2pad r0, r1
      texm3x2tex r0, r1
      texm3x3pad r0, r1
      texm3x3tex r0, r1
      texm3x3spec r0, r1, r2
      texm3x3vspec r0, r1
      expp r0, r1
      logp r0, r1
      cnd r0, r1, r2, r3
      def c0, 1, 0, 0, 1
      texreg2rgb r0, r1
      texdp3tex r0, r1
      texm3x2depth r0, r1
      texdp3 r0, r1
      texm3x3 r0, r1
      texdepth r0
      cmp r0, r1, r2, r3
      bem r0, r1, r2
      dp2add r0, r1, r2, r3
      dsx r0, r1
      dsy r0, r1
      texldd r0, r1, r2, r3, r4
      setp_gt r0, r1, r2
      texldl r0, r1, r2
      break_pp_centroid r1.z
      phase
      dcl_texcoord1 v1

// approximately 77 instruction slots used (20 texture, 57 arithmetic)

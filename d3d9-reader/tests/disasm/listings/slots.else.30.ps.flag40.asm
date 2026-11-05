    ps_3_0
    dcl_texcoord v0
    if b0
      mul oC0, c0, v0
    else
      add oC0, c1, v0
    endif

// approximately 7 instruction slots used

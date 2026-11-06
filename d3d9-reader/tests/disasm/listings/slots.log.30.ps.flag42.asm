    ps_3_0
    def c0, 0.693147182, 0, 0, 0
    dcl_texcoord v0
    log r0.x, v0.x
    log r0.y, v0.y
    log r0.z, v0.z
    log r0.w, v0.w
    mul oC0, r0, c0.x

// approximately 5 instruction slots used

    vs_1_1
    dcl_position v0
    mov oPos, v0
    rcp oT0.x, c0.x
    rsq oT0.y, c0.y
    rcp oT0.z, c0.z
    rsq oT0.w, c0.w

// approximately 5 instruction slots used

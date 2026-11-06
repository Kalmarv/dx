    vs_3_0
    def c3, 0, 1, 0, 0
    dcl_position v0  // p<0,1,2,3>
    dcl_position o0

#line 68 "C:\dx9-fixtures\debug.hlsl"
    mov r0, v0  // ::o<0,1,2,3>
    mov r1.x, c3.x  // ::i<0>
    rep i0
      mad r0, c2, r1.x, r0  // ::o<0,1,2,3>
      add r1.x, r1.x, c3.y  // ::i<0>
    endrep
    if b0
      mov o0, -r0  // ::o<0,1,2,3>
    else
      mov o0, r0  // ::o<0,1,2,3>
    endif

// approximately 16 instruction slots used

    vs_2_0
    def c6, 1, 2, 0, 0
    dcl_position v0  // p<0,1,2,3>
    dcl_texcoord v1  // t<0,1>

#line 53 "C:\dx9-fixtures\debug.hlsl"
    mul r0.x, v0.x, c4.x  // ::a<0>
    mul r0.y, v0.y, c4.y  // ::b<0>
    mov r0.x, r0.x  // ::ab<0>
    mov r0.y, r0.y  // ::ab<1>
    mul r0.zw, r0.x, c0.xyxy  // ::mm<0,2>
    mul r1.xy, r0.x, c1  // ::mm<1,3>
    add r1.z, r0.x, c6.x  // ::vals<0>
    add r1.w, r0.y, c6.y  // ::vals<1>
    mul r2, v0, c5
    add r2, r2, c3  // ::o<0,1,2,3>
    mul r0.z, r0.z, r0.x
    mul r0.w, r0.w, r0.y
    add r3.x, r0.w, r0.z
    mul r0.x, r0.x, r1.x
    mul r0.y, r0.y, r1.y
    add r3.y, r0.y, r0.x
    add r0.xy, r3, v1  // ::o<4,5>
    mul r0.z, r1.w, r1.z  // ::o<6>
    mov oPos, r2  // ::packed<0,1,2,3>
    mov oT0.xy, r0  // ::packed<4,5>
    mov oT1.x, r0.z  // ::packed<6>

// approximately 21 instruction slots used

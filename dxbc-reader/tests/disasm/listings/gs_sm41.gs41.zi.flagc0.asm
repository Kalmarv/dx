gs_4_1
dcl_globalFlags refactoringAllowed
dcl_constantbuffer CB0[24], dynamicIndexed
dcl_input v[3][0].xyzw
dcl_temps 3
dcl_inputprimitive triangle 
dcl_outputtopology trianglestrip 
dcl_output_siv o0.xyzw, position
dcl_output o1.xyzw
dcl_output_siv o2.x, rendertarget_array_index
dcl_maxout 18
//
// Initial variable locations:
//   m0 <- o; 
//   v[0][0].x <- p[0].x; v[0][0].y <- p[0].y; v[0][0].z <- p[0].z; v[0][0].w <- p[0].w; 
//   v[1][0].x <- p[1].x; v[1][0].y <- p[1].y; v[1][0].z <- p[1].z; v[1][0].w <- p[1].w; 
//   v[2][0].x <- p[2].x; v[2][0].y <- p[2].y; v[2][0].z <- p[2].z; v[2][0].w <- p[2].w
//
#line 8 "C:\dx-fixtures\gs_sm41.hlsl"
mov r0.x, l(0x00000000)  // r0.x <- f
loop 
  uge r0.y, r0.x, l(0x00000006)
  breakc_nz r0.y
  ishl r0.y, r0.x, l(0x00000002)
  utof r0.z, r0.x
  mul r0.z, r0.z, l(0x3e2aaaab)  // r0.z <- g.c.x
  mov r0.w, l(0x00000000)  // r0.w <- v
  loop 
    uge r1.x, r0.w, l(0x00000003)
    breakc_nz r1.x
    dp4 r1.x, v[r0.w + 0][0].xyzw, cb0[r0.y + 0].xyzw  // r1.x <- g.p.x
    dp4 r1.y, v[r0.w + 0][0].xyzw, cb0[r0.y + 1].xyzw  // r1.y <- g.p.y
    dp4 r1.z, v[r0.w + 0][0].xyzw, cb0[r0.y + 2].xyzw  // r1.z <- g.p.z
    dp4 r1.w, v[r0.w + 0][0].xyzw, cb0[r0.y + 3].xyzw  // r1.w <- g.p.w
    utof r2.x, r0.w
    mul r2.x, r2.x, l(0x3eaaaaab)  // r2.x <- g.c.y
    mov o0.x, r1.x
    mov o0.y, r1.y
    mov o0.z, r1.z
    mov o0.w, r1.w
    mov o1.x, r0.z
    mov o1.y, r2.x
    mov o1.zw, l(0x00000000,0x00000000,0x00000000,0x3f800000)
    mov o2.x, r0.x
    emit 
    iadd r0.w, r0.w, l(0x00000001)
  endloop 
  cut 
  iadd r0.x, r0.x, l(0x00000001)
endloop 

#line 9
ret 

    ps_2_0
          dcl t0.xy  // uv<0,1>
          dcl_2d s0

#line 21 "C:\dx9-fixtures\debug.hlsl"
   0:     texld r0, t0, s0
   0:     mul r0, r0, c0  // ::c<0,1,2,3>

#line 24
   1:     add r0, r0, c1  // ::tinted<0,1,2,3>

#line 19
   2:     mov oC0, r0  // ::tinted<0,1,2,3>

// approximately 4 instruction slots used (1 texture, 3 arithmetic)

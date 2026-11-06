    ps_3_0
          dcl_texcoord v0.xyz
          dcl_2d s0
          dcl_2d s1
          dcl_volume s2
          dcl_cube s3
   0:     texld r0, v0.x, s0
   0:     texld r1, v0, s1
   0:     add r0, r0, r1
   1:     texld r1, v0, s2
   1:     add r0, r0, r1
   2:     texld r1, v0, s3
   2:     add oC0, r0, r1

// approximately 7 instruction slots used (4 texture, 3 arithmetic)

    ps_3_0
0x00000108:     dcl_texcoord v0.xyz
0x00000114:     dcl_2d s0
0x00000120:     dcl_2d s1
0x0000012C:     dcl_volume s2
0x00000138:     dcl_cube s3
0x00000144:     texld r0, v0.x, s0
0x00000154:     texld r1, v0, s1
0x00000164:     add r0, r0, r1
0x00000174:     texld r1, v0, s2
0x00000184:     add r0, r0, r1
0x00000194:     texld r1, v0, s3
0x000001A4:     add oC0, r0, r1

// approximately 7 instruction slots used (4 texture, 3 arithmetic)

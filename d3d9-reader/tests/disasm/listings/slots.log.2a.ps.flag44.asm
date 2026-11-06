    ps_2_x
          def c0, 0.693147182, 0, 0, 0
          dcl t0
   0:     log r0.x, t0.x
   1:     log r0.y, t0.y
   2:     log r0.z, t0.z
   3:     log r0.w, t0.w
   4:     mul r0, r0, c0.x
   5:     mov oC0, r0

// approximately 6 instruction slots used

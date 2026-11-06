; vs_1_1 rcp and rsq of a replicated lane: 1/x and 1/sqrt(|x|), infinity at zero
; run: c0=4,4,0,-4 -> TEXCOORD0=0.25,0.5,inf,0.5
vs_1_1
dcl_position v0
mov oPos, v0
rcp oT0.x, c0.x
rsq oT0.y, c0.y
rcp oT0.z, c0.z
rsq oT0.w, c0.w

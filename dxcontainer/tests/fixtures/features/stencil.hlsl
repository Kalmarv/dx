// dxc: -T ps_6_0 -E main -Fo stencil.dxil
uint main() : SV_StencilRef { return 3; }

// dxc: -T ps_6_4 -E main -Fo shadingrate.dxil
float4 main(uint r : SV_ShadingRate) : SV_Target { return r; }

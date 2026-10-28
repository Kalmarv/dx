RasterizerOrderedTexture2D<float4> t : register(u0);
float4 main(float4 p : SV_Position) : SV_Target { t[uint2(p.xy)] = 1; return 0; }

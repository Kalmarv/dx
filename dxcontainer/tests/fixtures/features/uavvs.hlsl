RWBuffer<float> b : register(u0);
float4 main(uint i : SV_VertexID) : SV_Position { b[i] = 1; return 0; }

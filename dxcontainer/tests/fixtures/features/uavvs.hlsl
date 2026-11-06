// dxc: -T vs_6_0 -E main -Fo uavvs.dxil
RWBuffer<float> b : register(u0);
float4 main(uint i : SV_VertexID) : SV_Position { b[i] = 1; return 0; }

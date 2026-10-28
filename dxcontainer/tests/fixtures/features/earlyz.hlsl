RWBuffer<float> b : register(u1);
[earlydepthstencil] float4 main(float4 p : SV_Position) : SV_Target { b[0] = p.x; return 0; }

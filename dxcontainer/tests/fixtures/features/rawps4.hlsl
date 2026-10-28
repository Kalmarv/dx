ByteAddressBuffer o : register(t0);
float4 main(uint i : A) : SV_Target { return o.Load(i*4); }

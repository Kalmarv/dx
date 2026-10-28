Texture2D<float4> t : register(t0);
SamplerState s : register(s0);
struct V { float4 p : SV_Position; };
[numthreads(4,1,1)] [outputtopology("triangle")]
void main(uint i : SV_GroupIndex, out vertices V v[3], out indices uint3 tri[1]) { SetMeshOutputCounts(3,1); float4 c = t.Sample(s, float2(i,0)); v[i].p = c; tri[0]=uint3(0,1,2); }

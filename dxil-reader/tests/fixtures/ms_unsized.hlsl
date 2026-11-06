// dxc: -T ps_6_0 -E main -Fo ms_unsized.dxil
// Multisampled textures declared with a sample count of -1 keep it in their metadata, and dxc's listing writes it as
// 4294967295 (`2dMS4294967295`); one declared with no count has 0 (`2dMS`).
Texture2DMS<float4> no_count : register(t0);
Texture2DMS<float4, -1> minus_one : register(t1);
Texture2DMSArray<float4, -1> minus_one_array : register(t2);
Texture2DMS<float4, 8> eight : register(t3);

float4 main(uint2 p : P) : SV_Target
{
    return no_count.Load(p, 0) + minus_one.Load(p, 1) + minus_one_array.Load(uint3(p, 0), 2) + eight.Load(p, 3);
}

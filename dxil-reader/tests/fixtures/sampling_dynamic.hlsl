// Fixture for `sampling::texture_reads`: a texture array and a sampler array indexed by values the program computes.
// Compile: dxc -T ps_6_0 -E main -Fo sampling_dynamic.dxil sampling_dynamic.hlsl
Texture2D<float4> arr[4] : register(t8);
SamplerState linear_s : register(s1);
SamplerState pick[2] : register(s6);

float4 main(float2 uv : TEXCOORD0, uint i : INDEX, uint j : INDEX1) : SV_Target
{
    return arr[NonUniformResourceIndex(i)].Sample(pick[NonUniformResourceIndex(j & 1)], uv)
         + arr[2].Sample(linear_s, uv);
}

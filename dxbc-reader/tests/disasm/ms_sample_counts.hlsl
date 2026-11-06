// Multisampled textures with no sample count, a count of -1 and a count of 8: the reflection stores -1 as
// 0xffffffff, which Microsoft's listing writes as a signed number, `2dMS-1` (dxc's d3dreflect texture2dms test).
// fxc: /T ps_5_0 /E main /Fo ms_sample_counts.ps50.dxbc
Texture2DMS<float4> ms;
Texture2DMSArray<float4> msa;
Texture2DMS<float4, -1> ms1;
Texture2DMSArray<float4, -1> msa1;
Texture2DMS<float4, 8> ms8;
Texture2DMSArray<float4, 4> msa4;
float4 main(uint4 color : COLOR) : SV_TARGET
{
    return ms.sample[2][color.xy] + msa.sample[3][color.xyz] + ms1.sample[2][color.xy]
            + msa1.sample[3][color.xyz] + ms8.sample[2][color.xy] + msa4.sample[3][color.xyz];
}

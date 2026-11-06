// A global struct with a default value and a sampler member: Microsoft's listing writes the default's words before
// the line naming the sampler register the variable holds (vkd3d's sampler-state test).
// fxc: /T ps_5_0 /E main /Fo defaults_samplers.ps50.dxbc
struct
{
    float4 f;
    sampler sam;
    float2 g;
} apple = {
    1, 2, 3, 4,
    sampler_state
    {
        texture = NULL;
        mipfilter = LINEAR;
    },
    1, 1,
};
Texture2D tex;
float4 main() : sv_target
{
    return tex.Sample(apple.sam, apple.g) + apple.f;
}

// An input struct whose textures come before its position: the debug information gives the textures no size but an
// array of them its count, so the first location's offset falls in the array's first texture, past its size, and
// Microsoft's disassembler ends the initial locations with its internal error (vkd3d's object-parameters test).
// fxc: /T ps_5_0 /E main /Zi /Fo zi_object_input.ps50.zi.dxbc
// fxc: /T ps_5_0 /E main /Zi /Od /Fo zi_object_input.ps50.zod.dxbc
struct apple
{
    Texture2D unused;
    Texture2D tex[3];
    Texture2D lone;
    float4 pos : sv_position;
};
Texture2D tex0;
sampler sam;
float4 main(struct apple input) : sv_target
{
    return 100 * input.tex[1].Sample(sam, float2(0, 0))
            + 10 * tex0.Sample(sam, float2(0, 0))
            + input.lone.Sample(sam, float2(0, 0)) + input.pos;
}

// Shader messages (`printf`, `errorf`) and `abort`: the message text with Microsoft's escapes (`\b \t \n \r \\`
// escaped, other characters below 0x20 or above 0x7f as `.`, a quote unescaped), the operands, numbering and
// indenting inside flow control, and the debug-layer note fxc's digest for such a program brings.
// fxc: /T vs_5_0 /E main /Fo messages.vs50.dxbc
// fxc: /T cs_5_0 /E branch /Fo messages.cs50.dxbc
cbuffer C : register(b0) { float4 v; int i; double d; float f; };
RWBuffer<uint> u : register(u0);

float4 main(float4 p : POSITION) : SV_Position
{
    printf("plain");
    printf("float %f int %d", 1.5, -7);
    printf("vec %f %f", v.x, v.y);
    errorf("err %d %u", i, 70000);
    printf("quote \" lone \ tab \t nl \n pct %% back \\ two \\\\");
    printf("bs \b cr \r q \" x1 \x01 hi \xe9 oct \101 bell \a vt \v ff \f del \x7f");
    return p * (float)(d * 2.0) * f;
}

[numthreads(4, 1, 1)]
void branch(uint t : SV_DispatchThreadID)
{
    if (u[t] > 3)
    {
        printf("big %u at %u", u[t], t);
        if (u[t] > 100)
            abort();
    }
    u[t] = t;
}

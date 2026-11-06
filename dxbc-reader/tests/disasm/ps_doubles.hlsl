// Double-precision arithmetic with immediate doubles, which a listing with hex literals writes as their four words.
// fxc: /T ps_5_0 /E main /Fo ps_doubles.ps50.dxbc
cbuffer C : register(b0) { double2 d; };
float4 main() : SV_Target
{
    double a = d.x / 3.0;
    double b = d.y * 100.0 + 0.125;
    return float4((float)a, (float)b, (float)(a * -2.5), 1);
}

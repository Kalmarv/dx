// A `[call]` switch and a `[call]` if: subroutines, their `label` register and the calls to them.
// fxc: /T ps_5_0 /E main /Fo ps_calls.ps50.dxbc
float main(float2 a : A, int3 b : B) : SV_Target
{
    float r;
    [call] switch (b.x)
    {
    case 1: r = 5.f; break;
    case 2: r = a.x; break;
    default: r = 3.f; break;
    }
    [call] if (b.y > 0) { r += a.y; } else { r -= 1; }
    return r;
}

// Control flow with hints and loops (the branches that close them carry the attachments dx.controlflow.hints and llvm.loop). Compiled with dxc -T ps_6_0 -E main (hints.ps.dxil).
Texture2D<float4> t : register(t0);
float4 main(float4 p : SV_Position, uint k : K) : SV_Target {
    float4 r = 0;
    [loop] for (uint i = 0; i < k; i++) { r += t.Load(int3(i, 0, 0)); }
    [branch] if (p.x > 1) { r *= 2; }
    [flatten] if (p.y > 1) { r += 3; }
    [unroll(2)] for (uint j = 0; j < 2; j++) { r += j; }
    return r;
}

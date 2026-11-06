// A Shader Model 4.1 pixel program: a multisampled texture's sample position and load, and a cube array's gather and
// level of detail.
// fxc: /T ps_4_1 /E main /Fo ps_sm41.ps41.dxbc
Texture2DMS<float4, 4> ms : register(t0);
TextureCubeArray ca : register(t1);
SamplerState s;
float4 main(float3 d : DIR, float4 p : SV_Position, uint si : SV_SampleIndex) : SV_Target {
  float2 sp = ms.GetSamplePosition(si);
  float4 a = ms.Load(int2(p.xy), si);
  float4 g = ca.Gather(s, float4(d, 1));
  return a + g + sp.xyxy + ca.CalculateLevelOfDetail(s, d);
}

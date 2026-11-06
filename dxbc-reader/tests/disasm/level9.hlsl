// Programs for the Direct3D 9 feature levels: the container holds the Shader Model 2 program (`Aon9` part) beside
// the Shader Model 4 one, and the listing writes both.
// fxc: /T ps_4_0_level_9_1 /E ps /Fo level9.ps91.dxbc
// fxc: /T vs_4_0_level_9_3 /E vs /Fo level9.vs93.dxbc
Texture2D t : register(t0);
SamplerState s : register(s0);
cbuffer C : register(b0) { float4x4 m; float4 tint; };
float4 ps(float4 pos : SV_Position, float2 uv : TEXCOORD0) : SV_Target { return t.Sample(s, uv) * tint + uv.xyxy; }
float4 vs(float3 p : POSITION, inout float2 uv : TEXCOORD0) : SV_Position { uv *= tint.xy; return mul(float4(p, 1), m); }

// Integer and bool constants, several constant buffers and texture/sampler pairs, and a loop, for the mapping tables'
// other rows: what the constants convert to, which buffer and sampler each comes from, and the loop registers.
// fxc: /T ps_4_0_level_9_3 /E mapped /Fo level9.mapped.ps93.dxbc
// fxc: /T vs_4_0_level_9_1 /E looped /Fo level9.looped.vs91.dxbc
// fxc: /T vs_4_0_level_9_3 /E looped /Fo level9.looped.vs93.dxbc
Texture2D t1 : register(t1);
TextureCube t3 : register(t3);
SamplerState s2 : register(s2);
cbuffer D : register(b1) { int4 counts; uint4 masks; bool flags; float scale; };
cbuffer E : register(b2) { float4 extra[3]; };
float4 mapped(float2 uv : TEXCOORD0) : SV_Target {
    float4 c = t1.Sample(s2, uv) * counts.x + t3.Sample(s, uv.xyy) * masks.y;
    return flags ? c * scale + extra[2] : c - extra[0];
}
float4 looped(float4 p : POSITION) : SV_Position {
    float4 o = p;
    [loop] for (int k = 0; k < counts.x; k++) o += extra[k];
    return o * scale;
}
// two loops over constants away from register 0 and component 0, and a branch on a bool constant
// fxc: /T vs_4_0_level_9_3 /E twice /Fo level9.twice.vs93.dxbc
cbuffer F : register(b3) { float4 pad; int4 bounds; bool gate; };
float4 twice(float4 p : POSITION) : SV_Position {
    float4 o = p;
    [loop] for (int k = 0; k < bounds.z; k++) o += extra[1] * k;
    [loop] for (int j = 0; j < bounds.y; j++) o = o * o.yzwx;
    [branch] if (gate) o = -o;
    return o;
}
// one loop over a constant's w component and a branch on a bool in component y, so registers and components differ
// fxc: /T vs_4_0_level_9_3 /E lone /Fo level9.lone.vs93.dxbc
cbuffer G : register(b4) { float pad2; bool late; float pad3; int last; };
float4 lone(float4 p : POSITION) : SV_Position {
    float4 o = p;
    [loop] for (int k = 0; k < last; k++) o = o * o.yzwx;
    [branch] if (late) o = -o;
    return o;
}
// no constants and no textures: the mapping sections with nothing in them
// fxc: /T ps_4_0_level_9_1 /E bare /Fo level9.bare.ps91.dxbc
// fxc: /T ps_4_0_level_9_1 /E ps /Zi /Fo level9.ps91.zi.dxbc
// fxc: /T ps_4_0_level_9_1 /E ps /Zi /Od /Fo level9.ps91.zod.dxbc
// fxc: /T vs_4_0_level_9_3 /E vs /Zi /Fo level9.vs93.zi.dxbc
// fxc: /T vs_4_0_level_9_3 /E vs /Zi /Od /Fo level9.vs93.zod.dxbc
// fxc: /T ps_4_0_level_9_3 /E mapped /Zi /Fo level9.mapped.ps93.zi.dxbc
// fxc: /T ps_4_0_level_9_3 /E mapped /Zi /Od /Fo level9.mapped.ps93.zod.dxbc
// fxc: /T vs_4_0_level_9_1 /E looped /Zi /Fo level9.looped.vs91.zi.dxbc
// fxc: /T vs_4_0_level_9_1 /E looped /Zi /Od /Fo level9.looped.vs91.zod.dxbc
// fxc: /T vs_4_0_level_9_3 /E looped /Zi /Fo level9.looped.vs93.zi.dxbc
// fxc: /T vs_4_0_level_9_3 /E looped /Zi /Od /Fo level9.looped.vs93.zod.dxbc
// fxc: /T vs_4_0_level_9_3 /E twice /Zi /Fo level9.twice.vs93.zi.dxbc
// fxc: /T vs_4_0_level_9_3 /E twice /Zi /Od /Fo level9.twice.vs93.zod.dxbc
// fxc: /T vs_4_0_level_9_3 /E lone /Zi /Fo level9.lone.vs93.zi.dxbc
// fxc: /T vs_4_0_level_9_3 /E lone /Zi /Od /Fo level9.lone.vs93.zod.dxbc
// fxc: /T ps_4_0_level_9_1 /E bare /Zi /Fo level9.bare.ps91.zi.dxbc
// fxc: /T ps_4_0_level_9_1 /E bare /Zi /Od /Fo level9.bare.ps91.zod.dxbc
float4 bare(float4 pos : SV_Position, float4 c : COLOR0) : SV_Target { return c * c; }

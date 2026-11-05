// One operation of interest per build, for each pixel profile, so every instruction's slot cost in the listing's
// footer is checked on its own: derivatives, gradient and level sampling, lrp, log, and each kind of flow control.
// fxc: /T ps_2_a /E main /D DDX /Fo slots.ddx.2a.ps.bin
// fxc: /T ps_2_a /E main /D DDY /Fo slots.ddy.2a.ps.bin
// fxc: /T ps_2_a /E main /D LERP /Fo slots.lerp.2a.ps.bin
// fxc: /T ps_2_a /E main /D LOG /Fo slots.log.2a.ps.bin
// fxc: /T ps_3_0 /E main /D DDX /Fo slots.ddx.30.ps.bin
// fxc: /T ps_3_0 /E main /D DDY /Fo slots.ddy.30.ps.bin
// fxc: /T ps_3_0 /E main /D GRAD /Fo slots.grad.30.ps.bin
// fxc: /T ps_3_0 /E main /D LERP /Fo slots.lerp.30.ps.bin
// fxc: /T ps_3_0 /E main /D LOG /Fo slots.log.30.ps.bin
// fxc: /T ps_3_0 /E main /D LOOP /Fo slots.loop.30.ps.bin
// fxc: /T ps_3_0 /E main /D ELSE /Fo slots.else.30.ps.bin
// fxc: /T ps_3_0 /E main /D CALL /Fo slots.call.30.ps.bin
// fxc: /T ps_3_0 /E main /D PRED /Fo slots.pred.30.ps.bin
// fxc: /T ps_3_0 /E main /D LITERAL /Fo slots.literal.30.ps.bin
sampler2D s;
float4 a[8];
int n;
bool b;

float4 shade(float4 v) { return v * a[1] + a[2]; }

float4 main(float4 uv : TEXCOORD0) : COLOR0 {
#if defined(DDX)
    return ddx(uv);
#elif defined(DDY)
    return ddy(uv);
#elif defined(GRAD)
    return tex2Dgrad(s, uv.xy, uv.zw, uv.wz);
#elif defined(LERP)
    return lerp(uv, a[0], uv.w);
#elif defined(LOG)
    return log(uv);
#elif defined(LOOP)
    // a loop over an integer constant whose counter indexes constants: loop aL, endloop
    float4 c = 0;
    [loop] for (int k = 0; k < n; k++) c += a[k];
    return c;
#elif defined(ELSE)
    [branch] if (b) return a[0] * uv; else return a[1] + uv;
#elif defined(CALL)
    [call] if (uv.x > 0.5) return shade(uv);
    return uv;
#elif defined(PRED)
    float4 c = uv;
    [loop] for (int k = 0; k < n; k++) { [branch] if (c.x > a[k].x) break; c += a[k]; }
    return c;
#elif defined(LITERAL)
    // a loop of a literal count: its integer constant is a defi
    float4 c = uv;
    [loop] for (int k = 0; k < 5; k++) c = c * c.yzwx + a[0];
    return c;
#endif
}

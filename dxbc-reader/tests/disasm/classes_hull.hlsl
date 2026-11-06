// Class linkage in a hull program: the class tables come after the tessellation tables.
// fxc: /T hs_5_0 /E main /Fo classes_hull.hs50.dxbc
// fxc: /T hs_5_0 /E main /Zi /Fo classes_hull.hs50.zi.dxbc
// fxc: /T hs_5_0 /E main /Zi /Od /Fo classes_hull.hs50.zod.dxbc
interface IL { float f(float n); };
class A : IL { float k; float f(float n) { return n * k; } };
class B : IL { float f(float n) { return n; } };
IL l; A a;
struct P { float4 p : POSITION; };
struct C { float e[3] : SV_TessFactor; float i : SV_InsideTessFactor; };
C pc(InputPatch<P, 3> ip) { C c; c.e[0] = c.e[1] = c.e[2] = l.f(ip[0].p.x); c.i = 1; return c; }
[domain("tri")] [partitioning("integer")] [outputtopology("triangle_cw")] [outputcontrolpoints(3)] [patchconstantfunc("pc")]
P main(InputPatch<P, 3> ip, uint id : SV_OutputControlPointID) { return ip[id]; }

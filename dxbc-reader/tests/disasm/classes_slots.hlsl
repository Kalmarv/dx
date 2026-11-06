// N classes behind interface pointers and arrays of them: the slot table writes eight entries a row and skips the
// ninth, and moves the next record's first slot on by the record's span for each row it writes.
// fxc: /T ps_5_0 /E main /D N=8 /Fo classes_slots8.ps50.dxbc
// fxc: /T ps_5_0 /E main /D N=9 /Fo classes_slots9.ps50.dxbc
// fxc: /T ps_5_0 /E main /D N=10 /Fo classes_slots10.ps50.dxbc
// fxc: /T ps_5_0 /E main /D N=18 /Fo classes_slots18.ps50.dxbc
// fxc: /T ps_5_0 /E main /D N=30 /Fo classes_slots30.ps50.dxbc
interface IA { float3 f(float3 n); };
class C0 : IA { float3 f(float3 n) { return n * 1; } };
class C1 : IA { float3 f(float3 n) { return n * 2; } };
class C2 : IA { float3 f(float3 n) { return n * 3; } };
class C3 : IA { float3 f(float3 n) { return n * 4; } };
class C4 : IA { float3 f(float3 n) { return n * 5; } };
class C5 : IA { float3 f(float3 n) { return n * 6; } };
class C6 : IA { float3 f(float3 n) { return n * 7; } };
class C7 : IA { float3 f(float3 n) { return n * 8; } };
#if N > 8
class C8 : IA { float3 f(float3 n) { return n * 9; } };
#endif
#if N > 9
class C9 : IA { float3 f(float3 n) { return n * 10; } };
#endif
#if N > 10
class C10 : IA { float3 f(float3 n) { return n * 11; } };
#endif
#if N > 11
class C11 : IA { float3 f(float3 n) { return n * 12; } };
#endif
#if N > 12
class C12 : IA { float3 f(float3 n) { return n * 13; } };
#endif
#if N > 13
class C13 : IA { float3 f(float3 n) { return n * 14; } };
#endif
#if N > 14
class C14 : IA { float3 f(float3 n) { return n * 15; } };
#endif
#if N > 15
class C15 : IA { float3 f(float3 n) { return n * 16; } };
#endif
#if N > 16
class C16 : IA { float3 f(float3 n) { return n * 17; } };
#endif
#if N > 17
class C17 : IA { float3 f(float3 n) { return n * 18; } };
#endif
#if N > 18
class C18 : IA { float3 f(float3 n) { return n * 19; } };
#endif
#if N > 19
class C19 : IA { float3 f(float3 n) { return n * 20; } };
#endif
#if N > 20
class C20 : IA { float3 f(float3 n) { return n * 21; } };
#endif
#if N > 21
class C21 : IA { float3 f(float3 n) { return n * 22; } };
#endif
#if N > 22
class C22 : IA { float3 f(float3 n) { return n * 23; } };
#endif
#if N > 23
class C23 : IA { float3 f(float3 n) { return n * 24; } };
#endif
#if N > 24
class C24 : IA { float3 f(float3 n) { return n * 25; } };
#endif
#if N > 25
class C25 : IA { float3 f(float3 n) { return n * 26; } };
#endif
#if N > 26
class C26 : IA { float3 f(float3 n) { return n * 27; } };
#endif
#if N > 27
class C27 : IA { float3 f(float3 n) { return n * 28; } };
#endif
#if N > 28
class C28 : IA { float3 f(float3 n) { return n * 29; } };
#endif
#if N > 29
class C29 : IA { float3 f(float3 n) { return n * 30; } };
#endif
IA a[3];
IA b[2];
IA c;
IA d[2];
float4 main(float3 n : NORMAL) : SV_Target {
    return float4(a[0].f(n) + a[1].f(n) + a[2].f(n) + b[0].f(n) + b[1].f(n.yzx) + c.f(n.zxy) + d[0].f(n) + d[1].f(n), 1);
}

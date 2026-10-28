RaytracingAccelerationStructure s : register(t0);
RWStructuredBuffer<uint> o : register(u0);
[numthreads(1,1,1)] void main(uint i : SV_DispatchThreadID) { RayQuery<RAY_FLAG_NONE> q; RayDesc r; r.Origin=0;r.Direction=float3(0,0,1);r.TMin=0;r.TMax=1; q.TraceRayInline(s,0,0xff,r); while(q.Proceed()){} o[i]=q.CommittedStatus(); }

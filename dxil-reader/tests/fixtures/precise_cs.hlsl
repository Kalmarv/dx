RWStructuredBuffer<float> o : register(u0);
[numthreads(1,1,1)] void main(uint i : SV_DispatchThreadID) { precise float x = o[i] * 3.0 + o[i+1]; float y = x * x; o[i] = y + x; }

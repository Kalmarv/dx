// An amplification program (Shader Model 6.5): one group of 8 threads dispatches 3 mesh groups with a payload of one float4
// and one uint. Compiled with dxc -T as_6_5 -E main (amplify.as.dxil).
struct Payload { float4 colour; uint index; };
groupshared Payload p;
[numthreads(8, 1, 1)]
void main(uint i : SV_GroupIndex) {
    p.colour = float4(1, 0, 0, 1);
    p.index = i;
    DispatchMesh(3, 1, 1, p);
}

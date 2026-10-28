struct O { float4 p : SV_Position; uint v : SV_ViewportArrayIndex; };
O main(uint i : SV_VertexID) { O o; o.p = 0; o.v = i; return o; }

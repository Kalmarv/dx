cbuffer C : register(b0) { float4 a; float4 b; float4 c; };
float4 main(float4 p : POSITION) : SV_Position {
    precise float4 x = p * a + b;
    float4 y = x * c + p.wzyx;
    precise float z = y.x * y.y + y.z;
    return float4(x.xy, z, y.w);
}

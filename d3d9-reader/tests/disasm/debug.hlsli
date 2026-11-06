// A function in a second file, for the `#line` that names its file and the one back.
float4 twist(float4 v)
{
    return v.yzwx * v;
}

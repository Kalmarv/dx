// dxc: -T ps_6_2 -enable-16bit-types -E main -Fo lowp.dxil
float16_t4 main(float16_t4 a : A) : SV_Target { return a * a; }

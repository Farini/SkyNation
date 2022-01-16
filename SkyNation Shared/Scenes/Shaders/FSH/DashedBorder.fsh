// Test
void main( void ) {
    
    int stripe = int(u_path_length) / 100;
    int h = int(v_path_distance) / stripe % 2;
    gl_FragColor = float4(h);
    
}

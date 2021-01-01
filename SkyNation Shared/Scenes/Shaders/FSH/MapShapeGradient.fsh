
// Uniform: u_speed, how fast the wave should travel. Ranges from -2 to 2 work best, where negative numbers cause waves to come inwards; try starting with 1.

void main() {
    
    float normalisedPosition = v_path_distance / u_path_length;
    
    float c_blu = 0.2;
    
    // each dash should be 10 pixels
    int amount_dashes = int(u_path_length) / 10;
    
    int stripe = int(u_path_length) / amount_dashes;
    int h = int(v_path_distance) / stripe % 2;
    
    float c_red = normalisedPosition;
    float partial_green = 1.0 - (normalisedPosition * 2);
    float c_green = max(0.0, partial_green);
    
    if (h < 0.9){
        c_red = 0.0;
        c_green = 0.0;
        c_blu = 0.0;
    }
    
    gl_FragColor = vec4(c_red, c_green, c_blu, h);
}

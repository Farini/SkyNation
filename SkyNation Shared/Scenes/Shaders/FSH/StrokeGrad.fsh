
// uniform vec2 resolution;
// it looks like resolution = size
// so set the uniform u_size

void main( void ) {
    
    float timer = cos(u_time);
    // float tinverse = -cos(u_time);
    
    /*
     First light goes forward,
     Second light goes backward
     */
    
    /// The normalised Position
    float normPos = (v_path_distance / u_path_length) * timer;
    // float normPos = (v_path_distance * timer / (u_path_length * (1 - abs(timer))));
    // float normalisedPosition = (v_path_distance * timer / (u_path_length * (1 - abs(timer))));
    
    float secoPos = 1.0 - (v_path_distance / u_path_length);
    
//    float factory = normPos * timer;
    float firstColor = max(0.1, (normPos * timer));
    
    // float secondColor = (-1.0 * factory);
    float secondColor = max(0.1, (secoPos * (1.0 - timer)));
    
    float thirdColor = (firstColor + secondColor) / 1.5;
    
    // Colors
    float red = 0.1; //max(0.15, 0.25 * secondColor);
    float green = min(thirdColor, firstColor); //0.3; // max(0.2, 0.75 * firstColor);
    float blue = max(thirdColor, firstColor); // max(thirdColor, firstColor); //max(0.5, thirdColor);
    
    gl_FragColor = vec4(red, green, blue, 1.0);
    
    
}

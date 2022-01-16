
// Uniforms:
// u_colmin: the minimum red color
// u_theme: { red, yellow, fuchia }

// Colors
// darkred: (139,0,0)
// crimson (220,20,60)
// lightCoral (240,128,128)

void main( void ) {
    
    int size = 5;
    
    // Grid
    
    int h = int(v_tex_coord.x * 90) / size % 2;
    // int h = int(v_tex_coord.x * u_texture_size.x) / size % 2;
    int v = int(v_tex_coord.y * 25) / size % 2;
    // int v = int(v_tex_coord.y * u_texture_size.y) / size % 2;
    
    float whiteness = v ^ h;
    // normalise color
    whiteness = max(0.0, whiteness);
    whiteness = min(1.0, whiteness);
    
    float red = min(whiteness, u_colmin);
    float blue = min(whiteness, 0.3);
    float green = min(whiteness, 0.15);
    
    if (whiteness > 0.1) {
        // Bright Squares
        // reduce to a quarter brightness
        whiteness = 0.25;
    } else {
        // Dark Squares
        whiteness = 0.0;
    }
    
    if (u_theme < 0.33) {
        // Color 1: Red
        red = max(whiteness, u_colmin);
        green = whiteness;
        blue = whiteness;
    } else if (u_theme < 0.66) {
        // Color 2: Yellow/Orange
        red = max(whiteness, u_colmin);
        green = max(whiteness, u_colmin);
        blue = whiteness;
    } else {
        // Color 3: Fuchia
        green = max(whiteness, u_colmin);
        blue = max(whiteness, u_colmin);
        red = whiteness;
    }
    
    gl_FragColor = float4(red, green, blue, 1.0);
    
}

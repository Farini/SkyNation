//  HealthShader: SkyNationPrologue
//  Created by Carlos Farini on 11/2/18.
//  Copyright © 2018 Carlos Farini. All rights reserved.

// Uniforms to pass
// u_health:    The health (from 0 to 1) of the player
// u_gradient:  The gradient overlay

// u_texture:   (Passed by default)

void main() {
    
    // Load the pixel from our original texture, and the same place in the gradient circle
    vec4 val = texture2D(u_texture, v_tex_coord);
    vec4 grad = texture2D(u_gradient, v_tex_coord);
    
    // [1 - ORIGINAL CHECK] If the original is transparent AND
    // [2 - HEALTH CHECK] The gradient image has a black value less than the remaining health AND
    // [3 - MASKING] The gradient pixel is not transparent
    
    if (val.a < 0.1 && grad.r < u_health && grad.a > 0.9) {
        gl_FragColor = vec4(0.0,1.0,0.0,1.0);
    } else {
        gl_FragColor = val;
    }
}

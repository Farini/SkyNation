// Shader Designed by Carlos Farini
// 2018 All rights reserved.


// 1 on edges, 0 in middle
float hex(vec2 p) {
    p.x *= 0.57735*2.0;
    p.y += mod(floor(p.x), 2.0)*0.5;
    p = abs((mod(p, 1.0) - 0.5));
    return abs(max(p.x*1.5 + p.y, p.y*2.0) - 1.0);
}

void main() {
    vec2 pos = gl_FragCoord.xy;
    
    vec2 p = pos/40.0;
    
    float r = (1.0 -0.7) * 0.5;
    
    vec3 color = smoothstep(0.0, r + 0.05, hex(p));
    
    vec4 current_color = SKDefaultShading();
    
    if (color.r < 0.4){
        gl_FragColor = smoothstep(0.0, r + 0.05, hex(p));
    }else{
        gl_FragColor = current_color;
    }
}

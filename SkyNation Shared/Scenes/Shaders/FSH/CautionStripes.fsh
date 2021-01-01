// uniform vec2 resolution;
// it looks like resolution = size
// so set the uniform u_size

void main( void ) {
    
    vec2 position = gl_FragCoord.xy;
    float x = (position.x + 20.0) - position.y;
    float domain = fract(x * 0.01);
    
    float smooth = 0.015;
    
    vec4 c3 = vec4(1,0.6,0,1);
    vec4 c4 = vec4(0,0,0,1);
    
    gl_FragColor = mix(c3, c4, smoothstep(0.5 - smooth, 0.5, domain) - smoothstep(1.0 - smooth, 1.0, domain));
}

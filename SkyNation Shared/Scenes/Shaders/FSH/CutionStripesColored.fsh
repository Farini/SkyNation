// Uniforms names
// u_stripe_color: vector_float4([Float(r), Float(g), Float(b), Float(a)])
// u_empty_color: vector_float4([Float(r), Float(g), Float(b), Float(a)])
// Uniforms allow you to personalize the colors of the stripe

void main( void ) {
    
    vec2 position = gl_FragCoord.xy;
    float x = (position.x + 20.0) - position.y;
    float domain = fract(x * 0.01);
    
    float smooth = 0.015;
    
    vec4 cStripe = u_stripe_color;
    vec4 cEmpty = u_empty_color;
    
    gl_FragColor = mix(cStripe, cEmpty, smoothstep(0.5 - smooth, 0.5, domain) - smoothstep(1.0 - smooth, 1.0, domain));
}

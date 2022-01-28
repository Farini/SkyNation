// Shader

float linearstep(float a, float b, float x) {
    return clamp((b - x) / (b - a), 0.0, 1.0);
}

//x - circle alpha
//y - circle color
//Thanks to FabriceNeyret2 for this idea
vec2 circle(vec2 uv, float pixelSize, float sinDna, float cosDna, float msign) {
    
    float height = msign * sinDna;
    float depth = abs((msign * 0.5 + 0.5) - (cosDna * 0.25 + 0.5));    //this 0.25 is quite bad here
    float size = 0.2 + depth * 0.1;
    float alpha = 1.0 - smoothstep(size - pixelSize, size + pixelSize, distance(uv, vec2(0.5, height)));
    
    return vec2(alpha, depth * 0.8 + (1.0 - 0.8));
}



void main() {
    
    // const float COLOR_DIFFERENCE = 0.8
    
    vec2 uv = (gl_FragCoord.xy * 2.0 - u_resolution.xy) / u_resolution.y; //(gl_FragCoord * 2.0 - u_resolution.xy) / u_resolution.y;
    
    //scale
    uv = uv * 5.0;
    // store the value in uv
    vec2 preuv = uv;
    
    //rotation for angle=0.3
    //optimized version of uv *= mat2(cos(angle), sin(angle), -sin(angle), cos(angle)); by FabriceNeyret2
    float angle = 0.0; //0.15;
    mat2 rotmat = mat2(cos(angle), sin(angle), -sin(angle), cos(angle)); //mat2(cos(angle + vec4(0, 11, 33, 0)));
    
    uv = uv * rotmat;
    
    // move over time
    uv.x = uv.x - u_time * 0.5;
    
    // basic variables
    float pixelSize = 5.0 / u_resolution.y;
    vec2 baseUV = uv;
    uv.x = fract(uv.x);
    
    float lineIndex = floor(baseUV.x);
    float dnaTimeIndex = lineIndex * 0.4 + u_time;
    float sinDna = sin(dnaTimeIndex) * 2.0;
    float cosDna = cos(dnaTimeIndex) * 2.0;
    
    //draw straight line
    float lineSDF = abs(uv.x - 0.5);
    float line = smoothstep(pixelSize * 2.0, 0.0, lineSDF);
    
    //cut upper part of the lines
    float sinCutLineUp = abs(sinDna);
    float sinCutMaskUp = smoothstep(sinCutLineUp + pixelSize, sinCutLineUp - pixelSize, uv.y);
    
    //cut lower part of the lines
    float sinCutLineDown = -abs(sinDna);
    float sinCutMaskDown = smoothstep(sinCutLineDown - pixelSize, sinCutLineDown + pixelSize, uv.y);
    
    // Create first side of dna circles
    vec2 circle1 = circle(uv, pixelSize, sinDna, cosDna, 1.0);
    
    // Second side of dna circles
    vec2 circle2 = circle(uv, pixelSize, sinDna, cosDna, -1.0);
    
    // Calculating line gradient for depth effect
    // Thanks to @tb for this 3D effect idea
    float lineGradient = linearstep(sinCutLineUp, sinCutLineDown, uv.y);
    if (sin(lineIndex * 0.4 + u_time) > 0.0) {
        lineGradient = 1.0 - lineGradient;
    }
    lineGradient = mix(circle1.y, circle2.y, lineGradient);
    
    //rendering line
    float helis = 0.0;
    
    //rendering circles
    if (circle1.y < circle2.y) {
        helis = mix(helis, circle1.y, circle1.x);
        helis = mix(helis, lineGradient, line * sinCutMaskUp * sinCutMaskDown);
        helis = mix(helis, circle2.y, circle2.x);
    } else {
        helis = mix(helis, circle2.y, circle2.x);
        helis = mix(helis, lineGradient, line * sinCutMaskUp * sinCutMaskDown);
        helis = mix(helis, circle1.y, circle1.x);
    }
    
    float red = helis * sin(u_time) * preuv.x * lineGradient;
    float blu = helis * cos(u_time) * preuv.y * lineGradient;
    float green = helis * (1.0 - cos(u_time) * preuv.x * lineGradient);
    
    // helis.x *= red;
    // helis.z *= blu;
    
    // gl_FragColor = vec4(uv, angle, 1.0);
    gl_FragColor = vec4(red, green, blu, 1.0);
}

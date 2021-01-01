// Shader Designed by Carlos Farini
// 2018 All rights reserved.
// uniform vec2 u_resolution;
// uniform float u_time - Given by system

float random (in float x) {
    return fract(sin(x)*1e4);
}

float random (in vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898,78.233)))* 43758.5453123);
}

float pattern(vec2 st, vec2 v, float t) {
    vec2 p = floor(st+v);
    return step(t, random(10.+p*.000001)+random(p.x)*0.5);
}

void main() {
    vec2 st = gl_FragCoord.xy/u_resolution.xy;
    st.x *= u_resolution.x/u_resolution.y;
    
    vec2 grid = vec2(90.0,30.);
    st *= grid;
    
    vec2 ipos = floor(st);  // integer
    vec2 fpos = fract(st);  // fraction
    
    vec2 vel = vec2(u_time*0.8*max(grid.x,grid.y)); // time
    vel *= vec2(-1.,0.0) * random(1.+ipos.y); // direction
    
    // Assign a random value base on the integer coord
    // vec2 offset = vec2(0.1,0.);
    
    vec3 color = vec3(0.);
    color.r = pattern(st,vel,0.5);
    color.g = pattern(st,vel,0.5);
    color.b = pattern(st,vel,0.5);
    
    // Margins
    color *= step(0.7,fpos.y);
    
    gl_FragColor = vec4(color,color);
}

// VERTICAL

//float random (in float x) {
//    return fract(sin(x)*1e4);
//}
//
//float random (in vec2 st) {
//    return fract(sin(dot(st.xy, vec2(12.9898,78.233)))* 43758.5453123);
//}
//
//float pattern(vec2 st, vec2 v, float t) {
//    vec2 p = floor(st+v);
//    return step(t, random(15.+p)+random(p.x)*0.1);
//}
//
//void main() {
//    vec2 st = gl_FragCoord.xy/u_resolution.xy;
//    st.x *= u_resolution.x/u_resolution.y;
//
//    vec2 grid = vec2(30.0,30.);
//    st *= grid;
//
//    vec2 ipos = floor(st);  // integer
//    vec2 fpos = fract(st);  // fraction
//
//    vec2 vel = vec2(u_time*0.5*max(grid.x,grid.y)); // time
//    vel *= vec2(0.,1.0) * random(0.2+ipos.x); // direction
//
//    vec3 color = vec3(0.);
//    color.r = pattern(st,vel,0.5);
//    color.g = pattern(st,vel,0.5);
//    color.b = pattern(st,vel,0.5);
//
//    // Margins
//    color *= step(fpos.x,0.7);
//
//    gl_FragColor = vec4(color,color);
//}

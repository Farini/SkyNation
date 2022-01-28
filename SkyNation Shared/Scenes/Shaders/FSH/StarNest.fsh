// Shader Designed by Carlos Farini
// SkyNation 2022 All rights reserved.


// uniform vec2 u_resolution;
// uniform float u_time - Given by system
/*
#define iterations 17
#define formuparam 0.53

#define volsteps 20
#define stepsize 0.1

#define zoom   0.800
#define tile   0.850
#define speed  0.010

#define brightness 0.0015
#define darkmatter 0.300
#define distfading 0.730
#define saturation 0.850

#define morotx 0.5
#define moroty 0.8
*/

/*
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
*/



void main() {
    
    const int iterations = 17;
    const float formuparam = 0.53;
    const int volsteps = 20;
    const float stepsize = 0.1;
    
    const float zoom = 0.800;
    const float tile = 0.850;
    const float speed = 0.003; // 0.010;
    
    const float brightness = 0.0015;
    const float darkmatter = 0.300;
    const float distfading = 0.730;
    const float saturation = 0.850;
    const float morotx = 0.5;
    const float moroty = 0.8;
    
    // get coords and direction
    vec2 uv = gl_FragCoord.xy / u_resolution.xy - 0.5;
    uv.y *= u_resolution.y / u_resolution.x;
    
    vec3 dir = vec3(uv * zoom, 1.0);
    
    float time = u_time * speed + 0.25;
    
    // rotation matrix
    
    float a1 = morotx / u_resolution.x * 2.0;
    float a2 = moroty / u_resolution.y * 2.0;
    
    mat2 rot1 = mat2(cos(a1), sin(a1), -sin(a1), cos(a1));
    mat2 rot2 = mat2(cos(a2), sin(a2), -sin(a2), cos(a2));
    
    dir.xz = dir.xz * rot1;
    dir.xy = dir.xy * rot2;
    
    vec3 from = vec3(1.0, 0.5, 0.5);
    from += vec3(time * 2.0, time / 2.0, -2.0);
    
    from.xz = from.xz * rot1;
    from.xy = from.xy * rot2;
    
    // volumetric rendering
    float s = 0.1;
    float fade = 1.0;
    vec3 v = vec3(0.0);
    
    for (int r = 0; r < volsteps; r++) {
        vec3 p = from + s * dir * .5;
        p = abs(vec3(tile) - mod(p, vec3(tile * 2.0))); // tiling fold
        
        float a = 0.0;
        float pa = 0.0;
        
        for (int i=0; i<iterations; i++) {
            p = abs(p)/dot(p,p)-formuparam; // the magic formula
            a += abs(length(p)-pa); // absolute sum of average change
            pa = length(p);
        }
        float dm = max(0.0, darkmatter-a*a*.001); //dark matter
        a *= a*a*1.2; // add contrast
        if (r > 6) {
            fade *= 1.0 - dm; // dark matter, don't render near
        }
        //v+=vec3(dm,dm*.5,0.);
        v += fade;
        v += vec3(s,s*s,s*s*s*s)*a*brightness*fade; // coloring based on distance
        fade *= distfading; // distance fading
        s += stepsize;
    }
    v = mix(vec3(length(v)),v,saturation); //color adjust
    v *= 0.01;
    
    gl_FragColor = vec4(v, 1.0);
    
    // gl_FragColor = vec4(v, 1.0);
    
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

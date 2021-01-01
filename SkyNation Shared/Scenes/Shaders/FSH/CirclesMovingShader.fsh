// Shader Designed by Carlos Farini
// 2018 All rights reserved.

// uniform vec2 u_resolution;
// uniform float u_time - Given by system

// Example Code:
//if let square = self.childNode(withName: "Square") as? SKSpriteNode{
//    let v2 = vector2(Float(square.frame.size.width), Float(square.frame.size.height))
//    let uniform = SKUniform(name: "u_resolution", vectorFloat2: v2)
//    let shader = SKShader(fileNamed: "ShaderA.fsh")
//    shader.uniforms = [uniform]
//    square.shader = shader
//}

float circle(vec2 st, float radius){
    vec2 pos = vec2(0.5)-st;
    radius *= 0.5;
    return 1.-smoothstep(radius-(radius*0.01),radius+(radius*0.01),dot(pos,pos)*3.14);
}

void main(){
    
    // This can be another uniform
    float rows = 10.0;
    
    vec2 st = gl_FragCoord.xy / u_resolution.xy;
    st.x *= u_resolution.x / u_resolution.y;
    
    st *= rows;
    
    // Offset every other row
    st.x -= step(1., mod(st.y,2.0)) * 0.5;
    
    vec2 ipos = floor(st);  // integer position
    vec2 fpos = fract(st);  // float position
    
    // Movement to Right (This can be another uniform)
    float deltax = -8.0;
    
    // Move
    ipos += vec2(floor(u_time * deltax),0.);
    
    float pct = fract(sin(dot(ipos.xy ,vec2(12.9898,78.233))) * 43758.5453);
    
    // Circle
    float radius = 0.5;
    float theCircle = circle(fpos, radius);
    
    pct *= theCircle;
    
    // To color it...
    // change the vec3(pct) to...
    // if we want to make a color (red)
    // float red = 1.0;
    // vec3 ccolor = vec3(red,v,v);
    // gl_FragColor = vec4(ccolor,1.0);
    
    gl_FragColor = vec4(vec3(pct),1.0);
}


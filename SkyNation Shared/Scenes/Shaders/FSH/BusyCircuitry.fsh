// My Shader

// rotate position around axis
vec2 rotate(vec2 p, float a) {
	return vec2(p.x * cos(a) - p.y * sin(a), p.x * sin(a) + p.y * cos(a));
}

// 2D random numbers
vec2 rand2(vec2 p) {
    vec2 pre = vec2(sin(p.x * 591.32 + p.y * 154.077), cos(p.x * 391.32 + p.y * 49.077));
//	return fract(vec2(sin(p.x * 591.32 + p.y * 154.077), cos(p.x * 391.32 + p.y * 49.077)));
    return fract(pre);
}


// 1D random numbers
float rand(float n) {
    return fract(sin(n) * 43758.5453123);
}

// 1D noise
float noise1(float p) {
	float fl = floor(p);
	float fc = fract(p);
	return mix(rand(fl), rand(fl + 1.0), fc);
}

// voronoi distance noise, based on iq's articles
float voronoi(vec2 x) {
	vec2 p = floor(x);
	vec2 f = fract(x);
	
	vec2 res = vec2(8.0);
	for(int j = -1; j <= 1; j ++) {
		for(int i = -1; i <= 1; i ++) {
            
			vec2 b = vec2(i, j);
			vec2 r = vec2(b) - f + rand2(p + b);
			
			// chebyshev distance, one of many ways to do this
			float d = max(abs(r.x), abs(r.y));
			
			if(d < res.x) {
				res.y = res.x;
				res.x = d;
			} else if(d < res.y) {
				res.y = d;
			}
		}
	}
	return res.y - res.x;
}

void main() {

    float flicker = noise1(u_time * 2.0) * 0.8 + 0.4;

    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
	uv = (uv - 0.5) * 2.0;
	vec2 suv = uv;
	uv.x = uv.x * (u_resolution.x / u_resolution.y);
	
	float v = 0.0;
	
    // --------------------------
    // Special FX might be good for NewsNode - Similar to `MarsTomorrow` game menu.
	//
	// v = 1.0 - length(uv) * 1.3;
    // --------------------------
	
	// a bit of camera movement
    uv = uv * 0.5 + sin(u_time * 0.3) * 0.3; //*= 0.5 + sin(u_time * 0.3) * 0.3;
	uv = rotate(uv, sin(u_time * 0.3) * 1.0);
    uv = uv + (u_time * 0.2); //+= u_time * 0.4;
	
	// add some noise octaves
    float a = 0.6;
    float f = 1.0;
	
    for(int i = 0; i < 3; i ++) { // 4 octaves also look nice, its getting a bit slow though
	
		float v1 = voronoi(uv * f + 5.0);
		float v2 = 0.0;
		
		// make the moving electrons-effect for higher octaves
		if(i > 0) {
			// of course everything based on voronoi
			v2 = voronoi(uv * f * 0.5 + 50.0 + u_time);
			
			float va = 0.0, vb = 0.0;
			va = 1.0 - smoothstep(0.0, 0.1, v1);
			vb = 1.0 - smoothstep(0.0, 0.08, v2);
			v = v + a * pow(va * (0.5 + vb), 2.0);
		} else if(i > 1) {
			// of course everything based on voronoi
			v2 = voronoi(uv * f * 0.5 + 50.0 + u_time);
			
			float va = 0.0, vb = 0.0;
			va = 1.0 - smoothstep(0.0, 0.1, v1);
			vb = 1.0 - smoothstep(0.0, 0.08, v2);
			v = v + 0.01 * pow(va * (0.5 + vb), 2.0);
		}
		
		// make sharp edges
		v1 = 1.0 - smoothstep(0.0, 0.3, v1);
		
		// noise is used as intensity map
		v2 = a * (noise1(v1 * 5.5 + 0.1));
		
		// octave 0's intensity changes a bit
        if(i == 0) {
			v = v + v2 * flicker;
        } else {
			v = v + v2;
        }
        
		f *= 3.0;
		a *= 0.7;
	}

    
	// slight vignetting
	// v *= exp(-0.6 * length(suv)) * 1.2;
	
	vec3 cexp = vec3(2.0, 2.0, 1.0);
	cexp = cexp * 1.8;
	
	// old blueish color set
	// vec3 cexp = vec3(6.0, 4.0, 2.0);
	
	vec3 col = vec3(pow(v, cexp.x), pow(v, cexp.y), pow(v, cexp.z)) * 2.0;
    vec3 c2 = min(col, vec3(1.0)) * 0.75;
    
    // vec3 fake = vec3(0.5, 0.5, flicker);
    
	gl_FragColor = vec4(c2, 1.0);
}

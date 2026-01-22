// transparent background
const bool transparent = false;

// terminal contents luminance threshold to be considered background
const float threshold = 0.15;

// divisions of grid
const float repeats = 30.;

// number of layers
const float layers = 21.;

// GLOBAL SPEED CONTROL: Lower this to slow down time (0.1 = 10% speed)
const float speedFactor = 0.05;

float luminance(vec3 color) {
    return dot(color, vec3(0.2126, 0.7152, 0.0722));
}

float N21(vec2 p) {
    p = fract(p * vec2(233.34, 851.73));
    p += dot(p, p + 23.45);
    return fract(p.x * p.y);
}

vec2 N22(vec2 p) {
    float n = N21(p);
    return vec2(n, N21(p + n));
}

mat2 scale(vec2 _scale) {
    return mat2(_scale.x, 0.0,
        0.0, _scale.y);
}

// Background Starfield Logic
vec3 stars(vec2 uv, float offset) {
    // SLOWED DOWN: Applied speedFactor to timeScale
    float timeScale = -(iTime * speedFactor + offset) / layers;
    float trans = fract(timeScale);
    float newRnd = floor(timeScale);
    vec3 col = vec3(0.);
    
    uv -= vec2(0.5);
    uv = scale(vec2(trans)) * uv;
    uv += vec2(0.5);

    uv.x *= iResolution.x / iResolution.y;
    uv *= repeats;

    vec2 ipos = floor(uv);
    uv = fract(uv);
    
    vec2 rndXY = N22(newRnd + ipos * (offset + 1.)) * 0.9 + 0.05;
    float rndSize = N21(ipos) * 100. + 200.;

    // Randomize Star Color (Blueish to Reddish)
    float starType = N21(ipos + 10.0);
    vec3 starColor = mix(vec3(0.6, 0.8, 1.0), vec3(1.0, 0.9, 0.7), starType);

    vec2 j = (rndXY - uv) * rndSize;
    float sparkle = 1. / dot(j, j);

    col += starColor * sparkle;
    col *= smoothstep(1., 0.8, trans);
    return col; 
}

// Helper: Draws a 3D lit sphere
vec3 drawPlanetBody(vec2 uv, vec2 center, float radius, vec3 color) {
    float d = length(uv - center);
    
    // Mask for the planet disc
    float circle = smoothstep(radius, radius - 0.001, d);
    
    if (d > radius) return vec3(0.0); // Optimization

    // 3D Fake Normals
    // Calculate "z" depth of sphere at this pixel
    vec2 localPos = (uv - center) / radius;
    float z = sqrt(max(0.0, 1.0 - dot(localPos, localPos))); 
    vec3 normal = normalize(vec3(localPos, z));

    // Light Source Direction (Sun is at 0,0,0)
    // Vector from Surface to Sun
    vec3 surfacePos = vec3(uv.x, uv.y, 0.0);
    vec3 lightDir = normalize(vec3(0.0) - surfacePos);

    // Diffuse Lighting (Dot product)
    float diffuse = max(0.05, dot(normal, lightDir)); // 0.05 ambient light
    
    // Specular Highlight (Reflection of the sun)
    vec3 viewDir = vec3(0.0, 0.0, 1.0);
    vec3 reflectDir = reflect(-lightDir, normal);
    float spec = pow(max(dot(viewDir, reflectDir), 0.0), 16.0) * 0.3;

    // Rim lighting (Atmosphere effect on edges)
    float rim = (1.0 - dot(normal, viewDir)) * 0.2;

    return circle * (color * diffuse + spec + color * rim);
}

vec3 drawSolarSystem(vec2 uv) {
    vec3 col = vec3(0.0);
    float dist = length(uv);
    
    // SLOWED TIME
    float t = iTime * speedFactor;

    // 1. THE SUN (Enhanced)
    float sunRadius = 0.08;
    // Core (White hot)
    float sunCore = smoothstep(sunRadius * 0.8, sunRadius * 0.2, dist);
    // Corona (Orange/Yellow)
    float sunBody = smoothstep(sunRadius, sunRadius - 0.01, dist);
    // Outer Glow (Inverse falloff)
    float sunGlow = 0.02 / (dist + 0.01);
    
    vec3 sunColorInner = vec3(1.0, 1.0, 0.8);
    vec3 sunColorOuter = vec3(1.0, 0.6, 0.1);
    
    // Composite Sun
    col += sunBody * mix(sunColorOuter, sunColorInner, sunCore);
    col += sunGlow * sunColorOuter * 0.5;

    // 2. PLANETS (Physically Shaded)
    
    // Planet 1: Mercury-ish
    float p1_dist = 0.16;
    float p1_ang = t * 4.0; 
    vec2 p1_pos = vec2(cos(p1_ang), sin(p1_ang)) * p1_dist;
    col += drawPlanetBody(uv, p1_pos, 0.008, vec3(0.7, 0.6, 0.6));
    col += smoothstep(0.002, 0.0, abs(dist - p1_dist)) * 0.03; // Orbit line

    // Planet 2: Venus-ish
    float p2_dist = 0.24;
    float p2_ang = t * 2.5 + 1.0; 
    vec2 p2_pos = vec2(cos(p2_ang), sin(p2_ang)) * p2_dist;
    col += drawPlanetBody(uv, p2_pos, 0.014, vec3(0.9, 0.8, 0.5));
    col += smoothstep(0.002, 0.0, abs(dist - p2_dist)) * 0.03;

    // Planet 3: Earth-ish
    float p3_dist = 0.35;
    float p3_ang = t * 1.5 + 3.0; 
    vec2 p3_pos = vec2(cos(p3_ang), sin(p3_ang)) * p3_dist;
    col += drawPlanetBody(uv, p3_pos, 0.015, vec3(0.2, 0.5, 0.9));
    col += smoothstep(0.002, 0.0, abs(dist - p3_dist)) * 0.03;

    // Planet 4: Mars-ish
    float p4_dist = 0.50;
    float p4_ang = t * 0.8 + 5.0; 
    vec2 p4_pos = vec2(cos(p4_ang), sin(p4_ang)) * p4_dist;
    col += drawPlanetBody(uv, p4_pos, 0.011, vec3(0.8, 0.3, 0.2));
    col += smoothstep(0.002, 0.0, abs(dist - p4_dist)) * 0.02; // Fainter orbit

    // Planet 5: Gas Giant
    float p5_dist = 0.75;
    float p5_ang = t * 0.4 + 2.0; 
    vec2 p5_pos = vec2(cos(p5_ang), sin(p5_ang)) * p5_dist;
    col += drawPlanetBody(uv, p5_pos, 0.035, vec3(0.8, 0.7, 0.6));
    col += smoothstep(0.002, 0.0, abs(dist - p5_dist)) * 0.02;

    return col;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec2 uv = fragCoord / iResolution.xy;
    
    // Starfield Background
    vec3 col = vec3(0.);
    for (float i = 0.; i < layers; i++) {
        col += stars(uv, i);
    }
    
    // Solar System Overlay
    vec2 centerUV = uv - 0.5;
    centerUV.x *= iResolution.x / iResolution.y;
    col += drawSolarSystem(centerUV);

    // Terminal Masking
    vec4 terminalColor = texture(iChannel0, uv);
    if (transparent) {
        col += terminalColor.rgb;
    }

    float mask = 1.0 - step(threshold, luminance(terminalColor.rgb));
    vec3 blendedColor = mix(terminalColor.rgb, col, mask);

    fragColor = vec4(blendedColor, terminalColor.a);
}

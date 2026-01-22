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

// Simplex-ish noise for surface detail
float hash(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    float a = hash(i);
    float b = hash(i + vec2(1.0, 0.0));
    float c = hash(i + vec2(0.0, 1.0));
    float d = hash(i + vec2(1.0, 1.0));
    return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

float fbm(vec2 p) {
    float value = 0.0;
    float amplitude = 0.5;
    for (int i = 0; i < 5; i++) {
        value += amplitude * noise(p);
        p *= 2.0;
        amplitude *= 0.5;
    }
    return value;
}

// Cosmic stardust / nebula clouds
vec3 stardust(vec2 uv, float t) {
    vec3 col = vec3(0.0);
    
    // Slow drift
    vec2 drift = vec2(t * 0.02, t * 0.01);
    
    // Multiple layers of dust at different scales
    // Layer 1: Large diffuse clouds
    float dust1 = fbm(uv * 1.5 + drift);
    dust1 = smoothstep(0.35, 0.7, dust1);
    
    // Layer 2: Medium detail
    float dust2 = fbm(uv * 3.0 - drift * 0.5 + 10.0);
    dust2 = smoothstep(0.4, 0.75, dust2);
    
    // Layer 3: Fine particles
    float dust3 = fbm(uv * 6.0 + drift * 0.3 + 20.0);
    dust3 = smoothstep(0.45, 0.8, dust3) * 0.5;
    
    // Color palette - subtle cosmic hues
    vec3 dustBlue = vec3(0.15, 0.2, 0.35);    // Deep blue
    vec3 dustPurple = vec3(0.25, 0.15, 0.3);  // Subtle purple
    vec3 dustAmber = vec3(0.3, 0.2, 0.1);     // Warm amber
    
    // Blend colors based on position
    float colorMix = fbm(uv * 0.8 + 5.0);
    vec3 dustColor = mix(dustBlue, dustPurple, colorMix);
    dustColor = mix(dustColor, dustAmber, smoothstep(0.5, 0.8, colorMix) * 0.4);
    
    // Combine layers
    float totalDust = dust1 * 0.4 + dust2 * 0.35 + dust3 * 0.25;
    
    // Keep it subtle - stardust should be background atmosphere
    col = dustColor * totalDust * 0.18;
    
    // Add faint scattered particles (tiny bright specks in dust)
    float particles = fbm(uv * 25.0 + drift * 2.0);
    particles = pow(smoothstep(0.7, 0.95, particles), 3.0);
    col += vec3(0.4, 0.35, 0.3) * particles * totalDust * 0.15;
    
    return col;
}

// Background Starfield - Astronomical quality with depth
vec3 stars(vec2 uv, float offset) {
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
    vec2 fpos = fract(uv);
    
    // Randomize star position within cell
    vec2 rndXY = N22(newRnd + ipos * (offset + 1.)) * 0.8 + 0.1;
    
    // Depth-based properties: layers further back = dimmer, smaller
    float depthFactor = (offset + 1.0) / layers;
    float invDepth = 1.0 - depthFactor * 0.7; // Near stars brighter
    
    // Base star size varies with depth and randomness
    float baseSize = mix(0.015, 0.045, N21(ipos + 5.0));
    baseSize *= invDepth;
    
    // Distance from star center
    float d = length(fpos - rndXY);
    
    // Determine if this is a rare bright primary star (1 in ~50)
    float primaryChance = N21(ipos + newRnd * 0.1 + 99.0);
    bool isPrimary = primaryChance > 0.98 && depthFactor < 0.3;
    
    if (isPrimary) {
        baseSize *= 2.5;
    }
    
    // Gaussian-like falloff for photographic look (not harsh 1/r^2)
    float starCore = exp(-d * d / (baseSize * baseSize * 0.5));
    
    // Soft halo for brighter stars
    float halo = exp(-d * d / (baseSize * baseSize * 4.0)) * 0.15;
    
    // Natural stellar colors based on spectral type
    // Cool bluish (O/B) -> White (A/F) -> Warm yellow (G/K)
    float starType = N21(ipos + 10.0);
    vec3 starColor;
    if (starType < 0.15) {
        // Hot blue-white (rare O/B stars)
        starColor = vec3(0.75, 0.85, 1.0);
    } else if (starType < 0.5) {
        // White to pale yellow (A/F/G - Sun-like)
        starColor = mix(vec3(1.0, 0.98, 0.95), vec3(1.0, 0.95, 0.85), (starType - 0.15) / 0.35);
    } else if (starType < 0.85) {
        // Yellow-orange (K stars)
        starColor = mix(vec3(1.0, 0.92, 0.8), vec3(1.0, 0.85, 0.7), (starType - 0.5) / 0.35);
    } else {
        // Cooler orange-red (M stars, dimmer)
        starColor = vec3(1.0, 0.75, 0.6);
        starCore *= 0.6; // M-dwarfs are dimmer
    }
    
    // Brightness variation
    float brightness = N21(ipos + 20.0) * 0.5 + 0.5;
    brightness *= invDepth;
    
    if (isPrimary) {
        brightness = 1.5; // Primary stars pop
        starColor = mix(starColor, vec3(1.0), 0.3); // Slightly whiter
    }
    
    // Combine core and halo
    float starIntensity = starCore + halo;
    starIntensity *= brightness;
    
    // No twinkle in space (it's an atmospheric effect)
    
    col += starColor * starIntensity;
    
    // Fade during layer transition
    col *= smoothstep(1., 0.85, trans);
    
    return col; 
}

// Enhanced Sun with Animated Plasma
vec3 drawSun(vec2 uv, float t) {
    float dist = length(uv);
    vec3 col = vec3(0.0);
    
    float sunRadius = 0.08;
    
    // Animated turbulent noise for solar surface
    vec2 sunUV = uv / sunRadius;
    float plasmaSpeed = t * 0.3;
    float plasma1 = fbm(sunUV * 4.0 + vec2(plasmaSpeed, 0.0));
    float plasma2 = fbm(sunUV * 8.0 - vec2(0.0, plasmaSpeed * 0.7));
    float plasma = plasma1 * 0.6 + plasma2 * 0.4;
    
    // Core colors - from blinding white center to deep orange edge
    vec3 coreWhite = vec3(1.0, 1.0, 0.95);
    vec3 coreYellow = vec3(1.0, 0.95, 0.4);
    vec3 midOrange = vec3(1.0, 0.6, 0.1);
    vec3 edgeRed = vec3(0.9, 0.2, 0.05);
    
    float coreFactor = smoothstep(sunRadius, 0.0, dist);
    vec3 sunColor = mix(edgeRed, midOrange, smoothstep(0.0, 0.5, coreFactor));
    sunColor = mix(sunColor, coreYellow, smoothstep(0.5, 0.8, coreFactor));
    sunColor = mix(sunColor, coreWhite, smoothstep(0.8, 1.0, coreFactor));
    
    // Add plasma variation to surface
    sunColor += vec3(plasma * 0.3, plasma * 0.15, 0.0) * coreFactor;
    
    // Main sun body
    float sunBody = smoothstep(sunRadius, sunRadius - 0.003, dist);
    col += sunBody * sunColor * 1.2;
    
    // Solar flares / prominences
    float flareAngle = atan(uv.y, uv.x);
    float flareNoise = fbm(vec2(flareAngle * 3.0, t * 0.5)) * 0.015;
    float flare = smoothstep(sunRadius + 0.02 + flareNoise, sunRadius, dist);
    col += flare * midOrange * 0.5;
    
    // Corona layers
    float corona1 = 0.015 / (dist - sunRadius * 0.9 + 0.02);
    float corona2 = 0.008 / (dist - sunRadius * 0.7 + 0.05);
    corona1 *= smoothstep(sunRadius * 0.9, sunRadius * 1.5, dist);
    corona2 *= smoothstep(sunRadius * 0.7, sunRadius * 2.0, dist);
    
    col += corona1 * vec3(1.0, 0.5, 0.1) * 0.4;
    col += corona2 * vec3(1.0, 0.3, 0.05) * 0.2;
    
    // Outer glow
    float glow = 0.02 / (dist + 0.01);
    col += glow * vec3(1.0, 0.4, 0.1) * 0.3;
    
    // Pulsation
    float pulse = 1.0 + sin(t * 2.0) * 0.05;
    col *= pulse;
    
    return col;
}

// Draw textured planet with atmosphere
vec3 drawPlanet(vec2 uv, vec2 center, float radius, vec3 baseColor, vec3 secondColor, 
                float noiseScale, float atmosphereStrength, vec3 atmoColor, float rotation) {
    float d = length(uv - center);
    
    if (d > radius * 2.0) return vec3(0.0);
    
    vec2 localPos = (uv - center) / radius;
    
    // Atmosphere glow (outside planet)
    vec3 col = vec3(0.0);
    float atmoGlow = smoothstep(radius * 1.5, radius, d) * smoothstep(radius * 0.8, radius, d);
    col += atmoGlow * atmoColor * atmosphereStrength * 0.5;
    
    if (d > radius) return col;
    
    // 3D sphere math
    float z = sqrt(max(0.0, 1.0 - dot(localPos, localPos)));
    vec3 normal = normalize(vec3(localPos, z));
    
    // Spherical UV mapping for texture
    float theta = atan(normal.x, normal.z) + rotation;
    float phi = asin(normal.y);
    vec2 sphereUV = vec2(theta / 3.14159, phi / 1.5708);
    
    // Surface noise/texture
    float surfaceNoise = fbm(sphereUV * noiseScale);
    vec3 surfaceColor = mix(baseColor, secondColor, surfaceNoise);
    
    // Lighting from sun at origin
    vec3 surfacePos = vec3(center, 0.0);
    vec3 lightDir = normalize(-surfacePos);
    
    float diffuse = max(0.0, dot(normal, lightDir));
    // Smoother terminator (day/night boundary) - darker night side
    diffuse = smoothstep(-0.2, 0.4, diffuse) * 0.98 + 0.02;
    
    // Specular
    vec3 viewDir = vec3(0.0, 0.0, 1.0);
    vec3 reflectDir = reflect(-lightDir, normal);
    float spec = pow(max(dot(viewDir, reflectDir), 0.0), 32.0) * 0.4;
    
    // Rim lighting (atmospheric scattering at edges)
    float rim = pow(1.0 - dot(normal, viewDir), 3.0);
    
    // Fresnel-like atmosphere
    float fresnel = pow(1.0 - z, 2.0);
    
    col += surfaceColor * diffuse;
    col += spec * vec3(1.0);
    col += rim * atmoColor * atmosphereStrength;
    col += fresnel * atmoColor * atmosphereStrength * 0.3;
    
    return col;
}

// Special Earth with continents, oceans, clouds
vec3 drawEarth(vec2 uv, vec2 center, float radius, float t) {
    float d = length(uv - center);
    
    if (d > radius * 2.0) return vec3(0.0);
    
    vec2 localPos = (uv - center) / radius;
    
    // Atmosphere glow
    vec3 col = vec3(0.0);
    vec3 atmoColor = vec3(0.3, 0.6, 1.0);
    float atmoGlow = smoothstep(radius * 1.6, radius, d) * smoothstep(radius * 0.85, radius, d);
    col += atmoGlow * atmoColor * 0.6;
    
    if (d > radius) return col;
    
    float z = sqrt(max(0.0, 1.0 - dot(localPos, localPos)));
    vec3 normal = normalize(vec3(localPos, z));
    
    // Spherical mapping with rotation
    float rotation = t * 0.2;
    float theta = atan(normal.x, normal.z) + rotation;
    float phi = asin(normal.y);
    vec2 sphereUV = vec2(theta, phi);
    
    // Generate "continents"
    float continent = fbm(sphereUV * 3.0 + 1.5);
    continent = smoothstep(0.45, 0.55, continent);
    
    // Ocean & land colors
    vec3 oceanDeep = vec3(0.02, 0.1, 0.3);
    vec3 oceanShallow = vec3(0.1, 0.3, 0.5);
    vec3 landGreen = vec3(0.15, 0.4, 0.1);
    vec3 landBrown = vec3(0.5, 0.35, 0.2);
    vec3 snow = vec3(0.95, 0.95, 1.0);
    
    // Ocean color variation
    float oceanVar = fbm(sphereUV * 8.0);
    vec3 oceanColor = mix(oceanDeep, oceanShallow, oceanVar * 0.5);
    
    // Land color variation
    float landVar = fbm(sphereUV * 6.0 + 10.0);
    vec3 landColor = mix(landGreen, landBrown, landVar);
    
    // Ice caps
    float iceCap = smoothstep(0.7, 0.9, abs(phi / 1.5708));
    landColor = mix(landColor, snow, iceCap);
    oceanColor = mix(oceanColor, snow * 0.9, iceCap * 0.5);
    
    vec3 surfaceColor = mix(oceanColor, landColor, continent);
    
    // Cloud layer
    float cloudNoise = fbm(sphereUV * 5.0 + t * 0.1);
    float clouds = smoothstep(0.4, 0.7, cloudNoise);
    vec3 cloudColor = vec3(1.0, 1.0, 1.0);
    surfaceColor = mix(surfaceColor, cloudColor, clouds * 0.6);
    
    // Lighting
    vec3 lightDir = normalize(-vec3(center, 0.0));
    float diffuse = max(0.0, dot(normal, lightDir));
    diffuse = smoothstep(-0.1, 0.4, diffuse) * 0.85 + 0.15;
    
    // Night side city lights (faint orange dots on land)
    float nightSide = smoothstep(0.2, -0.1, dot(normal, lightDir));
    float cityLights = fbm(sphereUV * 20.0) * continent * nightSide;
    cityLights = smoothstep(0.5, 0.8, cityLights);
    
    // Specular on ocean
    vec3 viewDir = vec3(0.0, 0.0, 1.0);
    vec3 reflectDir = reflect(-lightDir, normal);
    float spec = pow(max(dot(viewDir, reflectDir), 0.0), 48.0) * (1.0 - continent) * 0.6;
    
    // Rim
    float rim = pow(1.0 - z, 3.0);
    
    col += surfaceColor * diffuse;
    col += spec * vec3(1.0, 0.95, 0.9);
    col += rim * atmoColor * 0.5;
    col += cityLights * vec3(1.0, 0.7, 0.3) * 0.3;
    
    return col;
}

// Gas giant with bands
vec3 drawGasGiant(vec2 uv, vec2 center, float radius, float t, bool hasRings) {
    vec3 col = vec3(0.0);
    float d = length(uv - center);
    
    // Ring system (draw behind and in front)
    if (hasRings) {
        vec2 ringUV = uv - center;
        // Tilt the ring plane
        float tilt = 0.3;
        float ringY = ringUV.y / tilt;
        float ringDist = length(vec2(ringUV.x, ringY));
        
        if (ringDist > radius * 1.2 && ringDist < radius * 2.2 && abs(ringUV.y) < radius * 0.15) {
            // Ring bands
            float ringBand = sin(ringDist * 80.0) * 0.5 + 0.5;
            ringBand *= fbm(vec2(ringDist * 10.0, atan(ringUV.y, ringUV.x) * 2.0)) * 0.5 + 0.5;
            
            vec3 ringColor = mix(vec3(0.7, 0.6, 0.5), vec3(0.9, 0.85, 0.7), ringBand);
            
            // Shadow from planet
            float shadowMask = smoothstep(radius * 0.8, radius * 1.0, abs(ringUV.x));
            if (ringUV.x < 0.0) shadowMask = 1.0; // Only shadow on sun-opposite side
            
            // Ring behind planet mask (when y < 0, ring is behind)
            float behindPlanet = (ringUV.y < 0.0 && d < radius) ? 0.0 : 1.0;
            
            col += ringColor * 0.5 * ringBand * shadowMask * behindPlanet;
        }
    }
    
    if (d > radius * 1.8) return col;
    
    vec2 localPos = (uv - center) / radius;
    
    // Atmosphere
    vec3 atmoColor = vec3(0.8, 0.7, 0.5);
    float atmoGlow = smoothstep(radius * 1.4, radius, d) * smoothstep(radius * 0.9, radius, d);
    col += atmoGlow * atmoColor * 0.3;
    
    if (d > radius) return col;
    
    float z = sqrt(max(0.0, 1.0 - dot(localPos, localPos)));
    vec3 normal = normalize(vec3(localPos, z));
    
    // Latitude bands
    float lat = localPos.y;
    float rotation = t * 0.15;
    float lon = atan(normal.x, normal.z) + rotation;
    
    // Jupiter-like bands
    float bands = sin(lat * 25.0) * 0.5 + 0.5;
    float bandDetail = fbm(vec2(lon * 2.0, lat * 10.0 + t * 0.05));
    bands = bands * 0.7 + bandDetail * 0.3;
    
    // Storm (Great Red Spot analog)
    vec2 stormPos = vec2(lon, lat * 3.0) - vec2(t * 0.02, 0.3);
    float storm = 1.0 - smoothstep(0.0, 0.3, length(stormPos - floor(stormPos + 0.5)));
    
    // Colors
    vec3 bandLight = vec3(0.9, 0.85, 0.7);
    vec3 bandDark = vec3(0.7, 0.5, 0.3);
    vec3 stormColor = vec3(0.8, 0.4, 0.3);
    
    vec3 surfaceColor = mix(bandDark, bandLight, bands);
    surfaceColor = mix(surfaceColor, stormColor, storm * 0.6);
    
    // Lighting - darker night side for gas giant
    vec3 lightDir = normalize(-vec3(center, 0.0));
    float diffuse = max(0.0, dot(normal, lightDir));
    diffuse = smoothstep(-0.2, 0.4, diffuse) * 0.98 + 0.02;
    
    float rim = pow(1.0 - z, 2.5);
    
    col += surfaceColor * diffuse;
    col += rim * atmoColor * 0.3;
    
    return col;
}

// Orbit lines with subtle glow
vec3 drawOrbit(float dist, float orbitRadius) {
    float orbit = smoothstep(0.002, 0.0, abs(dist - orbitRadius));
    orbit += smoothstep(0.008, 0.0, abs(dist - orbitRadius)) * 0.3;
    return vec3(0.3, 0.4, 0.5) * orbit * 0.15;
}

vec3 drawSolarSystem(vec2 uv) {
    vec3 col = vec3(0.0);
    float dist = length(uv);
    float t = iTime * speedFactor;

    // No orbit lines - realistic space view

    // Mercury - very slow rotation (58.6 Earth days)
    float p1_dist = 0.16;
    float p1_ang = t * 4.0; 
    vec2 p1_pos = vec2(cos(p1_ang), sin(p1_ang)) * p1_dist;
    float p1_rot = t * 0.02; // Very slow axial rotation
    col += drawPlanet(uv, p1_pos, 0.01, 
        vec3(0.55, 0.5, 0.5), vec3(0.7, 0.65, 0.6), 
        12.0, 0.0, vec3(0.0), p1_rot);

    // Venus - extremely slow retrograde rotation (243 Earth days, backwards)
    float p2_dist = 0.24;
    float p2_ang = t * 2.5 + 1.0; 
    vec2 p2_pos = vec2(cos(p2_ang), sin(p2_ang)) * p2_dist;
    float p2_rot = -t * 0.005; // Retrograde (negative), very slow
    col += drawPlanet(uv, p2_pos, 0.015, 
        vec3(0.9, 0.75, 0.4), vec3(0.95, 0.85, 0.6), 
        8.0, 0.4, vec3(1.0, 0.9, 0.7), p2_rot);

    // Earth - 24 hour rotation
    float p3_dist = 0.35;
    float p3_ang = t * 1.5 + 3.0; 
    vec2 p3_pos = vec2(cos(p3_ang), sin(p3_ang)) * p3_dist;
    col += drawEarth(uv, p3_pos, 0.018, t);
    
    // Moon - tidally locked (same face always toward Earth)
    float moonDist = 0.035;
    float moonAng = t * 8.0;
    vec2 moonPos = p3_pos + vec2(cos(moonAng), sin(moonAng)) * moonDist;
    float moonRot = moonAng; // Synced with orbit = tidally locked
    col += drawPlanet(uv, moonPos, 0.004, 
        vec3(0.7, 0.7, 0.7), vec3(0.5, 0.5, 0.5), 
        15.0, 0.0, vec3(0.0), moonRot);

    // Mars - ~24.6 hour rotation (similar to Earth)
    float p4_dist = 0.50;
    float p4_ang = t * 0.8 + 5.0; 
    vec2 p4_pos = vec2(cos(p4_ang), sin(p4_ang)) * p4_dist;
    float p4_rot = t * 1.2; // Slightly slower than Earth's visual rotation
    col += drawPlanet(uv, p4_pos, 0.012, 
        vec3(0.8, 0.35, 0.2), vec3(0.6, 0.25, 0.15), 
        10.0, 0.15, vec3(1.0, 0.6, 0.4), p4_rot);

    // Jupiter - fast rotation (~10 hours)
    float p5_dist = 0.75;
    float p5_ang = t * 0.4 + 2.0; 
    vec2 p5_pos = vec2(cos(p5_ang), sin(p5_ang)) * p5_dist;
    col += drawGasGiant(uv, p5_pos, 0.04, t, true);

    // Sun (drawn last for bloom on top)
    col += drawSun(uv, t);

    return col;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec2 uv = fragCoord / iResolution.xy;
    
    // Cosmic stardust (drawn first, behind everything)
    vec2 dustUV = uv - 0.5;
    dustUV.x *= iResolution.x / iResolution.y;
    vec3 col = stardust(dustUV, iTime * speedFactor);
    
    // Starfield Background
    for (float i = 0.; i < layers; i++) {
        col += stars(uv, i);
    }
    
    // Solar System Overlay
    vec2 centerUV = uv - 0.5;
    centerUV.x *= iResolution.x / iResolution.y;
    
    // Mask stars behind the sun (clear circular area)
    float sunDist = length(centerUV);
    float sunMask = smoothstep(0.06, 0.12, sunDist);
    col *= sunMask;
    
    col += drawSolarSystem(centerUV);

    // Cinematic lens flare from sun
    float flareIntensity = 0.03 / (sunDist + 0.05);
    vec2 flareDir = normalize(centerUV);
    float flareStreak = abs(dot(normalize(centerUV + 0.001), vec2(0.707, 0.707)));
    flareStreak = pow(flareStreak, 8.0) * 0.15 / (sunDist + 0.1);
    col += vec3(1.0, 0.8, 0.5) * flareIntensity * 0.3;
    col += vec3(1.0, 0.9, 0.7) * flareStreak * 0.2;

    // Very subtle vignette (barely noticeable)
    float vignette = 1.0 - length(uv - 0.5) * 0.25;
    col *= vignette;

    // Terminal Masking
    vec4 terminalColor = texture(iChannel0, uv);
    if (transparent) {
        col += terminalColor.rgb;
    }

    float mask = 1.0 - step(threshold, luminance(terminalColor.rgb));
    vec3 blendedColor = mix(terminalColor.rgb, col, mask);

    fragColor = vec4(blendedColor, terminalColor.a);
}

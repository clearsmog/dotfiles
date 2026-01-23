// Claude Ambient Shader
// A warm, gentle glow rising from the bottom like a sunrise
// with breathing animation and horizontal wave motion
// Features: coral-to-tan gradient, gentle wave, slow breathing

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord.xy / iResolution.xy;

    // Sample terminal content
    vec4 terminalColor = texture(iChannel0, uv);

    // Claude's color gradient: coral at bottom -> tan higher up
    vec3 claudeCoral = vec3(0.85, 0.47, 0.34);
    vec3 claudeTan = vec3(0.95, 0.85, 0.75);

    // Gradient height
    float gradientHeight = 0.35;

    // Horizontal wave motion (~8 second cycle)
    float wave = sin(uv.x * 6.0 + iTime * 0.8) * 0.03;

    // Bottom gradient with wave - stronger at bottom, fading upward
    float gradient = 1.0 - smoothstep(0.0, gradientHeight + wave, uv.y);

    // Blend coral to tan based on vertical position within the gradient
    float colorBlend = clamp(uv.y / gradientHeight, 0.0, 1.0);
    vec3 claudeColor = mix(claudeCoral, claudeTan, colorBlend);

    // Slow breathing animation (~10 second cycle)
    float breathe = sin(iTime * 0.628) * 0.1 + 0.9;

    // Combine gradient with breathing
    float glowIntensity = gradient * breathe * 0.3;

    // Detect if light or dark theme based on terminal luminance
    float luminance = dot(terminalColor.rgb, vec3(0.299, 0.587, 0.114));

    // For light themes (luminance > 0.5): tint background areas
    // For dark themes (luminance < 0.5): add glow to dark areas
    float isLightTheme = step(0.5, luminance);

    // Light theme: apply to bright backgrounds, Dark theme: apply to dark backgrounds
    float backgroundMask = mix(
        1.0 - smoothstep(0.0, 0.4, luminance),  // dark theme mask
        smoothstep(0.5, 0.9, luminance),         // light theme mask
        isLightTheme
    );

    // Blend glow with terminal
    vec3 finalColor = mix(terminalColor.rgb, claudeColor, glowIntensity * backgroundMask);

    fragColor = vec4(finalColor, terminalColor.a);
}

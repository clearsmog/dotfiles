// Claude UI Ambient Shader
// Recreates the warm, minimal aesthetic of Claude's web/desktop interface
// Design: Cream warmth, soft contrast, subtle coral accent, imperceptible motion

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord.xy / iResolution.xy;

    // Sample terminal content
    vec4 terminalColor = texture(iChannel0, uv);
    vec3 color = terminalColor.rgb;

    // ═══════════════════════════════════════════════════════════════
    // CLAUDE'S COLOR PALETTE
    // ═══════════════════════════════════════════════════════════════
    vec3 claudeCream = vec3(0.98, 0.976, 0.969);    // #FAF9F7 - main bg
    vec3 claudeBeige = vec3(0.961, 0.953, 0.937);   // #F5F3EF - secondary
    vec3 claudeCoral = vec3(0.878, 0.478, 0.373);   // #E07A5F - accent
    vec3 claudeCoralSoft = vec3(0.957, 0.639, 0.576); // #F4A393 - light accent

    // ═══════════════════════════════════════════════════════════════
    // 1. CREAM WARMTH TINT (matches Claude's warm background)
    // ═══════════════════════════════════════════════════════════════
    // Shift entire terminal toward Claude's cream tone
    // 5% blend - noticeable warmth without color distortion

    float creamIntensity = 0.05;
    color = mix(color, color * claudeCream, creamIntensity);

    // Additional warmth: slightly reduce blue, boost warm channels
    color.b *= 0.97;
    color.r *= 1.01;

    // ═══════════════════════════════════════════════════════════════
    // 2. CONTRAST SOFTENING (matches Claude's soft UI)
    // ═══════════════════════════════════════════════════════════════
    // Claude uses soft black (#1A1A1A) not pure black
    // Claude uses cream whites, not pure white

    vec3 softBlack = vec3(0.10, 0.10, 0.10);  // Lifted blacks
    vec3 softWhite = vec3(0.973, 0.965, 0.953); // #F8F6F3 cream whites

    // Smooth contrast compression
    color = mix(softBlack, softWhite, color);

    // ═══════════════════════════════════════════════════════════════
    // 3. SUBTLE CORAL AMBIENT (Claude's signature accent)
    // ═══════════════════════════════════════════════════════════════
    // Very gentle coral glow from bottom - like warmth rising
    // Maximum 3% intensity - accent, not feature

    // Flip Y for bottom-up effect (Ghostty Y=0 at top)
    float effectY = 1.0 - uv.y;

    // Soft gradient from bottom (only affects bottom 25%)
    float coralGradient = smoothstep(0.75, 0.0, effectY) * 0.03;

    // Horizontal variation - subtle, organic feel
    float horizontalVar = sin(uv.x * 3.14159) * 0.5 + 0.5;
    coralGradient *= (0.7 + horizontalVar * 0.3);

    // Apply coral tint
    vec3 coralTint = mix(claudeCoralSoft, claudeCoral, effectY);
    color = mix(color, color + coralTint * 0.15, coralGradient);

    // ═══════════════════════════════════════════════════════════════
    // 4. IMPERCEPTIBLE BREATHING (120-second cycle)
    // ═══════════════════════════════════════════════════════════════
    // So slow you can't perceive it, but creates subtle "life"

    // 120-second cycle = 2*PI / 120 = 0.0524 rad/sec
    float breath = sin(iTime * 0.0524) * 0.5 + 0.5;

    // Only 1.5% variation, only on the coral accent
    float breathEffect = 1.0 + (breath - 0.5) * 0.015;
    color = mix(color, color * vec3(1.0, 0.995, 0.99), coralGradient * breath * 0.5);

    // ═══════════════════════════════════════════════════════════════
    // 5. SOFT VIGNETTE (clean focus on content)
    // ═══════════════════════════════════════════════════════════════
    // Very gentle edge darkening - keeps focus on center

    vec2 center = uv - 0.5;
    float vignette = 1.0 - dot(center, center) * 0.15;
    color *= vignette;

    // ═══════════════════════════════════════════════════════════════
    // OUTPUT
    // ═══════════════════════════════════════════════════════════════
    // Clamp to valid range
    color = clamp(color, 0.0, 1.0);

    fragColor = vec4(color, terminalColor.a);
}

#include <metal_stdlib>
using namespace metal;

// MARK: - Underwater Caustics Shader
// Creates a subtle animated light caustic pattern simulating
// sunlight filtering through ocean water.

[[ stitchable ]] half4 oceanCaustics(
    float2 position,
    half4 color,
    float2 size,
    float time
) {
    // Normalize coordinates
    float2 uv = position / size;

    // Slow down time for gentle underwater feel
    float t = time * 0.12;

    // Layer 1: large slow caustic waves
    float2 p1 = uv * 2.5 + float2(t * 0.4, t * 0.25);
    float wave1 = sin(p1.x * 2.1 + sin(p1.y * 3.3 + t)) *
                  cos(p1.y * 1.8 + sin(p1.x * 2.7 + t * 0.7));

    // Layer 2: medium caustic detail
    float2 p2 = uv * 4.0 + float2(-t * 0.3, t * 0.2);
    float wave2 = sin(p2.x * 3.2 + cos(p2.y * 2.1 + t * 1.1)) *
                  cos(p2.y * 2.9 + sin(p2.x * 1.8 - t * 0.5));

    // Layer 3: fine shimmer
    float2 p3 = uv * 7.0 + float2(t * 0.15, -t * 0.3);
    float wave3 = sin(p3.x * 1.7 + sin(p3.y * 4.1 + t * 0.8)) *
                  cos(p3.y * 3.5 + cos(p3.x * 2.3 + t * 0.4));

    // Combine layers — pronounced caustic pattern
    float caustic = wave1 * 0.5 + wave2 * 0.3 + wave3 * 0.2;

    // Strong brightness variation (±45%) for clearly visible caustics
    float brightness = 1.0 + caustic * 0.45;

    // Caustics much stronger at top (near surface), fade with depth
    float depthFade = 1.0 - uv.y * 0.65;
    brightness = mix(1.0, brightness, depthFade);

    // Apply with cyan-tinted light caustics
    return half4(
        color.r * half(brightness * 0.94),
        color.g * half(brightness * 1.10),
        color.b * half(brightness * 1.18),
        color.a
    );
}

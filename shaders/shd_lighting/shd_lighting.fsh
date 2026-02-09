//
// Lighting Shader - Fragment Shader
// Dynamic multi-light system for horror atmosphere
//

precision highp float;

varying vec2 v_vTexcoord;
varying vec4 v_vColour;
varying vec2 v_vPosition;

uniform vec2 u_resolution;              // Screen resolution
uniform float u_ambient;                // Base darkness level (0.0-1.0)
uniform float u_vignette;               // Vignette strength (0.0-1.0)

// Light arrays (max 16 lights for performance)
uniform vec2 u_light_positions[16];     // Light positions in screen space
uniform vec3 u_light_colors[16];        // Light colors (r,g,b)
uniform float u_light_radii[16];        // Light radii
uniform float u_light_intensities[16];  // Light intensities
uniform int u_num_lights;               // Actual number of active lights

void main()
{
    // Sample the original texture
    vec4 base_color = v_vColour * texture2D(gm_BaseTexture, v_vTexcoord);
    
    // Calculate pixel position in screen space
    vec2 pixel_pos = v_vPosition;
    
    // Start with ambient darkness
    float total_light = u_ambient;
    vec3 light_color_mix = vec3(u_ambient);
    
    // Accumulate light from all sources
    for (int i = 0; i < 16; i++) {
        if (i >= u_num_lights) break;
        
        // Calculate distance from pixel to light
        vec2 light_pos = u_light_positions[i];
        float dist = distance(pixel_pos, light_pos);
        
        // Get light properties
        float radius = u_light_radii[i];
        float intensity = u_light_intensities[i];
        vec3 light_color = u_light_colors[i];
        
        // Calculate light falloff (inverse square with smooth edges)
        // Normalize distance by radius
        float normalized_dist = dist / radius;
        
        // Smooth falloff using inverse square law with smoothstep
        float attenuation = 0.0;
        if (normalized_dist < 1.0) {
            // Inside light radius - smooth falloff
            attenuation = 1.0 - smoothstep(0.0, 1.0, normalized_dist);
            attenuation = pow(attenuation, 1.5); // Adjust falloff curve
        }
        
        // Apply intensity
        attenuation *= intensity;
        
        // Accumulate light
        total_light += attenuation;
        light_color_mix += light_color * attenuation;
    }
    
    // Normalize light color mix
    if (total_light > 0.0) {
        light_color_mix /= total_light;
    }
    
    // Clamp total light to avoid overexposure
    total_light = clamp(total_light, 0.0, 1.0);
    
    // Apply vignette effect for horror atmosphere
    float vignette_effect = 1.0;
    if (u_vignette > 0.0) {
        vec2 uv = v_vTexcoord - 0.5;
        float vignette_dist = length(uv);
        vignette_effect = 1.0 - (vignette_dist * u_vignette * 0.5);
        vignette_effect = clamp(vignette_effect, 0.0, 1.0);
    }
    
    // Combine lighting with vignette
    float final_brightness = total_light * vignette_effect;
    
    // Apply lighting to base color
    vec3 lit_color = base_color.rgb * light_color_mix * final_brightness;
    
    // Output final color
    gl_FragColor = vec4(lit_color, base_color.a);
}

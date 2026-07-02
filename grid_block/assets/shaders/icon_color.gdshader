shader_type canvas_item;

uniform vec4 target_color : source_color = vec4(1.0, 0.0, 0.0, 1.0);
// Threshold to handle dark gray pixels or compression artifacts
uniform float threshold : hint_range(0.0, 0.5) = 0.05;

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);
    
    // Calculate how dark the pixel is by checking the average of RGB
    float brightness = (tex_color.r + tex_color.g + tex_color.b) / 3.0;
    
    // If the pixel is below the threshold, treat it as black
    if (brightness <= threshold) {
        // Keep the original alpha, but set the color to target
        COLOR = vec4(target_color.rgb, tex_color.a);
    } else {
        // Otherwise, keep the original pixel
        COLOR = tex_color;
    }
}
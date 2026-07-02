shader_type canvas_item;

uniform vec4 glow_color : source_color = vec4(1.0, 0.5, 0.0, 1.0);
uniform float glow_strength : hint_range(0.0, 10.0) = 2.0;
uniform float border_width : hint_range(0.0, 0.1) = 0.02;

void fragment() {
    vec4 tex = texture(TEXTURE, UV);
    
    // Calculate distance to the nearest edge (0.0 at edges, 0.5 at center)
    vec2 edge_dist = min(UV, 1.0 - UV);
    float min_dist = min(edge_dist.x, edge_dist.y);
    
    // Create a mask for the border
    float border_mask = step(min_dist, border_width);
    
    // Only apply the glow if we are in the border area AND 
    // we aren't completely replacing the center
    COLOR = tex + (glow_color * glow_strength * border_mask);
}
shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform vec4 flash_color : source_color = vec4(1.0, 0.0, 0.0, 1.0);
uniform float intensity : hint_range(0.0, 1.0) = 0.5;
uniform float reach : hint_range(0.0, 1.0) = 0.5;
uniform float softness : hint_range(0.01, 1.0) = 0.5;

// Hash function to generate pseudo-random noise
float hash(vec2 p) {
    return fract(
		sin(
			dot(
				p, 
				vec2(
					12.9898, 
					78.233
				)
			)
		) * 43758.5453
	);
}

void fragment() {
    // Aspect Ratio Correction
    float aspect = SCREEN_PIXEL_SIZE.y / SCREEN_PIXEL_SIZE.x;
    vec2 uv = UV - 0.5;
    uv.y *= aspect;
    
    // Calculate Distance
    float dist = length(uv);
    float edge_start = 0.5 - (reach * 0.5);
    
    // Smooth Gradient
    float mask = smoothstep(edge_start, edge_start + softness, dist);
    
    // Dithering
    float noise = hash(FRAGCOORD.xy) * 0.02; 
    mask += noise;
    
    // Sample and Mix
    vec4 screen_col = texture(SCREEN_TEXTURE, SCREEN_UV);
    vec3 final_rgb = mix(screen_col.rgb, flash_color.rgb, mask * intensity);
    
    COLOR = vec4(final_rgb, screen_col.a);
}
shader_type spatial;
render_mode unshaded, cull_disabled, blend_mix;

uniform vec4 color_inner : source_color = vec4(1.0, 0.5, 0.0, 1.0);
uniform vec4 color_outer : source_color = vec4(1.0, 0.0, 0.0, 1.0);
uniform float radius : hint_range(0.0, 5.0) = 0.5;
uniform float animation_progress : hint_range(0.0, 1.0) = 0.0;
uniform float alpha_override : hint_range(0.0, 1.0) = 1.0; 

varying vec3 local_pos;

void vertex() {
    local_pos = VERTEX;
}

void fragment() {
    float dist = length(local_pos.xz);
    
    float edge = fwidth(dist);
    float mask = 1.0 - smoothstep(radius - edge, radius + edge, dist);
    
    float effect = sin(animation_progress * 6.28) * 0.2 + 0.8;
    vec4 final_color = mix(color_inner, color_outer, (dist / radius));
    
    ALBEDO = final_color.rgb;
    ALPHA = mask * effect * final_color.a * alpha_override;
}
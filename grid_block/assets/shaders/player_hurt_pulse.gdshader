shader_type spatial;
render_mode unshaded, cull_disabled;

uniform vec4 flash_color : source_color = vec4(1.0, 0.0, 0.0, 1.0);
uniform float flash_alpha : hint_range(0.0, 1.0) = 0.0;

void fragment() {
    ALBEDO = flash_color.rgb;
    ALPHA = flash_alpha * flash_color.a;
}
 shader_type spatial;
render_mode unshaded;

uniform vec4 base_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform vec4 grid_color : source_color = vec4(0.0, 1.0, 1.0, 1.0);

uniform float grid_scale = 10.0;
uniform float line_width = 0.05;

varying vec3 v_local_pos;
varying vec3 v_normal;

void vertex() {

    // Keeps the grid attached to the object
    v_local_pos = VERTEX;

    // local-space plane detection
    v_normal = NORMAL;

}

float get_grid(vec2 uv) {

    // fwidth on the local UVs to ensure anti-aliasing
    vec2 grid = abs(fract(uv - 0.5) - 0.5) / fwidth(uv);
    return 1.0 - min(min(grid.x, grid.y) / line_width, 1.0);
}

void fragment() {

    // Convert normal to local-space axis weights
    vec3 n = abs(v_normal);
    n /= (n.x + n.y + n.z);
	
    // Project using local position (v_local_pos)
    float grid_xz = get_grid(v_local_pos.xz * grid_scale);
    float grid_xy = get_grid(v_local_pos.xy * grid_scale);
    float grid_yz = get_grid(v_local_pos.yz * grid_scale);

    // Combine based on the normal weights
    float mask = (grid_xz * n.y) + (grid_xy * n.z) + (grid_yz * n.x);

    ALBEDO = mix(base_color.rgb, grid_color.rgb, mask);
    EMISSION = grid_color.rgb * mask;

} 
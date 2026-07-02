shader_type spatial;
render_mode unshaded, cull_disabled, depth_draw_always;

uniform vec4 base_color : source_color = vec4(0.0, 0.0, 0.0, 0.5);
uniform vec4 grid_color : source_color = vec4(0.0, 1.0, 1.0, 1.0);
uniform float grid_scale = 10.0;
uniform float line_width = 0.05;
uniform float face_alpha : hint_range(0.0, 1.0) = 0.3;

varying vec3 v_local_pos;
varying vec3 v_normal;

void vertex() {
    v_local_pos = VERTEX;
    v_normal = NORMAL;
}

float get_grid(vec2 uv) {
    vec2 grid = abs(fract(uv - 0.5) - 0.5) / fwidth(uv);
    return 1.0 - min(min(grid.x, grid.y) / line_width, 1.0);
}

void fragment() {
    // Keep the normals for orientation
    vec3 n = abs(v_normal);
    
    // Calculate grids for all three planes
    float grid_xz = get_grid(v_local_pos.xz * grid_scale);
    float grid_xy = get_grid(v_local_pos.xy * grid_scale);
    float grid_yz = get_grid(v_local_pos.yz * grid_scale);
    
    // Instead of multiplying by normalized normals (which zeros out faces), 
    // project the grid based on which plane the face is aligned with.
    // We use a step or a smooth mix to choose the best plane for the face.
    float mask = 0.0;
    if (n.y > n.x && n.y > n.z) {
        mask = grid_xz;
    } else if (n.z > n.x && n.z > n.y) {
        mask = grid_xy;
    } else {
        mask = grid_yz;
    }
    
    // Add the base_color to the output
    vec3 final_color = mix(base_color.rgb, grid_color.rgb, mask);
    
    // Calculate alpha: ensures the face is visible even where the grid is 0
    float final_alpha = max(face_alpha, mask * grid_color.a);
    
    ALBEDO = final_color;
    ALPHA = final_alpha;
    EMISSION = grid_color.rgb * mask;
}
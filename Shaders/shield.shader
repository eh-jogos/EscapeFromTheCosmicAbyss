shader_type canvas_item;

uniform float torus_thickness : hint_range(0.001, 0.1) = 0.01;
uniform float torus_radius : hint_range(-0.1, 0.5) = 0.25;
uniform vec2 torus_center = vec2(0.5, 0.5);
uniform vec2 torus_resolution = vec2(1.0, 1.0);
uniform float inner_opacity: hint_range(0.0, 1.0) = 0.25;

uniform sampler2D dissolve_texture;
uniform float burn_size : hint_range(0,2);
uniform float dissolve_amount : hint_range(0,1);
uniform float emission_amount;

uniform bool has_shield_below = false; 
uniform vec4 color_in: hint_color = vec4(1);
uniform vec4 color_out: hint_color = vec4(0,0,0,1);


// From https://thebookofshaders.com/06/
vec3 rgb2hsb(vec3 c){
    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    vec4 p = mix(vec4(c.bg, K.wz),
                vec4(c.gb, K.xy),
                step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r),
                vec4(c.r, p.yzx),
                step(p.x, c.r));
    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)),
                d / (q.x + e),
                q.x);
}

vec3 hsb2rgb(vec3 c){
    vec3 rgb = clamp(abs(mod(c.x*6.0+vec3(0.0,4.0,2.0),
                    6.0)-3.0)-1.0,
                    0.0,
                    1.0 );
    rgb = rgb*rgb*(3.0-2.0*rgb);
    return c.z * mix(vec3(1.0), rgb, c.y);
}


float get_shield_value(vec2 uv){
	float torus_distance = length((uv - torus_center) * torus_resolution);
	float radius_difference = torus_thickness / 2.0;
	float inner_radius = torus_radius - radius_difference;
	float outer_radius = torus_radius + radius_difference;
	float fill_limit = min(torus_distance, torus_radius);
	
	float inner_line = smoothstep(torus_radius, torus_distance, inner_radius );
	float outter_line = smoothstep(torus_radius, torus_distance, outer_radius );
	float fill = (smoothstep(fill_limit, torus_radius, inner_radius ) * inner_opacity);
	
	return inner_line + outter_line + fill;
}


vec3 get_emission(float sample){
	float emission_value = 1.0 - smoothstep(dissolve_amount, dissolve_amount + burn_size, sample);
	vec3 hsb_color_in = rgb2hsb(color_in.rgb);
	hsb_color_in.y = 0.4;
	vec3 burn_color = hsb2rgb(hsb_color_in);
	vec3 emission = burn_color * emission_value * emission_amount;
	return emission;
}

void fragment(){
	float circle_alpha = get_shield_value(UV);
	
	float sample = texture(dissolve_texture, UV).r;
	float alpha_value = smoothstep(dissolve_amount - burn_size, dissolve_amount, sample);
	vec3 emission = get_emission(sample);
	
	float top_circle_alpha = alpha_value * (circle_alpha);
	float bottom_circle_alpha = circle_alpha * float(has_shield_below);
	COLOR.a = max(top_circle_alpha, bottom_circle_alpha);
	
	vec3 mixed_colors = mix(color_in.rgb, color_out.rgb, 1.0 - alpha_value);
	
	vec3 emission_strip = emission * alpha_value;
//	COLOR.rgb = mixed_colors;
	COLOR.rgb = max(mixed_colors,  emission_strip);
}
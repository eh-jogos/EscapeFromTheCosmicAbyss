shader_type canvas_item;

uniform sampler2D displacement_texture;
uniform float displacement_amount;
uniform vec2 displacement_center = vec2(0.5);
uniform vec2 screen_resolution = vec2(1.0);

void fragment(){
	float mask = texture(displacement_texture, UV).r;
	vec2 direction_from_center = (UV - displacement_center) * screen_resolution;
	vec2 screen_quadrants = sign(direction_from_center);
	
	float total_displacement = mask * displacement_amount;
	vec2 displaced_uv = vec2(UV.x + total_displacement * screen_quadrants.x, UV.y + total_displacement * screen_quadrants.y);
	//vec2 displaced_uv = vec2(UV.x + total_displacement, UV.y + total_displacement);
	
	vec4 distored_color = texture(TEXTURE, displaced_uv);
	
	COLOR = distored_color;
}
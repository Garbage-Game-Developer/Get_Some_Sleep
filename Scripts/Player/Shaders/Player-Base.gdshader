shader_type canvas_item;

uniform bool left_facing = false;
uniform vec4 left_overrides[1] : source_color;
uniform vec4 left_override_colors[1] : source_color;

uniform bool has_special = false;
uniform vec4 special_hair_color : source_color = vec4(1.0);
uniform vec4 hair_color : source_color = vec4(1.0);
uniform vec4 special_eye_color : source_color = vec4(1.0);
uniform vec4 eye_color : source_color = vec4(1.0);
uniform vec4 special_outline_color : source_color = vec4(1.0);
uniform bool has_other_overrides = false;
uniform vec4 special_overrides[1] : source_color;
uniform vec4 special_override_colors[1] : source_color;

uniform bool stamina_show = false;
uniform vec4 stamina_color : source_color = vec4(1.0);
uniform float stamina_thickness : hint_range(0.0, 5.0) = 1.0;

uniform bool white_flash = false;


float is_solid(float value){
	return max(0.0, sign(value));
}

float has_solid_neighbor( sampler2D texture_sample, vec2 uv_cords, vec2 pixel_size ) {
	vec2 offset = stamina_thickness * pixel_size;
	float sum_alpha = texture(texture_sample, uv_cords + vec2(1.0, 0.0) * offset).a + 
			texture(texture_sample, uv_cords + vec2(-1.0, 0.0) * offset).a +
			texture(texture_sample, uv_cords + vec2(0.0, 1.0) * offset).a +
			texture(texture_sample, uv_cords + vec2(0.0, -1.0) * offset).a;
	return is_solid(sum_alpha);
}

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	
	if(left_facing && COLOR != vec4(0.0)){
		//bool break_out = false;
		//for(int i = 0; i < left_overrides.length(); i++){
			//COLOR = vec4;
////			break_out = COLOR == left_overrides[i]; 
////			if(break_out){ COLOR = left_override_colors[i]; break; }
		//}
	}
	
	if(stamina_show && COLOR.a == 0.0){
		float outline_mask = has_solid_neighbor( TEXTURE, UV, TEXTURE_PIXEL_SIZE );
		COLOR = (outline_mask > 0.0 ? stamina_color : COLOR);
	}
	
	if(white_flash){
		COLOR = (white_flash && COLOR.a != 0.0 ? vec4(1.0) : COLOR);
	}
	
	if(has_special){
		if(COLOR == hair_color){
			COLOR = special_hair_color;
		} else if(COLOR == eye_color) {
			COLOR = special_eye_color;
		} //else if(COLOR == vec4(0.0, 0.0, 0.0, 1.0)) {
			//COLOR = special_outline_color;
		//}
		 else if(has_other_overrides) {
			for(int i = 0; i <= special_overrides.length(); i++){
				COLOR = (COLOR == special_overrides[i] && COLOR != vec4(0.0) ? special_override_colors[i] : COLOR);
			}
		}
	}
	
}
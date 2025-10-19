shader_type canvas_item;

uniform float intensity = 1.0;
uniform float black_level = 1.0;

uniform sampler2D secondNoiseMap;
uniform sampler2D startingImage;

uniform sampler2D colorTexture;

void fragment() {
	vec4 color = vec4(0.0, 0.0, 0.0, 1.0);
	
	if(black_level > 0.0){
		float textureColor1 = texture(TEXTURE, (UV + 0.05 * (TIME/10.0))).r;
		float textureColor2 = texture(secondNoiseMap, UV - 0.05 * cos(sqrt(TIME-PI/4.0)/10.0)).r;
		float energy = textureColor1 * textureColor2;
		
		color = texture(colorTexture, vec2(energy*4.0) * 0.5 + (sin(TIME)/70.0));
		color = vec4(vec3(color.r, color.g, color.b) * intensity, color.a);
	}
	
	COLOR = vec4(color.r * black_level, color.g * black_level, color.b * black_level, color.a);
}
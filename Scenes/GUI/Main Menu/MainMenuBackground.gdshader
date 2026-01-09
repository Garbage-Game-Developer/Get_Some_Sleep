shader_type canvas_item;

uniform float intensity = 1.0;

uniform sampler2D NoiseMap1;
uniform sampler2D secondNoiseMap;
uniform sampler2D startingImage;

uniform sampler2D colorTexture;

void fragment() {
	float time = TIME / 1000.0;
	vec2 coords = vec2(UV.x + 1000.0 * sin(time / 10.0), UV.y + 1000.0 * cos(time / 10.0));
	float backTexture = 0.1 * texture(TEXTURE, coords).r;
	
	float textureColor1 = 1.0 * texture(NoiseMap1, -coords).r;
	float textureColor2 = 0.0 * (texture(secondNoiseMap, UV - 0.05 * cos(sqrt(TIME-PI/4.0)/10.0)).r);
	float energy = pow(textureColor1 + textureColor2, 2.0);
	
	vec4 color = texture(colorTexture, vec2(energy*4.0) * 0.5 + (sin(TIME)/70.0));
	color = vec4(vec3(color.r, color.g, color.b) * intensity, color.a);
		
	//COLOR = vec4(backTexture, backTexture, backTexture, 1.0) + color;
	COLOR = vec4(textureColor1, textureColor1, textureColor1, 1.0);
}
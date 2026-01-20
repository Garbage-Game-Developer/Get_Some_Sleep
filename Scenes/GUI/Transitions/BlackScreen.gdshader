shader_type canvas_item;


uniform float rightside_show = 0.0;
uniform float leftside_show = 1.0;


void fragment() {
	
	if(UV.x < rightside_show){
		COLOR = vec4(0.0);
	} else if(UV.x > leftside_show) {
		COLOR = vec4(0.0);
	}
}
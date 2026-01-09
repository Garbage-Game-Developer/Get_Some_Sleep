@tool extends Sprite2D

var offst : Vector2
var rot : float

func _process(delta):
	
	var temp : NoiseTexture2D = get_noise_param("noise1")
	#temp.noise.fractal_gain = 0.5 + 0.15 * sin(Time.get_ticks_msec() / 1000.0)
	pass


func get_noise_param(name : StringName) -> Variant:
	var temp = material as ShaderMaterial
	return temp.get_shader_parameter(name)


func set_noise_param(name : StringName, value):
	var temp = material as ShaderMaterial
	temp.set_shader_parameter(name, value)

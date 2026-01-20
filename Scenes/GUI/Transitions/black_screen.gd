extends UIObject


func set_up():
	$ColorRect.material.set_shader_parameter("rightside_show", 1.0)
	$ColorRect.material.set_shader_parameter("leftside_show", 0.0)

func transition_in():
	$AnimationPlayer.play("transition_in")

func transition_out():
	$AnimationPlayer.play("transition_out")

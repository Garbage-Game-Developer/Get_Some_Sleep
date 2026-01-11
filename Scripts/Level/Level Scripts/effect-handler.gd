class_name EffectHandler extends LevelElement



func add_effect(scene : PackedScene, pos : Vector2, rot : float = 0.0):
	var effect : Effect = scene.instantiate()
	add_child(effect)
	effect.position = pos
	effect.rotation = rot


func reset():
	for child in get_children():
		child.queue_free()


func receive_trigger(_signal_name : StringName):
	pass

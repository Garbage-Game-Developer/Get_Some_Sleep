extends LevelElement


func reset():
	for child : Trigger in get_children():
		child.reset()


func receive_trigger(_signal_name : StringName):
	pass

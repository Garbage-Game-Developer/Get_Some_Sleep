extends Room


func _ready():
	pass


func enter():
	Global.camera.set_follow_type(camera_follow, follow_value)
	pass


func get_spawn() -> SpawnPoint:
	return Spawns.get_spawn(level_handler_parent.first_room_entrance)


func exit():
	pass


func reset():
	pass


func unload():
	pass


func trigger(signal_name : StringName):
	pass
	
	"""  Check if this consumes the signal  """
	
	

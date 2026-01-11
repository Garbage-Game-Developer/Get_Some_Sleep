extends Room


func _ready():
	pass


func enter(entry_point : StringName):
	
	var temp = follow_value
	if(temp is Vector2):
		temp += global_position
	
	Global.camera.set_follow_type(camera_follow, temp)
	active_respawn_point = Spawns.get_spawn(entry_point)


func get_entry(entry_name : StringName) -> SpawnPoint:
	return Spawns.get_spawn(entry_name)


func get_spawn() -> SpawnPoint:
	active_respawn_point = Spawns.get_spawn(level_handler_parent.first_room_entrance)
	return active_respawn_point


func exit():
	pass


func reset():
	pass


func unload():
	pass


func trigger(signal_name : StringName):
	pass
	
	"""  Check if this consumes the signal  """
	
	

extends Room


func _ready():
	pass


func enter(entry_point : StringName):
	
	var temp = follow_value
	if(temp is Vector2):
		temp += global_position
	elif(temp is PackedVector2Array):
		temp = temp.duplicate()
		for i in range(temp.size()):
			temp.set(i, temp.get(i) + global_position)
	
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
	signal_name = signal_name.remove_chars(" ")
	print(signal_name)
	if(signal_name == "Respawn1"):
		active_respawn_point = get_entry("Respawn1")
	
	"""  Check if this consumes the signal  """
	
	

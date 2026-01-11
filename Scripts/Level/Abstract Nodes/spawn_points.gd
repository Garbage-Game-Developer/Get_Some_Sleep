extends LevelElement


var spawn_points : Dictionary[String, SpawnPoint]


func _ready():
	for child : SpawnPoint in get_children():
		spawn_points.get_or_add(child.spawn_id.remove_chars(" "), child)


func get_spawn(key : StringName) -> SpawnPoint:
	return spawn_points.get(key.remove_chars(" "))


func reset():
	pass


func receive_trigger(_signal_name : StringName): 
	pass

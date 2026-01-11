extends LevelElement


var spawn_points : Dictionary[StringName, SpawnPoint]


func _ready():
	for child : SpawnPoint in get_children():
		spawn_points.get_or_add(child.name, child)


func get_spawn(key : StringName) -> SpawnPoint:
	return spawn_points.get(key)


func reset():
	pass


func receive_trigger(_signal_name : StringName):
	pass

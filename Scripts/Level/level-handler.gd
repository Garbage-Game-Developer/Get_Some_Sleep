class_name LevelHandler extends Node2D


@export var player_scene : PackedScene
@export var first_room : Room
@export var first_room_entrance : StringName
var room_dictionary : Dictionary[StringName, Room]

var player : Player


func _ready():
	for room in rooms():
		room_dictionary.get_or_add(room.room_name, room)
		if(room != first_room):
			room.unload()
	Global.current_room = first_room
	set_player()


func rooms() -> Array[Room]:
	var temp : Array[Room] = []
	for child : Node in get_children():
		if child is Room:
			temp.append(child)
	return temp





func set_player():
	"""  Remember when you hit continue, we need to check where they player was and adjust for that  """
	player = player_scene.instantiate()
	$Player.add_child(player)
	player.DEBUG = false
	Global.active_player = player
	Global.current_room = first_room
	
	"""  Check for different spawn room  """
	
	var room_spawn_point : SpawnPoint = first_room.get_spawn()
	first_room.enter(room_spawn_point.spawn_id)
	##
	player.transition_in(room_spawn_point) 


func transition(transition_room : StringName, spawn_point : StringName):
	var room : Room = Global.current_room
	if(room != null):
		room.exit()
	
	room = room_dictionary.get(transition_room)
	room.enter(spawn_point)
	Global.current_room = room
	player.transition_in(room.get_entry(spawn_point))

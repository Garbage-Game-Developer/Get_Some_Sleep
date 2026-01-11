class_name GameController extends Node2D


@export var debug_level : PackedScene


func _ready():
	var temp = debug_level.instantiate()
	add_child(temp)
	#Global.connect("")


func instantiate_level():
	pass

@abstract class_name Room extends Node2D

@export var level_handler_parent : LevelHandler

@export_group("Camera Follow Type")
@export var camera_follow : Camera.type = Camera.type.FREE
@export var follow_value : Variant
@export_group("LevelElements")
@export var room_name : StringName = ""
@export var Triggers : LevelElement
@export var Spawns : LevelElement

var active_respawn_point : SpawnPoint

@abstract func enter()
@abstract func get_spawn()
@abstract func exit()
@abstract func reset()
@abstract func unload()
@abstract func trigger(signal_name : StringName)


func player_died() -> SpawnPoint:
	reset()
	return active_respawn_point

signal Triggered(name : StringName)
func trigger_signal(signal_name : StringName):
	if(signal_name == ""):
		return
	emit_signal("Triggered", signal_name)

func transition(transition_room : StringName, spawn_point : StringName):
	level_handler_parent.transition(transition_room, spawn_point)
	exit()

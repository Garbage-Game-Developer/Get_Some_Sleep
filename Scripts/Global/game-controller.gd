class_name GameController extends Node


##	Variables
# Exports
@export var world_2d : Node2D
@export var gui : Control

# Variables
var current_2d_scene
var current_gui_scene


"""-----------------------"""
"""    Godot Built-Ins    """
"""-----------------------"""


func _ready():
	Global.game_controller = self


"""-----------------"""
"""    Changeing    """
"""-----------------"""


func change_gui_scene(new_scene: String, delete: bool = true, keep_running: bool = false) -> void:
		if(current_gui_scene != null):
			if(delete):
				current_gui_scene.queue_free()
			elif(keep_running):
				current_gui_scene.visible = false
			else:
				gui.remove_child(current_gui_scene)
		if(gui.find_child(new_scene) != null):
			current_gui_scene = gui.find_child(new_scene)
		else:
			var new = load(new_scene).instantiate()
			gui.add_child(new)
			current_gui_scene = new



func change_2d_scene(new_scene: String, delete: bool = true, keep_running: bool = false) -> void:
		if(current_2d_scene != null):
			if(delete):
				current_2d_scene.queue_free()
			elif(keep_running):
				current_2d_scene.visible = false
			else:
				world_2d.remove_child(current_2d_scene)
		if(world_2d.find_child(new_scene) != null):
			current_2d_scene = world_2d.find_child(new_scene)
		else:
			var new = load(new_scene).instantiate()
			world_2d.add_child(new)
			current_2d_scene = new

"""
	
	Thank you 'StayAtHomeDev' for this
	
"""

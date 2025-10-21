class_name Camera extends Node2D

"""
Simple script so the camera sets itself to the global camera, and then follows the global camera node


"""


func _ready():
	Global.camera = self


func _process(delta):
	if(Global.camera_lock != null):
		position = Global.camera_lock.global_position + Vector2(0.0,-100.0)

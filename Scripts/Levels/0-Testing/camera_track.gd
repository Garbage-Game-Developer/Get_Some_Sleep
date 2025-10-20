extends Node2D


func _ready():
	Global.camera_lock = $CameraPosition


func _process(delta):
	##	In an actual level, will use min and max stuff to keep it in bounds
	if(Global.player != null):
		$CameraPosition.position = Global.player.position

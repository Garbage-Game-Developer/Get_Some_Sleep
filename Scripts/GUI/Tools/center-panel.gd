@tool class_name CenterPanel extends Control


@export var child_panel : Panel
@export var center_horizontal : bool = true
@export var center_vertical : bool = true


func _process(delta):
	custom_minimum_size = Vector2.ZERO
	size = Vector2.ZERO
	if(center_horizontal && child_panel != null):
		child_panel.position.x = -child_panel.size.x/2.0
	if(center_vertical && child_panel != null):
		child_panel.position.y = -child_panel.size.y/2.0

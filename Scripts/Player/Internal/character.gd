@tool 
extends Node2D

##	Tool stuff (Could be used for cutescenes aswell)
@export_enum("Left:0", "Right:1") var left_or_right : int = 1
var left_or_right_changed : int = 0  ##  Set to the most previous left_or_right value for checking against current
@export_enum("Current:0", "Idle:1", "Walk:2") var animation : int = 0
var current_animation : int = 1  ##  0-default, 1-idle, 2-walk, 3-run
@export var reset_idle : bool = false


""" Internal Functions """

##	This sets the variable
var anim_name_start : String = "R_"
func _process(_delta):
	if(left_or_right_changed != left_or_right):
		anim_name_start = ("R_" if left_or_right == 1 else "L_")
		play_animation()
		left_or_right_changed = left_or_right
	if(animation != 0):
		current_animation = animation
		animation = 0
		play_animation()
	if(reset_idle):
		animation = 0
		current_animation = 1
		left_or_right = 1
		left_or_right_changed = 1
		anim_name_start = "R_"
		play_animation()
		reset_idle = false


func play_animation():
	match current_animation:
		1:
			$Legs.play(anim_name_start + "Idle")
			$Torso.play(anim_name_start + "Idle")
		2:
			$Legs.play(anim_name_start + "Walk")
			$Torso.play(anim_name_start + "Walk")
		3:
			$Legs.play(anim_name_start + "Walk")
			$Torso.play(anim_name_start + "Walk")


""" Externally Called Functions """

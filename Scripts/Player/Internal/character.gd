@tool 
extends Node2D

##	Tool stuff (Could be used for cutescenes aswell)
@export_enum("Left:0", "Right:1") var left_or_right : int = 1
var left_or_right_changed : int = 0  ##  Set to the most previous left_or_right value for checking against current
@export_enum(
	"Current:0", 
	"Idle:1", 
	"Run:2", 
	"Jump:3",
	"Fall:4",
	"Wall:5",
	"Slide:6",
) var animation : int = 0
var current_animation : int = 1  ##  1-idle, 2-walk, 3-run
@export var reset_idle : bool = false


""" Internal Functions """

##	This sets the variable
func _process(_delta):
	if(reset_idle):
		reset_idle = false
		animation = 0
		
		left_or_right = 1
		change_direction(true if left_or_right == 1 else false)
		current_animation = 1
		play_animation()
	else:
		if(left_or_right != left_or_right_changed):
			change_direction(true if left_or_right == 1 else false)
		if(animation != 0):
			current_animation = animation
			play_animation()
			animation = 0
	left_or_right_changed = left_or_right


##	true - right  |  false - left
func change_direction(direction : bool):
	$Right.visible = direction
	$Left.visible = !direction


func play_animation():
	var animation : String = "Idle"
	match current_animation:
		1:
			animation = "Idle"
		2:
			animation = "Run"
		3:
			animation = "Jump"
		4:
			animation = "Fall"
		5:
			animation = "Wall"
		6:
			animation = "Slide"
	$Right.play(animation)
	$Left.play(animation)

""" Externally Called Functions """

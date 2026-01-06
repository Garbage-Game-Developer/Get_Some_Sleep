@tool 
class_name SpriteHandler extends Node2D

##	Tool stuff (Could be used for cutescenes aswell)
@export_enum("Left:0", "Right:1") var left_or_right : int = 1
var left_or_right_changed : int = 0  ##  Set to the most previous left_or_right value for checking against current
enum {
	NONE,
	IDLE, 
		##	Can put other idle animations here
	RUN, 
	JUMP,
		JUMP_MOVING,
		JUMP_WALL,
	FALL,
		FALL_MOVING,
	WALL,
	SLIDE,
}
@export var animation : int = 0
var current_animation : int = IDLE
@export var reset_idle : bool = false



""" Internal Functions """

##	This sets the variable
func _process(_delta):
	if Engine.is_editor_hint():
		
		if(reset_idle):
			reset_idle = false
			left_or_right = 1
			change_direction(true if left_or_right == 1 else false)
			animation = IDLE
			play_animation()
		
		else:
			if(left_or_right != left_or_right_changed):
				change_direction(true if left_or_right == 1 else false)
			
			if(animation != current_animation):
				current_animation = animation
				play_animation()
		
		current_animation = 1
		left_or_right_changed = left_or_right
		
	else:
		animation = current_animation


##	true - right  |  false - left
func change_direction(direction : bool):
	$Right.visible = direction
	$Left.visible = !direction


var last_animation : int = IDLE
func play_animation():
	var anim : String = "Idle"
	var set_frame : int = 0
	match current_animation:
		IDLE:
			anim = "Idle"
		
		RUN:
			anim = "Run"
		
		JUMP:
			anim = "Jump"
		JUMP_MOVING:
			anim = "JumpMoving"
		JUMP_WALL:
			anim = "JumpWall"
		
		FALL:
			anim = "Fall"
		FALL_MOVING:
			anim = "FallInto"
		
			##	For into fall animations, need to set them to the proper frame of the other when swapping between moving and not moving
		
		WALL:
			anim = "Wall"
		
		SLIDE:
			anim = "Slide"
	
	var frame_progress : float = 0.0
	if(set_frame != 0):
		frame_progress = $Right.frame_progress
	
	$Right.play(anim)
	$Right.set_frame_and_progress(set_frame, frame_progress)
	$Left.play(anim)
	$Left.set_frame_and_progress(set_frame, frame_progress)
	last_animation = current_animation



func _on_right_animation_finished():
	
	var anim : String = $Right.animation
	match anim:
		"FallMovingInto":
			$Right.play("FallMoving")
			$Left.play("FallMoving")
		"JumpMoving":
			



""" Externally Called Functions """

func play(anim : int):
	if(anim == current_animation || anim == NONE):
		return
	else:
		current_animation = anim
	play_animation()


func change_facing(right : bool):
	change_direction(right)

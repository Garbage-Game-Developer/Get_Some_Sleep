@tool 
class_name SpriteHandler extends Node2D

##	Tool stuff (Could be used for cutescenes aswell)
@export_enum("Left:-1", "Right:1") var left_or_right : int = 1
var left_or_right_changed : int = 0  ##  Set to the most previous left_or_right value for checking against current
enum {
	NONE = 0,
	
	IDLE = 1, 
		##	Can put other idle animations here
	RUN = 2, 
	
	JUMP = 3,
		JUMP_MOVING = 301,
		JUMP_WALL = 302,
		JUMP_WALL_UP = 303,
	
	FLOATING_UP = 4,
		FLOATING_UP_MOVING = 401,
	
	FLOATING_DOWN = 5,
		FLOATING_DOWN_MOVING = 501,
	
	FALL = 6,
		FALL_MOVING = 601,
	
	WALL = 7,
		WALL_CLIMB_UP = 701,
		WALL_CLIMB_DOWN = 702,
		INTO_WALL = 703,  ##  Not implemented
		WALL_SLIDING = 704,
		WALL_PUNCHING = 705,  ##  Not implemented
	
	SLIDE = 8,
}
@export_enum(
	"NONE:0",
	
	"IDLE:1", 
		##	Can put other idle animations here
	"RUN:2", 
	
	"JUMP:3",
		"JUMP_MOVING:301",
		"JUMP_WALL:302",
		"JUMP_WALL_UP:303",
	
	"FLOATING_UP:4",
		"FLOATING_UP_MOVING:401",
	
	"FLOATING_DOWN:5",
		"FLOATING_DOWN_MOVING:501",
	
	"FALL:6",
		"FALL_MOVING:601",
	
	"WALL:7",
		"WALL_CLIMB_UP:701",
		"WALL_CLIMB_DOWN:702",
		"INTO_WALL:703",
		"WALL_SLIDING:704",
		"WALL_PUNCHING:705",
	
	"SLIDE:8",
) var animation : int = IDLE
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
				play_animation()
		
		left_or_right_changed = left_or_right
		
	else:
		animation = current_animation


##	true - right  |  false - left
func change_direction(direction : bool):
	$Right.visible = direction
	$Left.visible = !direction
	left_or_right = 1 if direction else -1


var current_wall_index : int = 0
var wall_queued : bool = false


var last_animation : int = IDLE
func play_animation():
	var anim : String = "Idle"
	var set_frame : int = 0
	var no_change : bool = false
	match animation:
		IDLE:
			anim = "Idle"
		
		RUN:
			anim = "Run"
		
		JUMP:
			anim = "Jump"
		JUMP_MOVING:
			anim = "JumpMoving"
		JUMP_WALL:
			if(current_animation == WALL_SLIDING):
				anim = "JumpWallSliding"
			else:
				anim = "JumpWall"
		JUMP_WALL_UP:
			if(current_animation == WALL_SLIDING):
				anim = "JumpWallSliding"
			else:
				anim = "JumpWallUp"
		
		FLOATING_UP:
			anim = "FloatUp"
		FLOATING_UP_MOVING:
			anim = "FloatUpMoving"
	
		FLOATING_DOWN:
			anim = "FloatDown"
		FLOATING_DOWN_MOVING:
			anim = "FloatDownMoving"
		
		FALL:
			anim = "Fall"
		FALL_MOVING:
			anim = "FallMovingInto" if last_animation == FALL else "FallMoving"
		
			##	For into fall animations, need to set them to the proper frame of the other when swapping between moving and not moving
		
		WALL:
			print(animation, " ", current_animation)
			if((current_animation == WALL_CLIMB_UP || current_animation == WALL_CLIMB_DOWN)):
				wall_queued = true
				no_change = true
			elif(current_animation == WALL_SLIDING):
				anim = "WallSlideBack"
				if($Right.animation == "WallIntoSlide"):
					set_frame = 1 - $Right.frame
			else:
				anim = "Wall" + str(current_wall_index % 2 + 1)
		WALL_CLIMB_UP:
			if(current_animation == WALL_CLIMB_DOWN):
				wall_queued = true
			else:
				anim = "WallClimbUp" + str(current_wall_index % 2 + 1)
		WALL_CLIMB_DOWN:
			if(current_animation == WALL_CLIMB_UP):
				wall_queued = true
			else:
				anim = "WallClimbDown" + str(current_wall_index % 2 + 1)
		WALL_SLIDING:
			if(current_animation == WALL || current_animation == WALL_CLIMB_UP || current_animation == WALL_CLIMB_DOWN):
				anim = "WallIntoSlide"
				if($Right.animation == "WallSlideBack"):
					set_frame = 1 - $Right.frame
			else:
				anim = "WallSlide"
		
		SLIDE:
			pass
	
	if(!no_change):
		var frame_progress : float = 0.0
		if(set_frame != 0):
			frame_progress = $Right.frame_progress
		
		$Right.play(anim)
		$Right.set_frame_and_progress(set_frame, frame_progress)
		$Left.play(anim)
		$Left.set_frame_and_progress(set_frame, frame_progress)
	last_animation = current_animation
	current_animation = animation



func _on_right_animation_finished():
	
	var anim : String = $Right.animation
	match anim:
		"FallMovingInto":
			$Right.play("FallMoving")
			$Left.play("FallMoving")
		"JumpWallSliding":
			current_animation = JUMP_MOVING
			$Right.play("JumpMoving")
			$Left.play("JumpMoving")
		"JumpWall":
			current_animation = JUMP_MOVING
			$Right.play("JumpMoving")
			$Left.play("JumpMoving")
		"JumpWallUp":
			if(queued_turn):
				change_facing(queued_direction)
			print("why???")
			animation = JUMP
			play_animation()
		"WallClimbUp1":
			current_wall_index = 1
			if(wall_queued):
				wall_queued = false
				play_animation()
			else:
				$Right.play("WallClimbUp2")
				$Left.play("WallClimbUp2")
		"WallClimbUp2":
			current_wall_index = 0
			if(wall_queued):
				wall_queued = false
				play_animation()
			else:
				$Right.play("WallClimbUp1")
				$Left.play("WallClimbUp1")
		"WallClimbDown1":
			current_wall_index = 1
			if(wall_queued):
				wall_queued = false
				animation = WALL
				play_animation()
			else:
				$Right.play("WallClimbDown2")
				$Left.play("WallClimbDown2")
		"WallClimbDown2":
			current_wall_index = 0
			if(wall_queued):
				wall_queued = false
				animation = WALL
				play_animation()
			else:
				$Right.play("WallClimbDown1")
				$Left.play("WallClimbDown1")
		"WallSlideBack":
			current_wall_index = 0
			$Right.play("Wall" + str(current_wall_index % 2 + 1))
			$Left.play("Wall" + str(current_wall_index % 2 + 1))
		"WallIntoSlide":
			$Right.play("WallSlide")
			$Left.play("WallSlide")
		"JumpWallUp":
			$Right.play("Jump")
			$Left.play("Jump")
	
	wall_queued = false
	animation = current_animation



""" Externally Called Functions """

func play(anim : int):
	if(anim == current_animation || anim == NONE):
		return
	else:
		animation = anim
	play_animation()


var queued_turn : bool = false
var queued_direction : bool = false
func change_facing(right : bool):
	if($Right.animation == "JumpWallUp"):
		queued_turn = true
		queued_direction = right
		return
	change_direction(right)

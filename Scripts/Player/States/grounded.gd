class_name GroundedState extends Node

""" 
Description
	This state is for when the player is in contact with the ground and not sliding
	The main not action animation for this state is idle, for when x velocity is zero

This state considers movenment

Actions available
- Jump			Gives upward velocity, and leaves the ground
- Dash			Gives a large ammount of horizontal velocity
- Slide			Starts sliding, can jump out of sliding, and can't really slide in low velocity since it has a cutoff point 
- (Punch)		A sub action that can be used while running and walking that has the player punch in the direction they are facing
- (Interact)	A sub action that can be used while running or walking that has the player simply interact with an interactable object
"""


""" Exports """
@onready var P : Player = $"../.."


func update(delta : float, new_state : bool = false):
	
	""" Actions Available """
	
	var new_action = false
	
	P.velocity += left_right_priority(Input.is_action_pressed("LEFT"), Input.is_action_pressed("RIGHT")) * P.BASE_SPEED * P.speed_boost * delta
	
	
	if(!P.dashing):
		##	Check for ground type
		P.velocity.x = maxf(P.velocity.x, P.SURFACE_MAX_SPEED * P.speed_boost)
	
	
	""" Animations to Play """
	
	pass
	
	""" Physics """
	if(!P.dashing):
		P.velocity -= P.BASE_GRAVITY * delta


var left_hold : bool = false  ##  LEFT been pressed for longer than a frame
var right_hold : bool = false  ##  RIGHT been pressed for longer than a frame
var left_or_right : bool = false  ## false for left, true for right
func left_right_priority(left_pressed : bool, right_pressed : bool) -> Vector2:
	if(!left_pressed):
		left_hold = false
		
		if(right_pressed):
			pass
	
	
	
	return Vector2.ZERO

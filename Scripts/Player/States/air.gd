class_name AirState extends Node

""" 
Description
	This state is for when the player is not touching a wall, floor, or water, and is also not currently kicking or sliding
	The main non action animations are falling, which is swapped to when y velocity reaches below 0 and no other action animation is taking priority

This state considers movenment

Actions available
- Double Jump	(Gives another, slightly less powerful mid air jump, which is only slightly affected by downward acceleration)
- Dash			(Reduces horizontal acceleration and gives a lot of horizontal acceleration)
- Down Kick		(Starts an angled dive downward with feet first)
- Swing			(If nearby thing to swing with, will snap to position and start swinging based on direction and speed of character when starting the swing)
- Slide			(Slight boost forward at no additional cost, putting the character straight into a sliding animation)
- (Punch)		A sub action that can be used while not in an action priority animation that has the player punch in the direction they are facing
"""


""" Exports """
@onready var P : Player = $"../.."


func update(delta : float, new_state : bool = false):
	
	""" Actions Available """
	
	var new_action = false
	
	P.velocity += left_right_priority(Input.is_action_pressed("LEFT"), Input.is_action_pressed("RIGHT")) * P.AIR_SPEED * P.speed_boost * delta
	
	
	if(!P.dashing):
		##	Check for ground type
		P.velocity.x = maxf(P.velocity.x, P.AIR_MAX_SPEED * P.speed_boost)
	
	
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

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
	
	##	LEFT and RIGHT movenment
	var velocity = left_right_priority(Input.is_action_pressed("LEFT"), Input.is_action_pressed("RIGHT")) * P.GROUND_SPEED * P.speed_boost * delta
	P.velocity += velocity
	
	
	if(!P.dashing):
		
		##	Check for ground type instead of just using normal surface  *sigh*
		if(P.velocity.x != 0):
			var direction = (P.velocity.x/abs(P.velocity.x))
			P.velocity.x = direction * minf(abs(P.velocity.x), P.SURFACE_MAX_SPEED)
			if(abs(P.velocity.x) < 10.0 && velocity.x == 0.0):
				P.velocity.x = 0.0
			else:
				P.velocity.x = lerp(P.velocity.x, 0.0 * direction, (0.03 if velocity.x == 0.0 else 0.01))
			
		if(Input.is_action_just_pressed("JUMP")):
			P.velocity.y += P.JUMP_FORCE
			new_action = true
		
		if(Input.is_action_just_pressed("DASH")):
			pass
		
		if(Input.is_action_just_pressed("SLIDE")):
			pass
		
		if(Input.is_action_just_pressed("ATTACK")):
			pass
		
		##	calls the interaction function in the player parant class
		if(Input.is_action_just_pressed("INTERACT")):
			pass
	
	
	""" Animations to Play """
	
	if(!new_action):
		
		if(just_switched_directions):
			$"../../C".left_or_right = (1 if P.left_or_right else 0)
		
		##	Check if not dashing before checking if velocity.y < 0, and then setting animation to falling
		
		"""
			Need a more advanced system for detecting if an animation is finished, so swapping between left and right doesn't re do 
			the animation, and just skips to the end frame (Only for one shot animations)
			
			Could have a left and right sprite that show and hide based on left or right to ensure animation is always in sync, and 
			it doesn't need to restart (probably the easiest and best solution for non mirrorable sprites)
			
			Alternativly, I could take the texture overlay approach of just having a model sprite, and then have shaders check from
			the texture node and place the coresponding pixels where they need to be. (Much more complex, but doesn't need 2 sprite 
			sets to work)
			
			Also, could have shaders detect weather or not the leg sprite has gone up a pixel, and move the sprite up respectivly in
			the shader (I really like this solution ngl)
		"""
		pass
	
	""" Physics """
	if(!P.dashing):
		pass  ##  idk what to do here that hasn't been done ngl


var just_switched_directions : bool = false
var left_hold : bool = false  ##  LEFT been pressed for longer than a frame
var right_hold : bool = false  ##  RIGHT been pressed for longer than a frame
#var left_or_right : bool = false  ## false for left, true for right   [moved to global]
func left_right_priority(left_pressed : bool, right_pressed : bool) -> Vector2:
	just_switched_directions = true
	if(right_pressed):
		if(!left_pressed):  ##  RIGHT is the 'only' button pressed
			just_switched_directions = !P.left_or_right  ##  if was left, switch directions
			left_hold = false
			P.left_or_right = true
			right_hold = true
			return Vector2.RIGHT
		else:
			if(!right_hold):  ##  RIGHT was 'just' pressed and LEFT is down
				just_switched_directions = !P.left_or_right  ##  if was left, switch directions
				P.left_or_right = true
				right_hold = true
				return Vector2.RIGHT
			else:
				if(!left_hold):  ##  LEFT was 'just' pressed and RIGHT is down
					just_switched_directions = P.left_or_right  ##  if was right, switch directions
					P.left_or_right = false
					left_hold = true
					return Vector2.LEFT
				if(P.left_or_right):  ##  RIGHT was 'most recently' pressed and LEFT is down
					return Vector2.RIGHT
	if(left_pressed):  ##  LEFT is the 'only' button pressed, 'or' LEFT was 'most recently' pressed and RIGHT is down
		just_switched_directions = P.left_or_right  ##  if was right, switch directions
		right_hold = right_pressed
		P.left_or_right = false
		left_hold = true
		return Vector2.LEFT
	
	left_hold = false
	right_hold = false
	return Vector2.ZERO

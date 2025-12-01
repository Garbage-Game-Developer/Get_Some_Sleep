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


"""  Don't forget about interferience and how it affects decelleration in air """


func new_state(delta : float):
	"""
		This will only be used if I decide every state should check if the state has changed
	"""
	update(delta)


func update(delta : float, new_state : bool = false):
	
	""" Actions Available """
	var new_action = false
	
	P.velocity += P.move_vector * P.AIR_SPEED * P.speed_boost * delta
	
	if(!P.dashing):
		##	Check for ground type
		
		##	This does not account for negative values, and therfore will not work properly
		P.velocity.x = minf(P.velocity.x, P.AIR_MAX_SPEED * P.speed_boost)
	
	""" Animations to Play """
	
	if(!new_action):
		
		#if(just_switched_directions):
		#	$"../../C".left_or_right = (1 if P.left_or_right else 0)
		
		##	Check if not dashing before checking if velocity.y < 0, and then setting animation to falling
		
		
		##	
		
		
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
		P.velocity -= P.BASE_GRAVITY * delta

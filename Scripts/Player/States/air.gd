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
@onready var player_base : Player = $"../.."


func update(delta : float, new_state : bool):
	
	""" Actions Available """
	
	
	
	""" Animations to Play """
	
	pass
	
	""" Physics """

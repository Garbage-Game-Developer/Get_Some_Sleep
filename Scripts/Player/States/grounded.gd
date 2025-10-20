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


func update(delta : float, new_state : bool):
	
	""" Actions Available """
	
	
	
	""" Animations to Play """
	
	pass
	
	""" Physics """

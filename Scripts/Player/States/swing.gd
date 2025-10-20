class_name SwingState extends Node

""" 
Description
	This state is for when the player is swinging on an object (this is the most complex mechanic to code)
	The main non action animations in swinging back and forth depending on velocity

	Need to consider animations and swinging for when the swinging object is moving (Lag and stuff)

This state considers movenment as a sort of rotationary swinging, but there's exceptions to this, idk

Actions available
- Release	Release with the velocity that you're swinging in (Jump)
- Drop		Release with the parallel velocity (Slide)

"""


""" Exports """
@onready var P : Player = $"../.."


func update(delta : float, new_state : bool):
	
	""" Actions Available """
	
	
	
	""" Animations to Play """
	
	pass
	
	""" Physics """

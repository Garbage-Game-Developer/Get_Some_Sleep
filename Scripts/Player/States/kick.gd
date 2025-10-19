class_name KickState extends Node

""" 
Description
	This state is for when the player has decided to kick mid air
	No animation to switch to at any point unless leaving this state

This state considers movenment (But very slightly, like 0.25 * air speed)

Actions available
- Double Jump	Would cause a less powerful double jump
- Dash			Would cause a less powerful air dash
- Slide			Would have you locked into the sliding state in air
    If made contact (Give a few pause frames on contact to allow for this)
- Dash			Would cause a less powerful air dash with a little bit of upward velocity proportional to a fraction of downward velocity
else : Jump		Would cause a double jump proportional to a fraction of downward velocity and restore special charge

"""


""" Exports """
@onready var player_base : Player = $"../.."


func update(delta : float, new_state : bool):
	
	""" Actions Available """
	
	
	
	""" Animations to Play """
	
	pass
	
	""" Physics """

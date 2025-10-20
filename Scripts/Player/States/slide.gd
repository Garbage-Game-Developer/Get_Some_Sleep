class_name SlideState extends Node

""" 
Description
	This state is for when the player starts sliding (in air or on ground)

This state considers movenment (But a lot less, like 0.3 * movenment speed)

Actions available (When time up)
	Ground
- Jump			Normal jump out of slide with a little more forward velocity
- Dash			Normal ground dash out of slide state
	Air
- Double Jump	Normal double jump out of slide state
- Dash			Normal air dash out of slide state
- Kick			Normal kick out of slide state
- Swing			Normal Swing out of slide state

Little note: if you come in contact with a bounch pad, and it launches in the opposite x direction, you will get kicked out of slide and into air
But you will keep slide state if you come in contact with one on the ground and it launches you up with no change in x direction
"""


""" Exports """
@onready var P : Player = $"../.."


func update(delta : float, new_state : bool):
	
	""" Actions Available """
	
	
	
	""" Animations to Play """
	
	pass
	
	""" Physics """

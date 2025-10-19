class_name SwimState extends Node

""" 
Description
	This state is for when the player is in wate, and it will not apply gravity, but has constant friction on all movenment vectors
	The main non action animations in place swimming on surface or under

This state considers movenment (As swim speed)

Actions available (When time up)
	Surface
- Dive		Quickly apply downward velocitity on player
- Dash		Dash with half air dash speed in any non up direction, no charge consumed
- Jump Out	Jump out force as a jump out of the water
	Under
- Dash		Dash in any direction at half air dash speed, eccentially a faster swim with some recovery, no charge consumed
- Up		Quickly swim straight up, faster than normal swim speed
"""


""" Exports """
@onready var player_base : Player = $"../.."


func update(delta : float, new_state : bool):
	
	""" Actions Available """
	
	
	
	""" Animations to Play """
	
	pass
	
	""" Physics """

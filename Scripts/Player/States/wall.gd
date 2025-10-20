class_name WallState extends Node

""" 
Description
	This state is for when the player is touching a wall and not the floor, if entering at a high enough position, you'll ledge grab

This state does NOT considers movenment (Just considers lower and climb)

Actions available
Ledge Grab
- Jump		Double jump in the opposite direction off the wall with no charge, or in the direction of the wall if holding towards the wall when doing it
- Dash		Air dash straight off the wall with no charge
- Lower		Holding down with able advanced climb to go upward on the wall (Need animation for advanced climb, and swap to wall climb instead of ledge grab)
- Release	press slide while on the wall to fully drop, or do it while holding the opposite direction to get a little bit of opposite velocity
Wall Climb
- Jump		Double jump in the opposite direction off the wall with no charge
- Dash		Air dash straight off the wall with no charge
- Climb		Holding up with able advanced climb to go upward on the wall (Need animation for advanced climb)
- Lower		Holding down with able advanced climb to go upward on the wall (Need animation for advanced climb)
- Release	press slide while on the wall to fully drop, or do it while holding the opposite direction to get a little bit of opposite velocity
"""


""" Exports """
@onready var P : Player = $"../.."


func update(delta : float, new_state : bool):
	
	""" Actions Available """
	
	
	
	""" Animations to Play """
	
	pass
	
	""" Physics """

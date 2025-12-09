@abstract
class_name State extends Node

enum s {
	AIR = 0, 
	DASH = 1, 
	DAZED = 2, 
	FLOATING = 3, 
	FROZEN = 4, 
	GHOST = 5, 
	GROUNDED = 6, 
	KICK = 7, 
	SLIDE = 8, 
	SWIM = 9, 
	SWING = 10, 
	WALL = 11, 
	DEAD = -1, 
	CUTSCENE = -2, 
	PAUSE = -3 
}

@abstract func new_state(delta : float, change_state : State.s, movenment_package : Array[float])
@abstract func update(delta : float)
@abstract func generate_movenment_package() -> Array  ##  [movenment_curve_max_frame <= movenment_curve_frame, starting_velocity]

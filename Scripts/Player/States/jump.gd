class_name JumpState extends Node

""" 
Description
	This normal state is for when the player is not in contact with the ground, a wall, or water

This state considers horizontal movenment, and uses a complex movenment curve
This state does not consider vertical movenment

Actions available
o Jump			Swap to the "Jump" state, from_ground = false
o Dash			Swap to the "Dash" state, from_ground = false
- Slide			Swap to the "Slide" state, from_ground = false
o Kick			Swap to the "Kick" state, 
o (Punch)		Sub action that calls the parent's Punch function, and plays an animation
"""


""" Externals """
@onready var P : Player = $"../.."
@onready var Animation_Controller : Node2D = $"../../C"


""" Constants """
##	These need to be the same for Air and Jump
@export var AIR_MAX_X_SPEED : float = 250.0		##	Maximum speed (px * s) the player can move in the air
@export var AIR_MAX_ACC_TIME : int = 12			##	Ammount of time (frames/60) it takes for the player to accelerate to maximum speed
@export var AIR_MAX_DEC_TIME : int = 06			##	Ammount of time (frames/60) it takes for the player to decelerate to 0 px*s
@export var AIR_MAX_OVER_DEC_TIME : int = 06	##	Ammount of time (frames/60) it takes for the player to decelerate to AIR_MAX_SPEED px*s from AIR_MAX_SPEED * 2 px*s

@export var GROUND_INITIAL_VELOCITY : float = 500.0		##	Maximum speed (px * s) the player can move in the air
@export var GROUND_DECELERATION_TIME : int = 12			##	Ammount of time (frames/60) it takes for the player to go from full jump to 0

@export var DOUBLE_INITIAL_VELOCITY : float = 500.0		##	Maximum speed (px * s) the player can move in the air
@export var DOUBLE_DECELERATION_TIME : int = 12			##	Ammount of time (frames/60) it takes for the player to go from full jump to 0

""" Internals """
var ACTIVE_STATE : bool = false

var movenment_curve_frame : float = 0
var movenment_curve_max_frame : float = 0
var last_velocity : Vector2 = Vector2.ZERO
var velocity : Vector2 = Vector2.ZERO

var ground_jump : bool = false


""" DEBUG """
var time : String


func new_state(delta : float, from_ground : bool):
	
	##	Run set up code for animations and such
	ACTIVE_STATE = true
	velocity = P.velocity / Global.time_speed
	#gen_movenment_curve(1.0 if (P.move_vector.x == 0.0 && velocity.x < 0.0) || P.move_vector.x > 0.0 else -1.0)
	ground_jump = from_ground
	update(delta)


func update(delta : float):
	
	time = "%9.3f" % (float(Time.get_ticks_msec()) / 1000.0)
	
	""" States (Pre Change) """
	var state_change_to : Player.State = Player.State.GROUNDED
	
	if(P.is_on_floor()):
		state_change_to = Player.State.GROUNDED
	elif(P.is_on_wall_only() && true):  ##  find if also holding direction
		state_change_to = Player.State.WALL
	elif(!Input.is_action_pressed("JUMP")):
		state_change_to = Player.State.AIR
	
	""" Actions """
	var new_action = false
	var action_is_punch = false
	if(Input.is_action_just_pressed("DASH") && $"../../Timers/DashFloorCooldown".is_stopped()):
		""" Default Key : "Shift"
			Swap to the "Dash" state, from_ground = false   """
		
		if(state_change_to == Player.State.AIR && (P.advanced_movenment || P.special_dash)):
			state_change_to = Player.State.DASH
			$"../../Timers/DashFloorCooldown".start()
			
		elif(state_change_to != Player.State.AIR):
			state_change_to = Player.State.DASH
			$"../../Timers/DashFloorCooldown".start()
	
	
	elif(Input.is_action_just_pressed("SLIDE")):
		""" Default Key : "C"
			Swap to the "Slide" state, from_ground = false   """
		
		state_change_to = Player.State.SLIDE
	
	
	elif(Input.is_action_just_pressed("JUMP")):
		""" Default Key : "Space"
			Swap to the "Jump" state, from_ground = false   """
		
		state_change_to = Player.State.JUMP
	
	
	else:
		if(Input.is_action_just_pressed("ATTACK")):
			""" Default Keys : "F", "V", "Right Mouse Button"
				Sub action that calls the parent's Punch function, and plays an animation   """
			
			##	There might be some weapon thing at some point where you can aim a weapon or orb for a boss fight / other mechanic thing
			#P.Punch()
			new_action = true
			action_is_punch = true
	
	
	""" States (Post Change)"""
	if(state_change_to != Player.State.GROUNDED):
		#ACTIVE_STATE = false
		match state_change_to:
			Player.State.AIR:
				#P.current_state = Player.State.AIR
				#P.Air.new_state(delta)
				pass
			Player.State.DASH:
				#P.current_state = Player.State.DASH
				#P.Dash.new_state(delta)
				pass
			Player.State.JUMP:
				#P.current_state = Player.State.JUMP
				#P.Jump.new_state(delta)
				pass
			Player.State.SLIDE:
				#P.current_state = Player.State.SLIDE
				#P.Slide.new_state(delta)
				pass
			Player.State.SWIM:
				#P.current_state = Player.State.SWIM
				#P.Swim.new_state(delta)
				pass
			Player.State.SWING:
				#P.current_state = Player.State.SWING
				#P.Swing.new_state(delta)
				pass
			Player.State.WALL:
				#P.current_state = Player.State.WALL
				#P.Wall.new_state(delta)
				pass
		return
	
	
	""" Movenement Vector """
	var move_vector = P.move_vector
	
	if(P.just_switched_directions || new_surface):
		P.interference = false
		movenment_curve_frame = 0
		gen_movenment_curve(move_vector.x)
	movenment_curve_frame = minf(movenment_curve_frame + 1.0 * P.speed_boost, movenment_curve_max_frame)
	velocity.x = velocity_on_curve(movenment_curve_frame)
	
	#print(time, " DEBUG velocity : V=%8.3f" % velocity.x)
	
	
	""" Animations to Play """
	if(!new_action):
		
		if(P.just_switched_directions):
			Animation_Controller.left_or_right = (1 if P.left_or_right else 0)
		
		pass
		
		##	Check if not dashing before checking if velocity.y < 0, and then setting animation to falling
		
		"""
			Need a more advanced system for detecting if an animation is finished, so swapping between left and right doesn't re do 
			the animation, and just skips to the end frame (Only for one shot animations)
			
			Could have a left and right sprite that show and hide based on left or right to ensure animation is always in sync, and 
			it doesn't need to restart (probably the easiest and best solution for non mirrorable sprites)
			
			Also, could have shaders detect weather or not the leg sprite has gone up a pixel, and move the sprite up respectivly in
			the shader (I really like this solution ngl)
		"""
		pass
	
	
	""" Physics """
	velocity.x *= P.speed_boost
	P.velocity = velocity #* delta

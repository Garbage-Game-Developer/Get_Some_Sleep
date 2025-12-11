class_name WallState extends State
var this_state : State.s = State.s.WALL

""" 
Description
	This normal state is for when the player is in contact with the wall, and not the ground or water

This state considers vertical movenment, and uses a simple movenment curve
This state does not consider horizontal movenment

Actions available
- Release		Swap to the "Air" state, from_ground = true
- Jump			Swap to the "Air" state, from_ground = true
+ Dash			Swap to the "Dash" state, from_ground = true
o (Punch)		Sub action that calls the parent's Punch function, and plays an animation
- (Interact)	Sub action that calls the parent's Interact function, and plays an animation
"""


""" Externals """
@onready var P : Player = $"../.."
@onready var Animation_Controller : Node2D = $"../../C"


""" Constants """
@export var NORMAL_CLIMB_SPEED : float = 70.0		##	Maximum speed (px * s) the player can climb
@export var NORMAL_MAX_SLIDE_SPEED : float = -120.0	##	Terminal speed (px * s) the player can slide down the wall
@export var NORMAL_MAX_SPEED_TIME : int = 30		##	Time (Frames) the player takes to reach max slide speed

@export var SLOW_CLIMB_SPEED : float = 70.0			##	Maximum speed (px * s) the player can climb
@export var SLOW_MAX_SLIDE_SPEED : float = -80.0	##	Terminal speed (px * s) the player can slide down the wall
@export var SLOW_MAX_SPEED_TIME : int = 60			##	Time (Frames) the player takes to reach max slide speed

@export var ICE_CLIMB_SPEED : float = 70.0			##	Maximum speed (px * s) the player can climb
@export var ICE_MAX_SLIDE_SPEED : float = -180.0	##	Terminal speed (px * s) the player can slide down the wall
@export var ICE_MAX_SPEED_TIME : int = 20			##	Time (Frames) the player takes to reach max slide speed

@export var KICK_OFF_VELOCITY : float = 100.0		##	The x velocity (px * s) applied to the player when jumping off a wall


""" Internals """
var ACTIVE_STATE : bool = false


var movenment_curve_frame : float = 0
var movenment_curve_max_frame : float = 0
var last_velocity : Vector2 = Vector2.ZERO
var velocity : Vector2 = Vector2.ZERO

var new_surface : bool = false


""" DEBUG """
var time : String


var is_state_new : bool = true
var last_state : State.s
func new_state(delta : float, change_state : State.s, _movenment_package : Array):
	print("          DEBUG - New WALL state")
	
	##	Run set up code for animations and such
	
	ACTIVE_STATE = true
	is_state_new = true
	last_state = change_state
	
	P.special_available = true
	last_velocity = P.velocity / Global.time_speed
	velocity = Vector2.ZERO
	update(delta)



func update(delta : float):
	
	time = "%9.3f" % (float(Time.get_ticks_msec()) / 1000.0)
	
	""" States (Pre Change) """
	var state_change_to : State.s = this_state
	var is_jumping : bool = false
	
	if(P.is_on_floor()):
		print(time, " DEBUG - Grounded")
		state_change_to = State.s.GROUNDED
	elif(P.is_on_wall() && P.move_vector.x == float(P.wall_direction)):
		
		""" Maybe make it so not holding makes you slide, even if you can climb, because that should always be preffereable """
		
		new_surface = determine_wall_type()
	else:
		state_change_to = State.s.AIR
	
	
	""" Actions """
	var new_action = false
	var action_is_punch = false
	if(Input.is_action_just_pressed("DASH") && $"../../Timers/DashFloorCooldown".is_stopped()):
		""" Default Key : "Shift"
			Swap to the "Dash" state, from_ground = true   """
		
		if(state_change_to == State.s.AIR && (P.advanced_movenment || P.special_dash)):
			state_change_to = State.s.DASH
			$"../../Timers/DashFloorCooldown".start()
			
		elif(state_change_to != State.s.AIR):
			state_change_to = State.s.DASH
			$"../../Timers/DashFloorCooldown".start()
	
	
	elif(Input.is_action_just_pressed("SLIDE")):
		""" Default Key : "C"
			Swap to the "Slide" state, from_ground = true   """
		
		state_change_to = State.s.SLIDE
	
	
	elif(Input.is_action_just_pressed("JUMP") || !$"../../Timers/PrecisionJumpTimer".is_stopped()):
		""" Default Key : "Space"
			Swap to the "Jump" state, from_ground = true   """
		
		
		state_change_to = State.s.AIR
		is_jumping = true
	
	
	else:
		if(Input.is_action_just_pressed("ATTACK")):
			""" Default Keys : "F", "V", "Right Mouse Button"
				Sub action that calls the parent's Punch function, and plays an animation   """
			
			##	There might be some weapon thing at some point where you can aim a weapon or orb for a boss fight / other mechanic thing
			#P.Punch()
			new_action = true
			action_is_punch = true
		
		
		elif(Input.is_action_just_pressed("INTERACT")):
			""" Default Keys : "E", "Left Mouse Button"
				Sub action that calls the parent's Interact function, and plays an animation   """
			
			##	Interact() returns an integer: 0 - Nothing happens, 1 - Cutscene, 2 - Swap to swing state
			var interact_type = 0 #P.Interact()
			match interact_type:
				0:
					new_action = true
					action_is_punch = false
				1:
					pass
				2:
					state_change_to = State.s.SWING
	
	
	""" States (Post Change)"""
	if(state_change_to != this_state):
		print(time, " DEBUG - State changing to : ", state_change_to)
		ACTIVE_STATE = false
		match state_change_to:
			State.s.AIR:
				P.current_state = State.s.AIR
				kick_off(is_jumping)
				P.Air.new_state(delta, this_state, generate_movenment_package(), is_jumping)
			State.s.DASH:
				#P.current_state = State.s.DASH
				#P.Dash.new_state(delta)
				pass
			State.s.DAZED:
				pass
			State.s.FLOATING:
				pass
			State.s.FROZEN:
				pass
			State.s.GHOST:
				pass
			State.s.GROUNDED:
				P.current_state = State.s.GROUNDED
				P.Grounded.new_state(delta, this_state, generate_movenment_package())
			State.s.KICK:
				pass
			State.s.SLIDE:
				#P.current_state = State.s.SLIDE
				#P.Slide.new_state(delta)
				pass
			State.s.SWIM:
				#P.current_state = State.s.SWIM
				#P.Swim.new_state(delta)
				pass
			State.s.SWING:
				#P.current_state = State.s.SWING
				#P.Swing.new_state(delta)
				pass
			State.s.DEAD:
				pass
			State.s.CUTSCENE:
				pass
		return
	
	
	""" Movenement Vector """
	
	
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
	
	is_state_new = false
	
	""" Physics """
	velocity.x *= P.speed_boost
	P.velocity = velocity * 60.0 * delta


func deterine_if_swap_state() -> bool:
	var temp_bool = P.move_vector.x == float(P.wall_direction)
	return temp_bool


func kick_off(jump : bool):
	if(jump):
		P.velocity.x = KICK_OFF_VELOCITY * (2.0 if P.move_vector.x == float(P.wall_direction) else 1.0) * -P.wall_direction
	else:
		P.velocity.x = (KICK_OFF_VELOCITY / 10.0) * -P.wall_direction


func generate_movenment_package() -> Array:
	##	Intended starting velocity of the curve (if there is one), is moving allong the curve still
	return [true, 0.0]


var ground_type : int = 1	##	1 - Normal, 2 - Slow, 3 - Ice
var last_ground_type : int = 1
func determine_wall_type():
	last_ground_type = ground_type
	if($"../../GroundTypeRays/NormalGroundMiddle".is_colliding()):
		ground_type = 1
	elif($"../../GroundTypeRays/SlowGroundMiddle".is_colliding()):
		ground_type = 2
	elif($"../../GroundTypeRays/IceGroundMiddle".is_colliding()):
		ground_type = 3
	return ground_type != last_ground_type

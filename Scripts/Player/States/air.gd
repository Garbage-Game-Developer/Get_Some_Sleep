class_name AirState extends Node

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
##	These need to be the same for Air and Jump states
@export var AIR_MAX_X_SPEED : float = 250.0		##	Maximum speed (px * s) the player can move in the air
@export var AIR_MAX_ACC_TIME : int = 32			##	Ammount of time (frames/60) it takes for the player to accelerate to maximum speed
@export var AIR_MAX_DEC_TIME : int = 16			##	Ammount of time (frames/60) it takes for the player to decelerate to 0 px*s
@export var AIR_MAX_OVER_DEC_TIME : int = 06	##	Ammount of time (frames/60) it takes for the player to decelerate to AIR_MAX_SPEED px*s from AIR_MAX_SPEED * 2 px*s

@export var GROUND_INITIAL_VELOCITY : float = 100.0		##	Initial speed (px * s) the player gets if jumping from the ground
@export var GROUND_DECELERATION_TIME : int = 120			##	Ammount of time (frames/60) it takes for the player to go from full jump velocity to 0

@export var DOUBLE_INITIAL_VELOCITY : float = 80.0		##	Initial speed (px * s) the player gets if jumping from the air
@export var DOUBLE_DECELERATION_TIME : int = 120			##	Ammount of time (frames/60) it takes for the player to go from full jump velocity to 0

""" Internals """
var ACTIVE_STATE : bool = false

var movenment_curve_frame : float = 0.0
var movenment_curve_max_frame : float = 0.0
var last_velocity : Vector2 = Vector2.ZERO
var initial_y_velocity : float = 0.0
var y_decceleration : float = 0.0
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
	initial_y_velocity = GROUND_INITIAL_VELOCITY if from_ground else DOUBLE_INITIAL_VELOCITY
	velocity.y = initial_y_velocity
	y_decceleration = y_decceleration * (GROUND_DECELERATION_TIME if from_ground else DOUBLE_DECELERATION_TIME)
	update(delta)


func update(delta : float):
	
	time = "%9.3f" % (float(Time.get_ticks_msec()) / 1000.0)
	
	""" States (Pre Change) """
	var state_change_to : Player.State = Player.State.AIR
	
	if(P.is_on_floor()):
		state_change_to = Player.State.GROUNDED
	elif(P.is_on_wall_only() && true):  ##  find if also holding direction
		state_change_to = Player.State.WALL
	
	""" Actions """
	var new_action = false
	var action_is_punch = false
	if(Input.is_action_just_pressed("DASH") && $"../../Timers/DashFloorCooldown".is_stopped()):
		""" Default Key : "Shift"
			Swap to the "Dash" state, from_ground = false   """
		
		""" Need to fix this dash for all potential dash states that could happen, and if it shouldn't happen """
		
		if(state_change_to == Player.State.GROUNDED && (P.advanced_movenment || P.special_dash)):
			state_change_to = Player.State.DASH
			$"../../Timers/DashFloorCooldown".start()
			
		elif(state_change_to != Player.State.GROUNDED):
			state_change_to = Player.State.DASH
			$"../../Timers/DashFloorCooldown".start()
	
	
	elif(Input.is_action_just_pressed("SLIDE")):
		""" Default Key : "C"
			Swap to the "Slide" state, from_ground = false   """
		
		state_change_to = Player.State.SLIDE
		
		""" Rework KICK state into being in a slide and punching (this would allow punch to be mapped to V insead of F) """
	
	
	else:
		if(Input.is_action_just_pressed("ATTACK")):
			""" Default Keys : "F", "V", "Right Mouse Button"
				Sub action that calls the parent's Punch function, and plays an animation   """
			
			##	There might be some weapon thing at some point where you can aim a weapon or orb for a boss fight / other mechanic thing
			#P.Punch()
			new_action = true
			action_is_punch = true
	
	
	""" States (Post Change)"""
	if(state_change_to != Player.State.AIR):
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
			Player.State.DAZED:
				pass
			Player.State.FLOATING:
				pass
			Player.State.FROZEN:
				pass
			Player.State.GHOST:
				pass
			Player.State.JUMP:
				#P.current_state = Player.State.JUMP
				#P.Jump.new_state(delta)
				pass
			Player.State.KICK:
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
			Player.State.DEAD:
				pass
			Player.State.CUTSCENE:
				pass
		return
	
	
	""" Movenement Vector (velocity.x) """
	var move_vector = P.move_vector
	
	if(P.just_switched_directions):
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
		"""
		pass
	
	
	""" Physics """
	
	##	Jump decceleration
	velocity.y -= (y_decceleration)
	
	velocity.x *= P.speed_boost
	P.velocity = velocity #* delta



""" Movenment Curve Functions """

##	Function for acceleration
#		
#		average_speed is the 0 to max_move_speed ammount (or just max_movenment)
#		time = ground_acc_time * ((|target_velocity - starting_velocity| / average_speed) ^ (3/5)
#		temp_variable = ((target_velocity - starting_velocity / (time ^ curve_constant))
#		speed = temp_variable * (frame ^ curve_constant) + starting_velocity
#	Frame is the independent variable and velocity is the dependent variable of this function

##	constants that are set based on acceleration / decceleration and ground type
var target_velocity : float = 0.0		#	"f", The speed we're lerping to (in px*s)
var starting_velocity : float = 0.0		#	"s", Starting velocity (in px*s)
var acceleration_time : float = 0.0		#	"time" or "t", Ammount of frames it takes to reach target_velocity from starting_velocity (frames)
var direction : bool = false

##	a constant set based on other variable constants
var temp_variable : float = 0.0		#	Will be set in the gen_movenment_curve() function as a reused constant dependent on varying constants

##	Permanent constants (Might change to be per ground type later)
var curve_constant : float = 1.0 / 2.0		#	"C1", The constant that determines how drasticly the function curves
var time_scale_constant : float = 3.0 / 5.0	#	"C2", The constant that determines how time scales over the average_speed constant

func gen_movenment_curve(direct : float):
	
	var to_zero = direct == 0.0
	if(to_zero && velocity.x == 0.0):
		
		acceleration_time = 0.0
		
		
		""" Figure this out, also need to figure out how disruptions and other stuff affect this, might keep it in the floating/dazed states """
		
		#print(time, " DEBUG - velocity at zero moving to zero")
		return
	
	var temp_boolean : bool
	var multiple : float
	
	starting_velocity = velocity.x
	#	This boolean works as so : (velocity is negative and direct is positive)
	temp_boolean = (sign(starting_velocity) != sign(direct) && direct > 0.0)
	#	This boolean works as so : not moving towards zero and (both velocity and direct are different signs) and (not yet calculated) target_speed > velocity
	##temp_boolean = temp_boolean || (sign(starting_velocity) == sign(direct) && ((direct > 0.0 && GROUND_MAX_SPEED > starting_velocity) || (direct < 0.0 && -GROUND_MAX_SPEED > starting_velocity)))
	temp_boolean = temp_boolean || (sign(starting_velocity) == sign(direct) && direct > 0.0)
	multiple = 1.0 if temp_boolean else -1.0 # This multiple is used for 
	target_velocity = AIR_MAX_X_SPEED * multiple if !to_zero else 0.0
	
	# 	This boolean works as so : (target velocity is greater than or equal to starting velocity) or (target is less than starting but target and starting aren't both either positive or negative)
	direction = direct != 0.0 && (abs(target_velocity) >= abs(starting_velocity) || (abs(target_velocity) < abs(starting_velocity) && sign(target_velocity) != sign(starting_velocity)))
	acceleration_time = AIR_MAX_ACC_TIME if direction else (AIR_MAX_DEC_TIME if abs(target_velocity) > abs(starting_velocity) else AIR_MAX_OVER_DEC_TIME)
	acceleration_time = acceleration_time * pow((abs(target_velocity - starting_velocity) / AIR_MAX_X_SPEED), time_scale_constant)
	
	temp_variable = (target_velocity - starting_velocity) / pow(acceleration_time, curve_constant)
	
	movenment_curve_max_frame = acceleration_time
	
	"""  Set the printf time thing to a variable in the beggining of the process and use it  """
	
	print(time, " DEBUG - New curve is generated succesfully :"
	,   " d=%4.1f"  % direct
	,  ", D=%5s"    % str(direction)
	 , ", Z=%5s"    % str(to_zero)
	 , ", T=%9.3f"  % target_velocity
	 , ", S=%9.3f"  % starting_velocity
	 , ", V=%9.3f"  % velocity.x
	 , ", A=%6.3f"  % acceleration_time
	 , ", AA=%6.3f" % movenment_curve_max_frame
	 , ", TV=%8.3f" % temp_variable)


func velocity_on_curve(frame : float) -> float:
	if(frame >= movenment_curve_max_frame):
		#if(frame > movenment_curve_max_frame): ##	Just in case something is going wrong, this will be a failsafe
			#print(time, " PROBLEM - found with Grounded's frames if statement prior to the velocity_on_curve() function being called")
		return target_velocity
	var speed : float = 0.0
	speed = temp_variable * pow(frame, curve_constant) + starting_velocity
	#print(time, " DEBUG - Speed found on curve : S=", "%8.3f" % speed)
	return speed


"""	Create a y velocity function and detector for when its time to swap to air """

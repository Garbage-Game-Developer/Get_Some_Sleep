class_name GroundedState extends Node

""" 
Description
	This normal state is for when the player is in contact with the ground, and not water

This state considers horizontal movenment, and uses a complex movenment curve
This state does not consider vertical movenment

Actions available
- Jump			Swap to the "Jump" state, from_ground = true
+ Dash			Swap to the "Dash" state, from_ground = true
- Slide			Swap to the "Slide" state, from_ground = true
o (Punch)		Sub action that calls the parent's Punch function, and plays an animation
- (Interact)	Sub action that calls the parent's Interact function, and plays an animation
"""


""" Externals """
@onready var P : Player = $"../.."
@onready var Animation_Controller : Node2D = $"../../C"


""" Constants """
@export var WALK_MAX_SPEED : float = 50.0	##	Maximum speed (px * s) the player can move
@export var WALK_MAX_ACC_TIME : int = 12	##	Ammount of time (frames/60) it takes for the player to accelerate to maximum speed
@export var WALK_MAX_DEC_TIME : int = 06	##	Ammount of time (frames/60) it takes for the player to decelerate to 0 px*s

@export var GROUND_MAX_SPEED : float = 200.0	##	Maximum speed (px * s) the player can move
@export var GROUND_MAX_ACC_TIME : int = 24		##	Ammount of time (frames/60) it takes for the player to accelerate to maximum speed
@export var GROUND_MAX_DEC_TIME : int = 12		##	Ammount of time (frames/60) it takes for the player to decelerate to 0 px*s

@export var SLOW_GROUND_MAX_SPEED : float = 120.0	##	Maximum speed (px * s) the player can move
@export var SLOW_GROUND_MAX_ACC_TIME : int = 48		##	Ammount of time (frames/60) it takes for the player to accelerate to maximum speed
@export var SLOW_GROUND_MAX_DEC_TIME : int = 10		##	Ammount of time (frames/60) it takes for the player to decelerate to 0 px*s

@export var ICE_GROUND_MAX_SPEED : float = 300.0	##	Maximum speed (px * s) the player can move
@export var ICE_GROUND_MAX_ACC_TIME : int = 60		##	Ammount of time (frames/60) it takes for the player to accelerate to maximum speed
@export var ICE_GROUND_MAX_DEC_TIME : int = 30		##	Ammount of time (frames/60) it takes for the player to decelerate to 0 px*s


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
var last_state
func new_state(delta : float, change_state):
	print("          DEBUG - New GROUNDED state")
	
	##	Run set up code for animations and such
	
	ACTIVE_STATE = true
	is_state_new = true
	last_state = change_state
	velocity = P.velocity / Global.time_speed
	update(delta)



func update(delta : float):
	
	time = "%9.3f" % (float(Time.get_ticks_msec()) / 1000.0)
	
	""" States (Pre Change) """
	var state_change_to : Player.State = Player.State.GROUNDED
	
	if(!P.is_on_floor()):
		state_change_to = Player.State.AIR
		$"../../Timers/CoyoteTimer".start()
	else:
		new_surface = determine_ground_type()
	
	
	""" Actions """
	var new_action = false
	var action_is_punch = false
	if(Input.is_action_just_pressed("DASH") && $"../../Timers/DashFloorCooldown".is_stopped()):
		""" Default Key : "Shift"
			Swap to the "Dash" state, from_ground = true   """
		
		if(state_change_to == Player.State.AIR && (P.advanced_movenment || P.special_dash)):
			state_change_to = Player.State.DASH
			$"../../Timers/DashFloorCooldown".start()
			
		elif(state_change_to != Player.State.AIR):
			state_change_to = Player.State.DASH
			$"../../Timers/DashFloorCooldown".start()
	
	
	elif(Input.is_action_just_pressed("SLIDE")):
		""" Default Key : "C"
			Swap to the "Slide" state, from_ground = true   """
		
		state_change_to = Player.State.SLIDE
	
	
	elif(Input.is_action_just_pressed("JUMP")):
		""" Default Key : "Space"
			Swap to the "Jump" state, from_ground = true   """
		
		state_change_to = Player.State.JUMP
	
	
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
					state_change_to = Player.State.SWING
	
	
	""" States (Post Change)"""
	if(state_change_to != Player.State.GROUNDED):
		print(time, " DEBUG - State changing to : ", state_change_to)
		ACTIVE_STATE = false
		match state_change_to:
			Player.State.AIR:
				P.current_state = Player.State.AIR
				P.Air.new_state(delta, P.State.GROUNDED)
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
				P.current_state = Player.State.JUMP
				P.Jump.new_state(delta, P.State.GROUNDED)
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
	
	
	""" Movenement Vector """
	var move_vector = P.move_vector
	
	if(P.just_switched_directions || new_surface || is_state_new):
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
	
	is_state_new = false
	
	""" Physics """
	velocity.x *= P.speed_boost
	P.velocity = velocity #* delta


var ground_type : int = 1	##	1 - Normal, 2 - Slow, 3 - Ice
var last_ground_type : int = 1
func determine_ground_type():
	last_ground_type = ground_type
	if($"../../GroundTypeRays/NormalGroundMiddle".is_colliding()):
		ground_type = 1
	elif($"../../GroundTypeRays/SlowGroundMiddle".is_colliding()):
		ground_type = 2
	elif($"../../GroundTypeRays/IceGroundMiddle".is_colliding()):
		ground_type = 3
	else:
		if($"../../GroundTypeRays/NormalGroundLeft".is_colliding() || $"../../GroundTypeRays/NormalGroundRight".is_colliding()):
			ground_type = 1
		elif($"../../GroundTypeRays/SlowGroundLeft".is_colliding() || $"../../GroundTypeRays/SlowGroundRight".is_colliding()):
			ground_type = 2
		elif($"../../GroundTypeRays/IceGroundLeft".is_colliding() || $"../../GroundTypeRays/IceGroundRight".is_colliding()):
			ground_type = 3
	return ground_type != last_ground_type



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
	var temp_boolean : bool
	var multiple : float
	
	match ground_type:
		1:  ##  Normal Ground
			
			starting_velocity = velocity.x
			#	This boolean works as so : (velocity is negative and direct is positive)
			temp_boolean = (sign(starting_velocity) != sign(direct) && direct > 0.0)
			#	This boolean works as so : not moving towards zero and (both velocity and direct are different signs) and (not yet calculated) target_speed > velocity
			##temp_boolean = temp_boolean || (sign(starting_velocity) == sign(direct) && ((direct > 0.0 && GROUND_MAX_SPEED > starting_velocity) || (direct < 0.0 && -GROUND_MAX_SPEED > starting_velocity)))
			temp_boolean = temp_boolean || (sign(starting_velocity) == sign(direct) && direct > 0.0)
			multiple = 1.0 if temp_boolean else -1.0 # This multiple is used for 
			target_velocity = GROUND_MAX_SPEED * multiple if !to_zero else 0.0
			
			# 	This boolean works as so : (target velocity is greater than or equal to starting velocity) or (target is less than starting but target and starting aren't both either positive or negative)
			direction = direct != 0.0 && (abs(target_velocity) >= abs(starting_velocity) || (abs(target_velocity) < abs(starting_velocity) && sign(target_velocity) != sign(starting_velocity)))
			acceleration_time = GROUND_MAX_ACC_TIME if direction else GROUND_MAX_DEC_TIME
			acceleration_time = acceleration_time * pow((abs(target_velocity - starting_velocity) / GROUND_MAX_SPEED), time_scale_constant)
			
			temp_variable = (target_velocity - starting_velocity) / pow(acceleration_time, curve_constant)
		
		2:  ##  Slow Ground
			
			starting_velocity = velocity.x
			#	This boolean works as so : (velocity is negative and direct is positive)
			temp_boolean = (sign(starting_velocity) != sign(direct) && direct > 0.0)
			#	This boolean works as so : (both velocity and direct are different signs) and (not yet calculated) target_speed > velocity
			##temp_boolean = temp_boolean || (sign(starting_velocity) == sign(direct) && ((direct > 0.0 && SLOW_GROUND_MAX_SPEED > starting_velocity) || (direct < 0.0 && -SLOW_GROUND_MAX_SPEED > starting_velocity)))
			temp_boolean = temp_boolean || (sign(starting_velocity) == sign(direct) && direct > 0.0)
			multiple = 1.0 if temp_boolean else -1.0 # This multiple is used for 
			target_velocity = SLOW_GROUND_MAX_SPEED * multiple if !to_zero else 0.0
			
			# 	This boolean works as so : not moving towards zero and (target velocity is greater than or equal to starting velocity) or (target is less than starting but target and starting aren't both either positive or negative)
			direction = direct != 0.0 && (abs(target_velocity) >= abs(starting_velocity) || (abs(target_velocity) < abs(starting_velocity) && sign(target_velocity) != sign(starting_velocity)))
			acceleration_time = SLOW_GROUND_MAX_ACC_TIME if direction else SLOW_GROUND_MAX_DEC_TIME
			acceleration_time = acceleration_time * pow((abs(target_velocity - starting_velocity) / GROUND_MAX_SPEED), time_scale_constant)
			
			temp_variable = (target_velocity - starting_velocity) / pow(acceleration_time, curve_constant)
			
		3:  ##  Ice Ground
			
			starting_velocity = velocity.x
			#	This boolean works as so : (velocity is negative and direct is positive)
			temp_boolean = (sign(starting_velocity) != sign(direct) && direct > 0.0)
			#	This boolean works as so : (both velocity and direct are different signs) and (not yet calculated) target_speed > velocity
			temp_boolean = temp_boolean || (sign(starting_velocity) == sign(direct) && ((direct > 0.0 && ICE_GROUND_MAX_SPEED > starting_velocity) || (direct < 0.0 && -ICE_GROUND_MAX_SPEED > starting_velocity)))
			multiple = 1.0 if temp_boolean else -1.0 # This multiple is used for 
			target_velocity = ICE_GROUND_MAX_SPEED * multiple if !to_zero else 0.0
			
			# 	This boolean works as so : not moving towards zero and (target velocity is greater than or equal to starting velocity) or (target is less than starting but target and starting aren't both either positive or negative)
			direction = direct != 0.0 && (abs(target_velocity) >= abs(starting_velocity) || (abs(target_velocity) < abs(starting_velocity) && sign(target_velocity) != sign(starting_velocity)))
			acceleration_time = ICE_GROUND_MAX_ACC_TIME if direction else ICE_GROUND_MAX_DEC_TIME
			acceleration_time = acceleration_time * pow((abs(target_velocity - starting_velocity) / GROUND_MAX_SPEED), time_scale_constant)
			
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


##	Is this code not bwutiful

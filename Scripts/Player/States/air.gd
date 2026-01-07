class_name AirState extends State
var this_state : State.s = State.s.AIR

""" 
Description
	This normal state is for when the player is not in contact with the ground, a wall, or water

This state considers horizontal movenment, and uses a complex movenment curve
This state does not consider vertical movenment

Actions available
o Dash			Swap to the "Dash" state, from_ground = false
- Slide			Swap to the "Slide" state, from_ground = false
o Kick			Swap to the "Kick" state, 
o (Jump)		Sub action that adds y velocity using the jump() functions
o (Punch)		Sub action that calls the parent's Punch function, and plays an animation
"""


""" Externals """
@onready var P : Player = $"../.."
@onready var C : SpriteHandler = $"../../C"


""" Constants """
##	Horizontal Movenment
@export var AIR_MAX_X_SPEED : float = 210.0		##	Maximum speed (px * s) the player can move in the air
@export var AIR_MAX_ACC_TIME : int = 42			##	Ammount of time (frames/60) it takes for the player to accelerate to maximum speed
@export var AIR_MAX_DEC_TIME : int = 18			##	Ammount of time (frames/60) it takes for the player to decelerate to 0 px*s
@export var AIR_MAX_OVER_DEC_TIME : int  = 48	##	Ammount of time (frames/60) it takes for the player to decelerate to AIR_MAX_SPEED px*s from AIR_MAX_SPEED * 2 px*s

##	Jumping (-6.25)
@export var GROUND_INITIAL_VELOCITY : float = -200		##	Initial speed (px * s) the player gets if jumping from the ground
@export var GROUND_DECELERATION_TIME : int = 32			##	Ammount of time (frames/60) it takes for the player to go from full jump velocity to 0
#	(-5.313)
@export var DOUBLE_INITIAL_VELOCITY : float = -180.0	##	Initial speed (px * s) the player gets if jumping from the air
@export var DOUBLE_DECELERATION_TIME : int = 32			##	Ammount of time (frames/60) it takes for the player to go from full jump velocity to 0
##	Wall (-6.25)
@export var WALL_INITIAL_VELOCITY : float = -180		##	Initial speed (px * s) the player gets if jumping off a wall
@export var WALL_DECELERATION_TIME : int = 32			##	Ammount of time (frames/60) it takes for the player to go from full jump velocity to 0
##	Falling (8.889)
@export var FALLING_TERMINAL_VELOCITY : float = 800.0		##	Maximum downward y velocity (px * s)
@export var FALLING_DECELERATION_TIME : int = 90			##	Ammount of time (frames/60) it takes for the player to go from 0 velocity to terminal

##	Slope of final velocity over time will determine acceleration
##	Falling should be greater than rising


""" Internals """
var ACTIVE_STATE : bool = false
var is_jumping
var double_jump_bool : bool

var triggered_jump : bool = false

var last_on_wall : bool = false
var interferience : bool = false

var movenment_curve_frame : float = 0.0
var movenment_curve_max_frame : float = 0.0

var last_velocity : Vector2 = Vector2.ZERO
var initial_y_velocity : float = 0.0
var y_decceleration : float = 0.0  ##  Gravity Value
var velocity : Vector2 = Vector2.ZERO


""" DEBUG """
var time : String


var kick_power : float
var mid_curve : bool = false
var is_state_new : bool = true
var last_state : State.s
func new_state(delta : float, change_state : State.s, movenment_package : Array, jumping : bool = false, power : float = 1.0):
	print("          DEBUG - New AIR state")
	
	##	Run set up code for animations and such
	ACTIVE_STATE = true
	is_state_new = true
	double_jump_bool = P.free_double_jump || P.item_double_jump
	last_state = change_state
	kick_power = power
	last_on_wall = false
	
	mid_curve = movenment_package[0]
	starting_velocity = movenment_package[1]
	
	velocity = P.velocity / Global.time_speed
	if(jumping):
		jump()
		$"../../Timers/CoyoteTimer".stop()
	else:
		y_decceleration = FALLING_TERMINAL_VELOCITY / FALLING_DECELERATION_TIME
	
	update(delta)


func update(delta : float):
	
	time = "%9.3f" % (float(Time.get_ticks_msec()) / 1000.0)
	
	""" States (Pre Change) """
	var state_change_to : State.s = this_state
	triggered_jump = false
	
	if(P.is_on_floor() && !is_state_new):
		state_change_to = State.s.GROUNDED
	elif(P.on_wall() && !P.is_on_floor() && !is_state_new && P.Wall.deterine_if_swap_state()):  ##  find if also holding direction
		##	Seemlessly cut over
		var temp_check : int = cut_clamber_hang()
		if(temp_check == 1 && velocity.y >= 0.0):
			##	Seemless cut
			P.position.y -= 15.0 - collision_point + 0.1
			velocity.y = -y_decceleration
			P.position.x += 0.1 + P.wall_direction
		elif(temp_check == 2 && velocity.y >= -10.0):
			##	Clamber
			velocity.y = -100.0
		elif((temp_check == 3 || temp_check == 4) && (P.stamina > 0.0 || Input.is_action_just_pressed("JUMP") && $"../../Timers/CoyoteTimer".is_stopped() && !(double_jump_bool && P.special_available))):
			##	Change to wall
			state_change_to = State.s.WALL
		else:
			##	Check if can corner hang, if not, don't switch
			pass
	elif(!Input.is_action_pressed("JUMP") || velocity.y >= 0.0 || P.is_on_ceiling()):
		y_decceleration = FALLING_TERMINAL_VELOCITY / FALLING_DECELERATION_TIME
		if(P.is_on_ceiling() && is_jumping):
			velocity.y = -y_decceleration
		is_jumping = false
	
	if(P.is_on_wall_only() && state_change_to != State.s.WALL && velocity.x != 0.0):
		target_velocity = 0.0 if sign(velocity.x) == P.wall_direction else target_velocity
		movenment_curve_frame = 1000.0 if sign(velocity.x) == P.wall_direction else movenment_curve_frame
		if(sign(velocity.x) == P.wall_direction && P.move_vector.x != P.wall_direction && !P.just_switched_directions):
			gen_movenment_curve(P.move_vector.x)
			movenment_curve_frame = 0.0
		last_on_wall = true
	if(last_on_wall && !P.on_wall()):
		interferience = true
		last_on_wall = false
	
	""" Actions """
	var new_action = false
	var action_is_punch = false
	if(Input.is_action_just_pressed("DASH") && $"../../Timers/DashFloorCooldown".is_stopped()):
		""" Default Key : "Shift"
			Swap to the "Dash" state """
		
		""" Need to fix this dash for all potential dash states that could happen, and if it shouldn't happen """
		
		if(state_change_to == State.s.GROUNDED && (P.advanced_movenment || P.special_dash)):
			state_change_to = State.s.DASH
			$"../../Timers/DashFloorCooldown".start()
			
		elif(state_change_to != State.s.GROUNDED):
			state_change_to = State.s.DASH
			$"../../Timers/DashFloorCooldown".start()
	
	
	elif(Input.is_action_just_pressed("JUMP") && !is_jumping && (!$"../../Timers/CoyoteTimer".is_stopped() || (double_jump_bool && P.special_available))):
		""" Default Key : "Space"
			run the jump() function """
		
		if(P.item_double_jump && $"../../Timers/CoyoteTimer".is_stopped()):
			if(P.special_areas > 0):
				Global.emit_signal("player_special_used", P.player_id)
				P.special_available = false
				last_state = State.s.AIR
				jump()
		
		elif(!$"../../Timers/CoyoteTimer".is_stopped()):
			print("working???")
			$"../../Timers/CoyoteTimer".stop()
			jump()
		
		else:
			P.special_available = false
			last_state = State.s.AIR
			jump()
	
	elif(Input.is_action_just_pressed("SLIDE")):
		""" Default Key : "C"
			Swap to the "Slide" state, from_ground = false   """
		
		state_change_to = State.s.SLIDE
		
		""" Rework KICK state into being in a slide and punching (this would allow punch to be mapped to V insead of F) """
	
	
	else:
		if(Input.is_action_just_pressed("ATTACK")):
			""" Default Keys : "F", "V", "Right Mouse Button"
				Sub action that calls the parent's Punch function, and plays an animation   """
			
			##	There might be some weapon thing at some point where you can aim a weapon or orb for a boss fight / other mechanic thing
			#P.Punch()
			new_action = true
			action_is_punch = true
	
	
	##	Precision Jump
	if(Input.is_action_just_pressed("JUMP") && !is_jumping && !triggered_jump):
		$"../../Timers/PrecisionJumpTimer".start()
	
	
	""" States (Post Change) """
	#	I've thought about keeping this in the abstract class, but there's too much stuff to it like animation that can't be generalized
	if(state_change_to != this_state):
		print(time, " DEBUG - State changing to : ", state_change_to)
		ACTIVE_STATE = false
		match state_change_to:
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
			State.s.WALL:
				P.current_state = State.s.WALL
				P.Wall.new_state(delta, this_state, generate_movenment_package())
			State.s.DEAD:
				pass
			State.s.CUTSCENE:
				pass
		return
	
	
	""" Movenement Vector (velocity.x) """
	var move_vector = P.move_vector
	
	if(P.just_switched_directions || is_state_new || interferience):
		P.interference = false
		interferience = false
		movenment_curve_frame = 0
		gen_movenment_curve(move_vector.x)
	movenment_curve_frame = minf(movenment_curve_frame + 1.0 * P.speed_boost, movenment_curve_max_frame)
	velocity.x = velocity_on_curve(movenment_curve_frame)
	
	#print(time, " DEBUG velocity : V=%8.3f" % velocity.x)
	
	
	""" Animations to Play """
	if(!new_action):
		
		#if(P.just_switched_directions):
		#	C.change_facing(P.left_or_right)
		
		if(velocity.x != 0.0 && sign(velocity.x) != C.left_or_right):
			C.change_facing(true if velocity.x > 0.0 else false)
		
		"""  Movenment Animations  """
		
		var moving_threshhold : float = 100.0 
		var float_threshhold : float = 50.0
		
		if(was_on_wall && is_jumping):
			C.play(C.JUMP_WALL)
		
		elif(velocity.y < -float_threshhold && C.animation != C.JUMP_WALL):
			C.play(C.JUMP_MOVING if abs(velocity.x) > moving_threshhold else C.JUMP)
		
		elif(velocity.y < 0.0 && C.animation != C.JUMP_WALL):
			C.play(C.FLOATING_UP_MOVING if abs(velocity.x) > moving_threshhold else C.FLOATING_UP)
		
		elif(velocity.y < float_threshhold * 1.5 && C.animation != C.JUMP_WALL):
			C.play(C.FLOATING_DOWN_MOVING if abs(velocity.x) > moving_threshhold else C.FLOATING_DOWN)
		
		elif(velocity.y > float_threshhold && C.animation != C.JUMP_WALL):
			C.play(C.FALL_MOVING if abs(velocity.x) > moving_threshhold else C.FALL)

		
	else:
		
		"""  Action Animations  """
		
		pass
		
		##	Will need to receive the interaction type to figure out what kind of animation to play, might have to cutscene it

	
	
	"""  Animation Scale Stuff  """
	
	var desired_scale : Vector2 = Vector2.ONE
	desired_scale.y = 1 + (abs(velocity.y) / ((abs(velocity.y) + 100.0) * (5.0 if sign(velocity.y) < 0 else 6.0)))
	desired_scale.x = 1.0 / desired_scale.y
	C.scale = lerp(C.scale, desired_scale, 0.4) 
	
	is_state_new = false
	was_on_wall = false 
	
	""" Physics """
	
	##	Jump decceleration
	velocity.y = min(velocity.y + y_decceleration, FALLING_TERMINAL_VELOCITY)
	
	velocity.x *= P.speed_boost
	P.velocity = velocity * 60.0 * delta
	
	
	"""  Final Adjustments  """
	
	var temp_velocity = velocity * delta
	$"../../ConvenienceRays/VelocityCeilingSnapLeft".target_position.y = minf(0, temp_velocity.y)
	$"../../ConvenienceRays/VelocityCeilingSnapRight".target_position.y = minf(0, temp_velocity.y)
	$"../../ConvenienceRays/VelocityCeilingLeft".target_position.y = minf(0, temp_velocity.y)
	$"../../ConvenienceRays/VelocityCeilingRight".target_position.y = minf(0, temp_velocity.y)
	$"../../ConvenienceRays/VelocityCeilingSnapLeft".force_update_transform()	##	Checks if you can't snap around the ceiling next frame
	$"../../ConvenienceRays/VelocityCeilingSnapRight".force_update_transform()	##	Checks if you can't snap around the ceiling next frame
	$"../../ConvenienceRays/VelocityCeilingLeft".force_update_transform()		##	Checks if you're colliding with the ceiling next frame
	$"../../ConvenienceRays/VelocityCeilingRight".force_update_transform()		##	Checks if you're colliding with the ceiling next frame
	$"../../ConvenienceRays/VelocityCeilingSnapLeft".force_raycast_update()
	$"../../ConvenienceRays/VelocityCeilingSnapRight".force_raycast_update()
	$"../../ConvenienceRays/VelocityCeilingLeft".force_raycast_update()
	$"../../ConvenienceRays/VelocityCeilingRight".force_raycast_update()
	
	if(!($"../../ConvenienceRays/VelocityCeilingLeft".is_colliding() && !$"../../ConvenienceRays/VelocityCeilingSnapLeft".is_colliding()) && ($"../../ConvenienceRays/VelocityCeilingRight".is_colliding() && !$"../../ConvenienceRays/VelocityCeilingSnapRight".is_colliding())):
		$"../../ConvenienceRays/CeilingSnapRight".position.y = -15 + temp_velocity.y
		$"../../ConvenienceRays/CeilingSnapRight".force_update_transform()
		$"../../ConvenienceRays/CeilingSnapRight".force_raycast_update()
		P.position.x += $"../../ConvenienceRays/VelocityCeilingRight".to_local($"../../ConvenienceRays/CeilingSnapRight".get_collision_point()).x - 0.1
		if(velocity.y < -50.0):
			$"../../C".scale.y = 1.2 + (($"../../ConvenienceRays/VelocityCeilingRight".to_local($"../../ConvenienceRays/CeilingSnapRight".get_collision_point()).x - 0.1) / 7.0)
			$"../../C".scale.x = 1 / $"../../C".scale.y
	
	elif($"../../ConvenienceRays/VelocityCeilingLeft".is_colliding() && !$"../../ConvenienceRays/VelocityCeilingSnapLeft".is_colliding()):
		$"../../ConvenienceRays/CeilingSnapLeft".position.y = -15 + temp_velocity.y
		$"../../ConvenienceRays/CeilingSnapLeft".force_update_transform()
		$"../../ConvenienceRays/CeilingSnapLeft".force_raycast_update()
		P.position.x += $"../../ConvenienceRays/VelocityCeilingLeft".to_local($"../../ConvenienceRays/CeilingSnapLeft".get_collision_point()).x + 0.1
		if(velocity.y < -50.0):
			$"../../C".scale.y = 1.2 + (($"../../ConvenienceRays/VelocityCeilingLeft".to_local($"../../ConvenienceRays/CeilingSnapLeft".get_collision_point()).x - 0.1) / 7.0)
			$"../../C".scale.x = 1 / $"../../C".scale.y


func generate_movenment_package() -> Array:
	##	Intended starting velocity of the curve (if there is one), is moving allong the curve still
	return [movenment_curve_max_frame > movenment_curve_frame, starting_velocity]


var was_on_wall = false
func jump():
	var height_jumping : bool = P.stamina > 0.0 && ((P.wall_type == 1 && P.normal_climb) || (P.wall_type == 2 && P.slow_climb))
	is_jumping = last_state != State.s.WALL || height_jumping
	triggered_jump = true
	
	match last_state:
		State.s.GROUNDED:
			initial_y_velocity = GROUND_INITIAL_VELOCITY
			velocity.y = initial_y_velocity
			y_decceleration = -initial_y_velocity / GROUND_DECELERATION_TIME
		State.s.WALL:
			was_on_wall = true
			initial_y_velocity = (WALL_INITIAL_VELOCITY * kick_power if height_jumping else 0.0)
			velocity.y = initial_y_velocity * kick_power
			y_decceleration = (-initial_y_velocity / WALL_DECELERATION_TIME if height_jumping else FALLING_TERMINAL_VELOCITY / FALLING_DECELERATION_TIME)
		this_state:
			initial_y_velocity = DOUBLE_INITIAL_VELOCITY
			velocity.y = initial_y_velocity
			y_decceleration = -initial_y_velocity / DOUBLE_DECELERATION_TIME
		_:
			pass
	last_state = this_state


var collision_point : float = 0.0
var low_collision_point : float = 0.0
##	Return : 1 - seemless cut over, 2 - clamber, 3 - normal wall, 4 - ledge hang, 5 - corner hang
func cut_clamber_hang() -> int:
	##  starts at y = -15.0 (0.0), and at the target position (which is downward, starting up) would be y = 0.0 (15.0)
	collision_point = $"../../WallTypeRays/WallRight".get_collision_point().y - $"../../WallTypeRays/WallRight".global_position.y if P.wall_direction == 1 else $"../../WallTypeRays/WallLeft".get_collision_point().y - $"../../WallTypeRays/WallLeft".global_position.y
	##  starts at y = 0.0 (0.0), and at the target position (which is upwards, starting down) would be y = -15.0 (15.0)
	low_collision_point = -$"../../WallTypeRays/WallRightDown".get_collision_point().y - -$"../../WallTypeRays/WallRightDown".global_position.y if P.wall_direction == 1 else $"../../WallTypeRays/WallLeftDown".get_collision_point().y - $"../../WallTypeRays/WallLeftDown".global_position.y
	if(collision_point == 0.0 && low_collision_point >= 12.0):
		return 5
	elif(collision_point == 0.0):
		return 3
	elif(collision_point >= 13.0):
		return 1
	elif(collision_point >= 9.0):
		return 2
	elif(collision_point >= 3.0):
		return 4
	return 3


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
	
	if(!is_state_new || !mid_curve || was_on_wall):
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
	if(is_state_new && mid_curve && last_state != State.s.WALL):
		movenment_curve_frame = pow((velocity.x - starting_velocity) / temp_variable, 1 / (curve_constant))
	
	"""  Set the printf time thing to a variable in the beggining of the process and use it  """
	
	print(time, " DEBUG - New curve is generated succesfully :"
	,   " d=%4.1f"  % direct
	,  ", D=%5s"    % str(direction)
	 , ", Z=%5s"    % str(to_zero)
	 , ", T=%9.3f"  % target_velocity
	 , ", S=%9.3f"  % starting_velocity
	 , ", V=%9.3f"  % velocity.x
	 , ", A=%5.2f"  % acceleration_time
	 , ", AA=%5.2f" % movenment_curve_max_frame
	 , ", F=%5.2f"  % movenment_curve_frame
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

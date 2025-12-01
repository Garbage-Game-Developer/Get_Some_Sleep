class_name GroundedState extends Node

""" 
Description
	This state is for when the player is in contact with the ground, and not water

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
@export var WALK_MAX_SPEED : float = 100.0	##	Maximum speed (px * s) the player can move
@export var WALK_MAX_ACC_TIME : int = 12	##	Ammount of time (frames/60) it takes for the player to accelerate to maximum speed
@export var WALK_MAX_DEC_TIME : int = 06	##	Ammount of time (frames/60) it takes for the player to decelerate to 0 px*s

@export var GROUND_MAX_SPEED : float = 300.0	##	Maximum speed (px * s) the player can move
@export var GROUND_MAX_ACC_TIME : int = 24		##	Ammount of time (frames/60) it takes for the player to accelerate to maximum speed
@export var GROUND_MAX_DEC_TIME : int = 12		##	Ammount of time (frames/60) it takes for the player to decelerate to 0 px*s

@export var SLOW_GROUND_MAX_SPEED : float = 200.0	##	Maximum speed (px * s) the player can move
@export var SLOW_GROUND_MAX_ACC_TIME : int = 48		##	Ammount of time (frames/60) it takes for the player to accelerate to maximum speed
@export var SLOW_GROUND_MAX_DEC_TIME : int = 10		##	Ammount of time (frames/60) it takes for the player to decelerate to 0 px*s

@export var ICE_GROUND_MAX_SPEED : float = 350.0	##	Maximum speed (px * s) the player can move
@export var ICE_GROUND_MAX_ACC_TIME : int = 60		##	Ammount of time (frames/60) it takes for the player to accelerate to maximum speed
@export var ICE_GROUND_MAX_DEC_TIME : int = 30		##	Ammount of time (frames/60) it takes for the player to decelerate to 0 px*s


""" Internals """
var ACTIVE_STATE : bool = false

var movenment_curve_frame : float = 0
var movenment_curve_max_frame : int = 0
var last_velocity : Vector2 = Vector2.ZERO
var velocity : Vector2 = Vector2.ZERO


func new_state(delta : float):
	
	##	Run set up code for animations and such
	
	ACTIVE_STATE = true
	velocity = P.velocity / Global.time_speed
	gen_movenment_curve(1.0 if (P.move_vector.x == 0.0 && velocity.x < 0.0) || P.move_vector.x > 0.0 else -1.0)
	update(delta)



func update(delta : float):
	
	""" States (Pre Change) """
	var state_change_to : Player.State = Player.State.GROUNDED
	
	if(!P.is_on_floor()):
		state_change_to = Player.State.AIR
		$"../../Timers/CoyoteTimer".start()
	else:
		determine_ground_type()
	
	
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
	
	
	if(P.just_switched_directions):
		P.interference = false
		movenment_curve_frame = 0
		gen_movenment_curve(move_vector.x)
	movenment_curve_frame = minf(movenment_curve_frame + 1.0 * P.speed_boost, float(movenment_curve_max_frame))
	velocity.x = velocity_on_curve(movenment_curve_frame)
	
	#print("DEBUG velocity:" +str(velocity.x))
	
	
	""" Animations to Play """
	if(!new_action):
		
		if(P.just_switched_directions):
			Animation_Controller.left_or_right = (1 if P.left_or_right else 0)
		
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


var ground_type : int = 1	##	1 - Normal, 2 - Slow, 3 - Ice
func determine_ground_type():
	pass



""" Movenment Curve Functions """

##	Function for movenment
##		temp_variable = acceleration time - (acceleration time * starting velocity) / (2 * max speed)
##		speed = -1 * (max speed - starting velocity) * (frame * (frame - 2 * temp_variable) / (temp_variable * temp_variable)) + starting velocity
##	Frame is the independent variable and speed is the dependent variable of this function

var target_speed : float = 0.0				##	Maximum speed (in px*s)
var starting_velocity : float = 0.0		##	Starting velocity (in px*s)
var acceleration_time : int = 0			##	Ammount of frames it takes to reach max_speed from starting_velocity (frames)

var to_zero = false
var direction : float = 0.0				##	The direction the player is moving towards
var temp_variable : float = 0.0			##	Will be set in the gen_movenment_curve() function as a reused constant dependent on varying constants
func gen_movenment_curve(direct : float):
	direction = direct
	
	to_zero = direction == 0.0
	if(to_zero && velocity.x == 0.0):
		return
	
	match ground_type:
		1:  ##  Normal Ground
			if(!to_zero):
				target_speed = GROUND_MAX_SPEED * direction
				starting_velocity = velocity.x
				acceleration_time = GROUND_MAX_ACC_TIME
				
				temp_variable = acceleration_time - (acceleration_time * starting_velocity) / (2 * target_speed)
				movenment_curve_max_frame = int(temp_variable)
			
			else:
				target_speed = GROUND_MAX_SPEED * (velocity.x / abs(velocity.x))
				starting_velocity = velocity.x - target_speed
				acceleration_time = GROUND_MAX_DEC_TIME
				
				temp_variable = acceleration_time + acceleration_time * starting_velocity / (8 * target_speed)
				movenment_curve_max_frame = int( sqrt(((starting_velocity * temp_variable * temp_variable) / target_speed) + (temp_variable * temp_variable)) )
		
		2:  ##  Slow Ground
			target_speed = SLOW_GROUND_MAX_SPEED * direction
			starting_velocity = velocity.x if !to_zero else velocity.x - (SLOW_GROUND_MAX_SPEED * (velocity.x / abs(velocity.x)))
			acceleration_time = SLOW_GROUND_MAX_ACC_TIME if !to_zero else SLOW_GROUND_MAX_DEC_TIME
			
			if(to_zero):
				target_speed = SLOW_GROUND_MAX_SPEED * (velocity.x / abs(velocity.x))
				temp_variable = acceleration_time + acceleration_time * starting_velocity / (8 * target_speed)
				movenment_curve_max_frame = int( sqrt(((starting_velocity * temp_variable * temp_variable) / target_speed) + (temp_variable * temp_variable)) )
		
		3:  ##  Ice Ground
			target_speed = ICE_GROUND_MAX_SPEED * direction
			starting_velocity = velocity.x if !to_zero else velocity.x - (ICE_GROUND_MAX_SPEED * (velocity.x / abs(velocity.x)))
			acceleration_time = ICE_GROUND_MAX_ACC_TIME if !to_zero else ICE_GROUND_MAX_DEC_TIME
			
			if(to_zero):
				target_speed = SLOW_GROUND_MAX_SPEED * (velocity.x / abs(velocity.x))
				temp_variable = acceleration_time + (acceleration_time * starting_velocity / (8 * target_speed))
				movenment_curve_max_frame = int( sqrt(((starting_velocity * temp_variable * temp_variable) / target_speed) + (temp_variable * temp_variable)) )

	print("DEBUG - New curve is generated succesfully : D="
	 + str(direction)
	 + ", Z=" + str(to_zero)
	 + ", T=" + str(target_speed)
	 + ", S=" + str(starting_velocity)
	 + ", V=" + str(velocity.x)
	 + ", A=" + str(acceleration_time)
	 + ", AA=" + str(movenment_curve_max_frame))


func velocity_on_curve(frame : float) -> float:
	if(int(frame) >= movenment_curve_max_frame):
		if(int(frame) > movenment_curve_max_frame): ##	Just in case something is going wrong, this will be a failsafe
			print("Likely PROBLEM found with Grounded's frames if statement prior to the velocity_on_curve() function being called")
		return target_speed if !to_zero else 0.0
	
	var speed : float = 0.0
	if(target_speed == 0.0):
		""" This is the last thing to do before debugging, if it doesn't work in like 5 min of bug fixing, switch approach """
		speed = -1 * (target_speed * (frame + temp_variable) * (frame - temp_variable)) / (temp_variable * temp_variable) + starting_velocity
		return speed
	speed = -1 * (target_speed - starting_velocity) * (frame * (frame - 2 * temp_variable) / (temp_variable * temp_variable)) + starting_velocity
	return speed


##	Is this code not bwutiful

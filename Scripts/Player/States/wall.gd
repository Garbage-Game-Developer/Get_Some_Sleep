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
@onready var C : SpriteHandler = $"../../C"


""" Constants """
@export_group("Into Air")
@export_subgroup("Coyote Time")
@export var COYOTE_TIME : float = 0.15

@export_group("Climbing or Sliding")

@export var KICK_OFF_VELOCITY : float = 150.0		##	The x velocity (px * s) applied to the player when jumping off a wall

@export_subgroup("Normal Wall") # -4.0
@export var NORMAL_CLIMB_SPEED : float = 70.0		##	Maximum speed (px * s) the player can climb
@export var NORMAL_MAX_SLIDE_SPEED : float = -120.0	##	Terminal speed (px * s) the player can slide down the wall
@export var NORMAL_MAX_SPEED_TIME : int = 30		##	Time (Frames) the player takes to reach max slide speed
@export var NORMAL_KICK_POWER : float = 0.9			##	The multiple for how high the player's kick off jump should be

@export_subgroup("Slow Wall") # -1.333
@export var SLOW_CLIMB_SPEED : float = 70.0			##	Maximum speed (px * s) the player can climb
@export var SLOW_MAX_SLIDE_SPEED : float = -80.0	##	Terminal speed (px * s) the player can slide down the wall
@export var SLOW_MAX_SPEED_TIME : int = 60			##	Time (Frames) the player takes to reach max slide speed
@export var SLOW_KICK_POWER : float = 0.9			##	The multiple for how high the player's kick off jump should be

@export_subgroup("Ice Wall") # -9.0
@export var ICE_CLIMB_SPEED : float = 70.0			##	Maximum speed (px * s) the player can climb
@export var ICE_MAX_SLIDE_SPEED : float = -180.0	##	Terminal speed (px * s) the player can slide down the wall
@export var ICE_MAX_SPEED_TIME : int = 20			##	Time (Frames) the player takes to reach max slide speed
@export var ICE_KICK_POWER : float = 0.5			##	The multiple for how high the player's kick off jump should be



""" Internals """
var ACTIVE_STATE : bool = false

var movenment_curve_frame : float = 0
var movenment_curve_max_frame : float = 0
var last_velocity : Vector2 = Vector2.ZERO
var velocity : Vector2 = Vector2.ZERO

var decceleration : float = 0.0	##	Decceleration slope
var max_decc : float = 0.0		##	Maximum decceleration

var grabbing : bool = false
var climbing : bool = false
var was_climbing : bool = false
var new_surface : bool = false


""" DEBUG """
var time : String


var kick_power
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
	
	
	"""  There are 2 sub states of this state, thats down hanging and ledge hanging, and they each have swap to animation sequences that are sub-sub states  """
	
	
	time = "%9.3f" % (float(Time.get_ticks_msec()) / 1000.0)
	
	""" States (Pre Change) """
	var state_change_to : State.s = this_state
	var is_jumping : bool = false
	var is_upward_jump : bool = false
	
	was_climbing = climbing
	grabbing = P.move_vector.x == float(P.wall_direction)
	if(P.is_on_floor()):
		state_change_to = State.s.GROUNDED
	elif(P.on_wall()):
		new_surface = P.new_wall_surface
		if(-P.move_vector.x == float(P.wall_direction) || P.wall_type < 1 || P.stamina <= 0.0):
			climbing = false
			state_change_to = State.s.AIR
			$"../../Timers/CoyoteTimer".start(COYOTE_TIME)
		if(grabbing && ((P.wall_type == 1 && P.normal_climb) || (P.wall_type == 2 && P.slow_climb))):
			climbing = true
		else:
			climbing = false
		
		""" Maybe make it so not holding makes you slide, even if you can climb, because that should always be preffereable """
	else:
		state_change_to = State.s.AIR
		$"../../Timers/CoyoteTimer".start(COYOTE_TIME)
	
	
	""" Actions """
	var new_action = false
	var action_is_punch = false
	if(P.is_action_just_pressed("DASH") && $"../../Timers/DashFloorCooldown".is_stopped()):
		""" Default Key : "Shift"
			Swap to the "Dash" state, from_ground = true   """
		
		if(state_change_to == State.s.AIR && (P.advanced_movenment || P.special_dash)):
			state_change_to = State.s.DASH
			$"../../Timers/DashFloorCooldown".start()
			
		elif(state_change_to != State.s.AIR):
			state_change_to = State.s.DASH
			$"../../Timers/DashFloorCooldown".start()
	
	
	elif(P.is_action_just_pressed("SLIDE")):
		""" Default Key : "C"
			Swap to the "Slide" state, from_ground = true   """
		
		state_change_to = State.s.SLIDE
	
	
	elif(P.is_action_just_pressed("JUMP") || !$"../../Timers/PrecisionJumpTimer".is_stopped()):
		""" Default Key : "Space"
			Swap to the "Jump" state, from_ground = true   """
		
		P.stamina -= 1.0
		state_change_to = State.s.AIR
		is_jumping = true
		is_upward_jump = P.move_vector.y < 0.0
	
	
	else:
		if(P.is_action_just_pressed("ATTACK")):
			""" Default Keys : "F", "V", "Right Mouse Button"
				Sub action that calls the parent's Punch function, and plays an animation   """
			
			##	There might be some weapon thing at some point where you can aim a weapon or orb for a boss fight / other mechanic thing
			#P.Punch()
			new_action = true
			action_is_punch = true
		
		
		elif(P.is_action_just_pressed("INTERACT")):
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
		C.material.set_shader_parameter("white_flash", false)
		match state_change_to:
			State.s.AIR:
				Global.camera.shake(0.0 if P.stamina > 0.0 else (0.4 if is_jumping else 0.8))
				P.current_state = State.s.AIR
				kick_off(is_jumping, is_upward_jump)
				P.Air.new_state(delta, this_state, generate_movenment_package(), is_jumping, kick_power)
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
	
	
	if(climbing):
		##	When grabbing, need to consider vertical inputs to climb up and down
		velocity.y = get_propper_velocity(true)
		velocity.y *= P.speed_boost
	else:
		##	When not grabbing, need to slide down slowly
		if(is_state_new || new_surface || was_climbing != climbing):
			max_decc = NORMAL_MAX_SLIDE_SPEED if P.wall_type == 1 else (SLOW_MAX_SLIDE_SPEED if P.wall_type == 2 else ICE_MAX_SLIDE_SPEED)
			decceleration = get_propper_velocity(false)
			was_climbing = false
		velocity.y = max(velocity.y - decceleration, max_decc)
	velocity.x += 5 * C.left_or_right
	
	#print(time, " DEBUG velocity : V=%8.3f" % velocity.x)
	
	if(climbing && velocity.y != 0.0):
		P.stamina -= delta
	elif(climbing):
		P.stamina -= delta / 3.0
	else:
		P.stamina -= delta / 10.0
	
	if(P.stamina <= 1.0):
		C.material.set_shader_parameter("white_flash", !$BlinkTimeout.is_stopped())
		if($BlinkTimeout.is_stopped() && $LastBlink.is_stopped()):
			$BlinkTimeout.start()
			$LastBlink.start()
	
	""" Animations to Play """
	if(!new_action):
		
		if(P.just_switched_directions):
			C.change_facing(P.left_or_right)
		
		"""  Movenment Animations  """
		
		if(abs(velocity.y) <= 10.0):
			C.play(C.WALL if climbing else C.WALL_SLIDING)
		
		elif(velocity.y < -10.0):  ##  Going up
			C.play(C.WALL_CLIMB_UP)
		
		elif(velocity.y >= 0.0):  ##  Going down
			C.play(C.WALL_CLIMB_DOWN if climbing else C.WALL_SLIDING)
		
	else:
		
		"""  Action Animations  """
		
		pass
		
		##	Will need to receive the interaction type to figure out what kind of animation to play, might have to cutscene it
	
	
	"""  Scale Stuff  """
	C.scale = Vector2.ONE
	
	
	is_state_new = false
	
	""" Physics """
	P.velocity = velocity * 60.0 * delta


func deterine_if_swap_state() -> bool:
	var temp_bool = P.move_vector.x == float(P.wall_direction)
	temp_bool = temp_bool && (P.wall_type > 0 && (P.ice_slide || P.wall_type != 3))
	return temp_bool


var upward_jump : bool = false
func kick_off(jump : bool, up_jump : bool):
	upward_jump = up_jump
	if(jump && !upward_jump):
		P.velocity.x = KICK_OFF_VELOCITY * (1.2 if P.move_vector.x == float(P.wall_direction) else 1.0) * -P.wall_direction
	else:
		P.velocity.x = (KICK_OFF_VELOCITY / 20.0) * -P.wall_direction


func generate_movenment_package() -> Array:
	##	Intended starting velocity of the curve (if there is one), is moving allong the curve still
	return [true, 0.0]


##	Gets the y velocity when you're climbing
func get_propper_velocity(grab) -> float:
	
	var multiplier : float = P.move_vector.y
	var temp_velocity : float  = 0.0
	if(grab):
		match P.wall_type:
			
			1:	##	Normal Surface
				temp_velocity = NORMAL_CLIMB_SPEED
			
			2:	##	Slow Surface
				temp_velocity = SLOW_CLIMB_SPEED
			
			3:	##	Ice Surface
				temp_velocity = ICE_CLIMB_SPEED
			
			0:	##	No Proper Contact
				temp_velocity = 100
		
		temp_velocity *= multiplier
		
	else:
		match P.wall_type:
			
			1:	##	Normal Surface
				temp_velocity = NORMAL_MAX_SLIDE_SPEED / NORMAL_MAX_SPEED_TIME
			
			2:	##	Slow Surface
				temp_velocity = SLOW_MAX_SLIDE_SPEED / SLOW_MAX_SPEED_TIME
			
			3:	##	Ice Surface
				temp_velocity = ICE_MAX_SLIDE_SPEED / ICE_MAX_SPEED_TIME
			
			0:	##	No Proper Contact
				temp_velocity = 100
	
	return temp_velocity

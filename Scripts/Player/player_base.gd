class_name Player extends CharacterBody2D


""" States """
@onready var Air : AirState = $S/Air
#@onready var Dash : DashState = $S/Dash
#@onready var Dazed : DazedState = $S/Dazed
#@onready var Floating : FloatingState = $S/Floating
#@onready var Frozen : FrozenState = $S/Frozen
#@onready var Ghost : GhostState = $S/Ghost
@onready var Grounded : GroundedState = $S/Grounded
#@onready var Kick : KickState = $S/Kick
#@onready var Slide : SlideState = $S/Slide
#@onready var Swim : SwimState = $S/Swim
#@onready var Swing : SwingState = $S/Swing
#@onready var Wall : WallState = $S/Wall
#@onready var Dead : DeadState = $S/Dead
#@onready var Cutscene : CutsceneState = $S/Cutscene

var current_state : State.s = State.s.GROUNDED
var walk_mode : bool = false  ##  A special grounded state and falling state where most actions are locked


""" Exports """
##	

##	Unique Player Variables
#  Player can swim
@export var can_swim : bool = false

#  Player can punch and air kick, sliding does half damage (rounded up) and upward knockback, dash does half damage (rounded up) and forward knockback
@export var combat_skills : bool = false
@export var combat_power : int = 5  #  Damage done by attacks

#  Allows for ground dash, wall dash, and swinging
@export var basic_movenment : bool = false

#  Allows for air normal dash, swinging dash, and advanced climbing
@export var advanced_movenment : bool = false

#  Allows for air double jump under a condition
@export var item_double_jump : bool = false  

#  Allows for air double jump with no conditional
@export var free_double_jump : bool = false

#  Allows for special dash variation on ground, air, and water
@export var special_dash : bool = false


@export var able_special : bool = false  ##  Can double jump and dash in air, can consume more pills
@export var able_swing : bool = false  ##  Can use swingables
@export var able_attack : bool = false  ##  Can punch and kick
@export var able_expert_wall : bool = false  ##  Can no slide down wall grab (Won't matter on ice), and free dash off of wall
@export var able_fast_swim : bool = false  ##  Move quickly in water, and can water dash


""" Variables """
##	External Variables
var player_id : int = 0  ##  This will be used when there are multiple player characters instantiated, and we want to check who is who


##	Constants
# Gravity
const BASE_GRAVITY : Vector2 = Vector2(0.0, -900)

# Jump force
const JUMP_FORCE : float = -600
const DOUBLE_JUMP_FORCE : float = -500
const WATER_JUMP_FORCE : float = -900  ##  Force upon jumping out of water while surfaced

# Movenment speed
const AIR_SPEED : float = 125  ##  Pixel acceleration in air (px/s)
const SWIM_SPEED_BASE : float = 250  ##  Pixel acceleration in water (px/s)

# Slide
const SLIDE_SPEED_BOOST : float = 100  ##  Extra velocity added when sliding, in a sliding state all friction is accounted for
const SLIDE_GROUND_REQ_TIME : float = 0.4  ##  Time required to slide for until you can leave (seconds)
const SLIDE_AIR_REQ_TIME : float = 0.2  ##  Time required to slide for until you can leave (seconds)
const SLIDE_VELOCITY_CUTOFF : float = 150  ##  lowest velocity until you're kicked out of sliding animation

# Max speed and friction
## Little note here, NO friction in air, but also very slow air accelerations
const AIR_MAX_SPEED : float = 2400  ##  Max speed in the air (horizontal vector)
const AIR_MAX_FALL_SPEED : float = 1200  ##  Max speed in air (vertical vector)
const SURFACE_MAX_SPEED : float = 300  ##  Max speed on normal surfaces
const SURFACE_FRICTION : float = 0.2  ##  Friction coefficient (Not quite sure how to use this yet \: )
const WALK_MAX_SPEED : float = 150  ##  Max speed while in walk state
const WATER_FRICTION : float = 0.3  ##  Coefficient of friction


# Dash
const GROUND_DASH_SPEED : float = 600  ##  Speed gained when dashing
const AIR_DASH_SPEED : float = 800  ##  Speed gained when dashing
const DASH_GROUND_REQ_TIME : float = 0.3  ##  Time required to slide for until you can leave (seconds)
const DASH_GROUND_MAX_TIME : float = 0.5  ##  Max time in the dash state (seconds)
const DASH_AIR_REQ_TIME : float = 0.4  ##  Time required to slide for until you can leave (seconds)
const DASH_AIR_MAX_TIME : float = 0.6  ##  Max time in the dash state (seconds)


##	Internal Variables (Extends to states)
# available actions
var passive_state = false  ##  Most animations locked, can only walk
var special_available = true  ##  Can double jump or dash mid air
var has_dashed_in_air = false  ##  Has dashed in the air

# physics manipulation
var speed_boost : float = 1.0  ##  Boosts to all speed stuff
var layered_gravity : Vector2 = Vector2.ZERO  ##  Things like wind and extra gravity that are applied outside of the state

# Animations
var left_or_right : bool = false  ## false for left, true for right

# Rays


# Simple internals
var move_vector : Vector2 = Vector2.ZERO


""" Godot Built-In Functions """
func _ready():
	""" Check for global prefrences for controls and set the corresponding internal variables """
	pass


func _physics_process(delta):
	
	##	Check velocity rays and other state related stuff
	move_vector = left_right_priority(Input.is_action_pressed("LEFT"), Input.is_action_pressed("RIGHT"))
	
	"""
	
		The current error is a dividing by 0 error, and I need to find a solution for decceleration/acceleration top zero in that case
		
		One idea is to have height = starting velocity, and then get the velocity of frame + max frames up to the max point, because that
		will end on zero, but the problem with this is that I lose all scaling for the varying starting velocities in time, so they'll always take
		the same time to decelerate to zero
	
	"""
	
	""" State Machine """
	
	##	The state process
	var new_state = false
	match current_state:
		State.s.AIR:
			Air.update(delta)		##	Unfinished - Working on
		#State.s.DASH:
			#Dash.update(delta)		##	Unfinished
		#State.s.DAZED:
			#Dazed.update(delta)		##	Unfinished
		#State.s.FLOATING:
			#Floating.update(delta)		##	Unfinished
		#State.s.FROZEN:
			#Frozen.update(delta)		##	Unfinished
		#State.s.GHOST:
			#Ghost.update(delta)		##	Unfinished
		State.s.GROUNDED:
			Grounded.update(delta)				##	Unfinished - Prototyped (Needs review)
		#State.s.KICK:
			#Kick.update(delta)		##	Unfinished
		#State.s.SLIDE:
			#Slide.update(delta)		##	Unfinished
		#State.s.SWIM:
			#Swim.update(delta)		##	Unfinished
		#State.s.SWING:
			#Swing.update(delta)		##	Unfinished
		#State.s.WALL:
			#Wall.update(delta)		##	Unfinished
		#State.s.DEAD:
			#Dead.update(delta)		##	Unfinished
		#State.s.CUTSCENE:
			#Cutscene.update(delta)		##	Unfinished
	
	""" End of process """
	
	#velocity *= Global.time_speed  ##  Sets it to the speed of the game
	
	##	Set Velocity Rays
	$GroundTypeRays/VelocityBouncePad.target_position = velocity
	$WallTypeRays/VelocityBouncePadHigh.target_position = velocity + (Vector2(6.0, 0.0) if velocity.x > 0.0 else Vector2(-6.0, 0.0))
	$WallTypeRays/VelocityBouncePadLow.target_position = velocity + (Vector2(6.0, 0.0) if velocity.x > 0.0 else Vector2(-6.0, 0.0))
	$ConvenienceRays/VelocityClamber.target_position = velocity
	$ConvenienceRays/VelocityOver.target_position = velocity
	$ConvenienceRays/VelocityNextPosition.target_position = velocity
	$ConvenienceRays/VelocityCeilingSnapLeft.target_position.y = minf(0, velocity.y)
	$ConvenienceRays/VelocityCeilingSnapRight.target_position.y = minf(0, velocity.y)
	$ConvenienceRays/VelocityCeilingLeft.target_position.y = minf(0, velocity.y)
	$ConvenienceRays/VelocityCeilingRight.target_position.y = minf(0, velocity.y)
	
	
	$GroundTypeRays/VelocityBouncePad.force_update_transform()			##	Checks if the next frame will interact with a bouncepad on the ground
	$WallTypeRays/VelocityBouncePadHigh.force_update_transform()		##	Checks if the next frame will interact with a bouncepad on the wall
	$WallTypeRays/VelocityBouncePadLow.force_update_transform()			##	Checks if the next frame will interact with a bouncepad on the wall
	$ConvenienceRays/VelocityClamber.force_update_transform()			##	Checks if you can't clamber over a ledge next frame
	$ConvenienceRays/VelocityOver.force_update_transform()				##	Checks if you can't snap over a ledge next fram
	$ConvenienceRays/VelocityNextPosition.force_update_transform()		##	Checks if you're colliding with a surface or the ground next frame
	$ConvenienceRays/VelocityCeilingSnapLeft.force_update_transform()	##	Checks if you can't snap around the ceiling next frame
	$ConvenienceRays/VelocityCeilingSnapRight.force_update_transform()	##	Checks if you can't snap around the ceiling next frame
	$ConvenienceRays/VelocityCeilingLeft.force_update_transform()		##	Checks if you're colliding with the ceiling next frame
	$ConvenienceRays/VelocityCeilingRight.force_update_transform()		##	Checks if you're colliding with the ceiling next frame
	
	$GroundTypeRays/VelocityBouncePad.force_raycast_update()
	$WallTypeRays/VelocityBouncePadHigh.force_raycast_update()
	$WallTypeRays/VelocityBouncePadLow.force_raycast_update()
	$ConvenienceRays/VelocityClamber.force_raycast_update()
	$ConvenienceRays/VelocityOver.force_raycast_update()
	$ConvenienceRays/VelocityNextPosition.force_raycast_update()
	$ConvenienceRays/VelocityCeilingSnapLeft.force_raycast_update()
	$ConvenienceRays/VelocityCeilingSnapRight.force_raycast_update()
	$ConvenienceRays/VelocityCeilingLeft.force_raycast_update()
	$ConvenienceRays/VelocityCeilingRight.force_raycast_update()
	
	##	Check Velocity Rays (And call actions)
	match current_state:
		State.s.AIR:
			"""
				Check if can clamber, over, or ceiling snap, also bounce pads on walls or floors
			"""
			pass	##	Unfinished
		State.s.DASH:
			"""
				Check if can clamber, over, or ceiling snap, also bounce pads on walls or floors
			"""
			pass	##	Unfinished
		State.s.GROUNDED:
			"""
				Check if there's bounce pads on floors
			"""
			pass	##	Unfinished
		State.s.KICK:
			"""
				Check if there's bounce pads on floors
			"""
			pass	##	Unfinished
		State.s.SLIDE:
			"""
				Check if can clamber, over, or ceiling snap, also bounce pads on walls and floors
			"""
			pass	##	Unfinished
		State.s.SWIM:
			pass	##	Unfinished
		State.s.SWING:
			pass	##	Unfinished
		State.s.WALL:
			"""
				Check if there's bounce pads on walls and floors
			"""
			pass	##	Unfinished
	
	#pingpong()
	move_and_slide() # Might do this first, idk



""" Interference """
var interference : bool = false  ## If something has interfered with the player, causing a new movenment curve to need generating
var interference_vector : Vector2
func player_interference(int_vector : Vector2, int_location : Vector2, do_rotation : bool = true, time_freeze : float = 0.0):
	interference = true
	var int_rotation = global_position.angle_to(int_location)
	if(do_rotation):
		interference_vector = int_vector.rotated(int_rotation)
	else:
		interference_vector = int_vector



""" Internal Functions """
var just_switched_directions : bool = false
var left_hold : bool = false  ##  LEFT been pressed for longer than a frame
var right_hold : bool = false  ##  RIGHT been pressed for longer than a frame
func left_right_priority(left_pressed : bool, right_pressed : bool) -> Vector2:
	if(right_pressed):
		if(!left_pressed):  ##  RIGHT is the 'only' button pressed
			just_switched_directions = !left_or_right || !right_hold ##  if was left, switch directions
			left_hold = false
			left_or_right = true
			right_hold = true
			return Vector2.RIGHT
		else:
			if(!right_hold):  ##  RIGHT was 'just' pressed and LEFT is down
				just_switched_directions = !left_or_right  ##  if was left, switch directions
				left_or_right = true
				right_hold = true
				return Vector2.RIGHT
			else:
				if(!left_hold):  ##  LEFT was 'just' pressed and RIGHT is down
					just_switched_directions = left_or_right  ##  if was right, switch directions
					left_or_right = false
					left_hold = true
					return Vector2.LEFT
				if(left_or_right):  ##  RIGHT was 'most recently' pressed and LEFT is down
					just_switched_directions = false
					return Vector2.RIGHT
	if(left_pressed):  ##  LEFT is the 'only' button pressed, 'or' LEFT was 'most recently' pressed and RIGHT is down
		just_switched_directions = left_or_right || !left_hold  ##  if was right, switch directions
		right_hold = right_pressed
		left_or_right = false
		left_hold = true
		return Vector2.LEFT
	just_switched_directions = left_hold || right_hold
	left_hold = false
	right_hold = false
	return Vector2.ZERO


""" External Functions """
##	A function that other nodes can call to apply velocity to the player (explosions and bounce pads)
func knockback(applied_force: Vector2, freeze_time: float = 0.0, freeze_intensity = 0.0):
	velocity += applied_force
	if(freeze_time != 0.0):
		Global.time_freeze(freeze_time, freeze_intensity)


""" Signals """
var special_areas : int = 0
func _on_special_zone_area_entered(_area: Area2D) -> void:
	special_areas += 1
func _on_special_zone_area_exited(_area: Area2D) -> void:
	special_areas -= 1



""" Signal Connections """


""" To-Do
- Player Sprites
	- Advanced Climbing animations
	- Swiming animations (A whole lot of them)
	- Diagonal Kick animation
	- Interact animation
	- Punch animation
	- Air Punch animation
	- Switch all animations to be connected (no seperation between upper and lower body)
	- Have a left facing animated_sprite node and a right facing, and swap them between shown and hidden as needed
	
	- Rework all sprites so that they aren't screwed when there's a little bit of screen tearing (do this later)
- The code?
	- Code the wall and ground detectors
	- Code player movenment in the normal state
		- Code a testing level
			- Quick restart code for level and player
			- Starting point from room starts, or checkpoints
- Sprites for consumables
	- Keys
	- Pills
	- Attackables
	- Interactables
	- Breakables/Down Kickables
"""

""" Notes
- Have player's velocity usable as damage against surfaces and enemies, and punching, kicking, or being in a slide can amplify the damage on contact
"""

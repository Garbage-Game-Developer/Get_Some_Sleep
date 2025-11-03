class_name Player extends CharacterBody2D


""" States """
enum State { AIR = 0, DASH = 1, GROUNDED = 2, JUMP = 3, KICK = 4, SLIDE = 5, SWIM = 6, SWING = 7, WALL = 8, DEAD = -1 }
@onready var Air : AirState = $S/Air
@onready var Dash : DashState = $S/Dash
@onready var Grounded : GroundedState = $S/Grounded
@onready var Jump : JumpState = $S/Jump
@onready var Kick : KickState = $S/Kick
@onready var Slide : SlideState = $S/Slide
@onready var Swim : SwimState = $S/Swim
@onready var Swing : SwingState = $S/Swing
@onready var Wall : WallState = $S/Wall
@onready var Dead : DeadState = $S/Dead

var current_state : State = State.GROUNDED
var last_state : State = State.GROUNDED
var walk_mode : bool = false  ##  A special grounded state and falling state where most actions are locked

""" Other Exports """
##	

##	Unique Player Variables
@export var able_special : bool = true  ##  Can double jump and dash in air, can consume more pills
@export var able_swing : bool = true  ##  Can use swingables
@export var able_attack : bool = true  ##  Can punch and kick
@export var able_expert_wall : bool = true  ##  Can no slide down wall grab (Won't matter on ice), and free dash off of wall
@export var able_fast_swim : bool = true  ##  Move quickly in water, and can water dash

""" Internal Variables """
##	External Variables


##	Constants
# Gravity
const BASE_GRAVITY : Vector2 = Vector2(0.0, -900)

# Jump force
const JUMP_FORCE : float = -600
const DOUBLE_JUMP_FORCE : float = -500
const WATER_JUMP_FORCE : float = -900  ##  Force upon jumping out of water while surfaced

# Movenment speed
const BASE_SPEED : float = 650  ##  Pixel acceleration at base???
const GROUND_SPEED : float = 1200  ##  Pixel acceleration on any ground (px/s)
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

# Slow surface
const SLOW_SURFACE_DEBUFF : float = 0.6  ##  Acceleration percent debuffed
const SLOW_SURFACE_MAX_SPEED : float = 200  ##  Max speed on slow surfaces
const SLOW_SURFACE_FRICTION : float = 0.6  ##  Coefficient of friction

# Ice surface
const ICE_SURFACE_DEBUFF : float = 0.7  ##  Acceleration percent debuffed
const ICE_SURFACE_MAX_SPEED : float = 1500  ##  Max speed on low friction surfaces
const ICE_SURFACE_FRICTION : float = 0.1  ##  Coefficient of friction

# Dash
const GROUND_DASH_SPEED : float = 600  ##  Speed gained when dashing
const AIR_DASH_SPEED : float = 800  ##  Speed gained when dashing
const DASH_GROUND_REQ_TIME : float = 0.3  ##  Time required to slide for until you can leave (seconds)
const DASH_GROUND_MAX_TIME : float = 0.5  ##  Max time in the dash state (seconds)
const DASH_AIR_REQ_TIME : float = 0.4  ##  Time required to slide for until you can leave (seconds)
const DASH_AIR_MAX_TIME : float = 0.6  ##  Max time in the dash state (seconds)


##	Internal Variables (Extends to states)
# available actions
var special_available = true  ##  Can double jump or dash mid air
var has_dashed_in_air = false  ##  Has dashed in the air

# physics manipulation
var speed_boost : float = 1.0  ##  Boosts to all speed stuff
var layered_gravity : Vector2 = Vector2.ZERO  ##  Things like wind and extra gravity that are applied outside of the state

# Animations
var left_or_right : bool = false  ## false for left, true for right
var left_right_vector : Vector2 = Vector2.ZERO

# Rays



""" Godot Built-In Functions """
func _ready():
	""" Check for global prefrences for controls and set the corresponding internal variables """
	pass


var changed_states = false
func _process(delta):
	
	##	Check velocity rays and other state related stuff
	left_right_vector = left_right_priority(Input.is_action_pressed("LEFT"), Input.is_action_pressed("RIGHT"))
	
	
	
	""" State Machine """
	changed_states = false
	check_new_state()  ##  Checks what state it should be
	
	##	The state process
	var new_state = current_state == last_state
	last_state = current_state
	match current_state:
		State.AIR:
			Air.update(delta, new_state)		##	Unfinished
		State.DASH:
			Dash.update(delta, new_state)		##	Unfinished
		State.GROUNDED:
			Grounded.update(delta, new_state)	##	Unfinished
		State.JUMP:
			Jump.update(delta, new_state)		##	Unfinished
		State.KICK:
			Kick.update(delta, new_state)		##	Unfinished
		State.SLIDE:
			Slide.update(delta, new_state)		##	Unfinished
		State.SWIM:
			Swim.update(delta, new_state)		##	Unfinished
		State.SWING:
			Swing.update(delta, new_state)		##	Unfinished
		State.WALL:
			Wall.update(delta, new_state)		##	Unfinished
		
		State.DEAD:
			Dead.update(delta, new_state)		##	Unfinished
	
	""" End of process """
	
	velocity *= Global.time_speed  ##  Sets it to the speed of the game
	
	##	Set Velocity Rays
	$GroundTypeRays/VelocityBouncePad.target_position = velocity
	$ConvenienceRays/VelocityClamber.target_position = velocity
	$ConvenienceRays/VelocityOver.target_position = velocity
	$ConvenienceRays/VelocityNextPosition.target_position = velocity
	$ConvenienceRays/VelocityCeilingSnapLeft.target_position.y = minf(0, velocity.y - 16.0)
	$ConvenienceRays/VelocityCeilingSnapRight.target_position.y = minf(0, velocity.y - 16.0)
	
	##	Check Velocity Rays (And call actions)
	match current_state:
		State.AIR:
			"""
				Check if can clamber, over, or ceiling snap, also bounce pads on walls or floors
			"""
			pass	##	Unfinished
		State.DASH:
			"""
				Check if can clamber, over, or ceiling snap, also bounce pads on walls or floors
			"""
			pass	##	Unfinished
		State.GROUNDED:
			pass	##	Unfinished
		State.JUMP:
			"""
				Check if can clamber, over, or ceiling snap, also bounce pads on walls
			"""
			pass	##	Unfinished
		State.KICK:
			"""
				Check if there's bounce pads
			"""
			pass	##	Unfinished
		State.SLIDE:
			"""
				Check if can clamber, over, or ceiling snap, also bounce pads on walls and floors
			"""
			pass	##	Unfinished
		State.SWIM:
			pass	##	Unfinished
		State.SWING:
			pass	##	Unfinished
		State.WALL:
			"""
				Check if there's bounce pads on walls and floors
			"""
			pass	##	Unfinished
	
	
	move_and_slide() # Might do this first, idk


""" Internal Functions """
func check_new_state(overwrite_priority : bool = false):
	
	##	First check if triggered jump pad so you don't swap states yet
	""" ^ WIP ^  """
	
	##	(Priority 0) If dead, stops it from checking other state stuff
	##	(Priority 0) If swinging, don't bother checking other stuff
	if(current_state == State.DEAD || current_state == State.SWING):
		return
	
	##	(Priority 1) Checks if in water to swap to water 
	if($InWater.has_overlapping_areas()):
		if(current_state != State.SWIM):
			current_state = State.SWIM
			changed_states = true
		return
	
	##	(Priority 2 and 3) Slide and Kick are triggered in other states, and swap to other states from within
	if(!overwrite_priority && (current_state == State.SLIDE || current_state == State.KICK)):
		return
	
	##	(Priority 4) Checks if only on the wall, and not exit from wall
	if(is_on_wall_only()):
		##	Need to check if intentionally released from wall before this
		""" ^ WIP ^ """
		if(current_state != State.WALL):
			current_state = State.WALL
			changed_states = true
		return
	
	##	(Priority 5) Checks if only on floor
	if(is_on_floor()):
		if(current_state != State.GROUNDED):
			current_state = State.GROUNDED
			changed_states = true
		return
	
	##	(Priority 6) Checks if only in air and not doing other stuff
	if(current_state != State.AIR):
		current_state = State.AIR
		changed_states = true


var just_switched_directions : bool = false
var left_hold : bool = false  ##  LEFT been pressed for longer than a frame
var right_hold : bool = false  ##  RIGHT been pressed for longer than a frame
func left_right_priority(left_pressed : bool, right_pressed : bool) -> Vector2:
	just_switched_directions = true
	if(right_pressed):
		if(!left_pressed):  ##  RIGHT is the 'only' button pressed
			just_switched_directions = !left_or_right  ##  if was left, switch directions
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
					return Vector2.RIGHT
	if(left_pressed):  ##  LEFT is the 'only' button pressed, 'or' LEFT was 'most recently' pressed and RIGHT is down
		just_switched_directions = left_or_right  ##  if was right, switch directions
		right_hold = right_pressed
		left_or_right = false
		left_hold = true
		return Vector2.LEFT
	
	left_hold = false
	right_hold = false
	return Vector2.ZERO


""" External Functions """
##	A function that other nodes can call to apply velocity to the player (explosions and bounce pads)
func knockback(applied_force: Vector2, freeze_time: float = 0.0, freeze_intensity = 0.0):
	velocity += applied_force
	if(freeze_time != 0.0):
		Global.time_freeze(freeze_time, freeze_intensity)


""" Signal Connections """


""" To-Do
- Player Sprites
	- Advanced Climbing animations
	- Swiming animations
	- Diagonal Kick animation
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

class_name Player extends CharacterBody2D


""" States """
enum State { AIR = 0, GROUNDED = 1, KICK = 2, SLIDE = 3, SWIM = 4, SWING = 5, WALL = 6, DEAD = -1 }
@onready var Air : AirState = $S/Air					#	     (6 Priority)
@onready var Grounded : GroundedState = $S/Grounded		#	    (5 Priority)
@onready var Kick : KickState = $S/Kick					#	 (2 Priority)
@onready var Slide : SlideState = $S/Slide				#	  (3 Priority)
@onready var Swim : SwimState = $S/Swim					#	(1 Priority)
@onready var Swing : SwingState = $S/Swing				#  (0 Priority)
@onready var Wall : WallState = $S/Wall					#	   (4 Priority)
@onready var Dead : DeadState = $S/Dead					#  (0 Priority)

var current_state : State = State.GROUNDED
var last_state : State = State.GROUNDED

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
const BASE_SPEED : float = 350  ##  Pixel acceleration on any ground (px/s)
const AIR_SPEED : float = 125  ##  Pixel acceleration in air (px/s)
const SWIM_SPEED_BASE : float = 250  ##  Pixel acceleration in water (px/s)

# Slide
const SLIDE_SPEED_BOOST : float = 100  ##  Extra velocity added when sliding, in a sliding state all friction is accounted for
const SLIDE_GROUND_REQ_TIME : float = 0.4  ##  Time required to slide for until you can leave (seconds)
const SLIDE_AIR_REQ_TIME : float = 0.2  ##  Time required to slide for until you can leave (seconds)
const SLIDE_VELOCITY_CUTOFF : float = 150  ##  lowest velocity until you're kicked out of sliding animation

# Max speed and friction
## Little note here, NO friction in air, but also very slow air accelerations
const AIR_MAX_SPEED : float = 2400
const SURFACE_MAX_SPEED : float = 300  ##  Max speed on normal surfaces
const SURFACE_FRICTION : float = 0.2  ##  Friction coefficient (Not quite sure how to use this yet \: )
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
var dashing = false  ##  Currently dashing as an action

# physics manipulation
var speed_boost : float = 1.0  ##  Boosts to all speed stuff
var layered_gravity : Vector2 = Vector2.ZERO  ##  Things like wind and extra gravity that are applied outside of the state


""" Godot Built-In Functions """
func _ready():
	""" Check for global prefrences for controls and set the corresponding internal variables """
	pass


var changed_states = false
func _process(delta):
	
	""" State Machine """
	changed_states = false
	check_new_state()  ##  Checks what state it should be
	
	##	The state process
	var new_state = current_state == last_state
	last_state = current_state
	match State:
		0:	##	AIR
			Air.update(delta, new_state)
		1:	##	GROUNDED
			Grounded.update(delta, new_state)
		2:	##	KICK
			Kick.update(delta, new_state)
		3:	##	SLIDE
			Slide.update(delta, new_state)
		4:	##	SWIM
			Swim.update(delta, new_state)
		5:	##	SWING
			Swing.update(delta, new_state)
		6:	##	WALL
			Wall.update(delta, new_state)
		-1:	##	DEAD
			Dead.update(delta, new_state)
	
	""" End of process """
	if(!(dashing && able_special)):
		velocity += layered_gravity * delta
	
	velocity *= Global.time_speed  ##  Sets it to the speed of the game
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

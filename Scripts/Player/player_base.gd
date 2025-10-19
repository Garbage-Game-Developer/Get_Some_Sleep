class_name Player extends CharacterBody2D


""" States """
enum State { AIR = 0, GROUNDED = 1, KICK = 2, SLIDE = 3, SWIM = 4, WALL = 5, DEAD = 6 }
@onready var Air : AirState = $S/Air
@onready var Grounded : GroundedState = $S/Grounded
@onready var Kick : KickState = $S/Kick
@onready var Slide : SlideState = $S/Slide
@onready var Swim : SwimState = $S/Swim
@onready var Wall : WallState = $S/Wall
@onready var Dead : DeadState = $S/Dead


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


##	Enums


##	Constants
# BASE variables
const BASE_GRAVITY : float = 900

const JUMP_FORCE : float = -600
const DOUBLE_JUMP_FORCE : float = -500
const WATER_JUMP_FORCE : float = -900  ##  Force upon jumping out of water while surfaced

const BASE_SPEED : float = 350  ##  Pixel acceleration on any ground (px/s)
const AIR_SPEED : float = 125  ##  Pixel acceleration in air (px/s)
const SWIM_SPEED_BASE : float = 250  ##  Pixel acceleration in water (px/s)
const SLIDE_SPEED_BOOST : float = 100  ##  Extra velocity added when sliding, in a sliding state all friction is accounted for
const SLIDE_GROUND_REQ_TIME : float = 0.4  ##  Time required to slide for until you can leave (seconds)
const SLIDE_AIR_REQ_TIME : float = 0.2  ##  Time required to slide for until you can leave (seconds)
const SLIDE_VELOCITY_CUTOFF : float = 150  ##  lowest velocity until you're kicked out of sliding animation

## Little note here, NO friction in air, but also very slow air accelerations
# const AIR_MAX_SPEED : float = 1600
const SURFACE_MAX_SPEED : float = 300  ##  Max speed on normal surfaces
const SURFACE_FRICTION : float = 0.2  ##  Friction coefficient (Not quite sure how to use this yet \: )
const WATER_FRICTION : float = 0.3  ##  Coefficient of friction

const SLOW_SURFACE_DEBUFF : float = 0.6  ##  Acceleration percent debuffed
const SLOW_SURFACE_MAX_SPEED : float = 200  ##  Max speed on slow surfaces
const SLOW_SURFACE_FRICTION : float = 0.6  ##  Coefficient of friction

const ICE_SURFACE_DEBUFF : float = 0.7  ##  Acceleration percent debuffed
const ICE_SURFACE_MAX_SPEED : float = 1500  ##  Max speed on low friction surfaces
const ICE_SURFACE_FRICTION : float = 0.1  ##  Coefficient of friction

const GROUND_DASH_SPEED : int = 600  ##  Speed gained when dashing
const AIR_DASH_SPEED : int = 800  ##  Speed gained when dashing
const DASH_GROUND_REQ_TIME : float = 0.6  ##  Time required to slide for until you can leave (seconds)
const DASH_AIR_REQ_TIME : float = 0.4  ##  Time required to slide for until you can leave (seconds)


##	Internal Variables
# can whatever with bools attached based on actions n stuff


""" Godot Built-In Functions """


func _ready():
	""" Check for global prefrences for controls and set the corresponding internal variables """
	pass


func _process(delta):
	pass
	
	
	""" State Machine """
	##	Checks what state it should be
	
	
	
	##	Runs the state process
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
		5:	##	WALL
			Wall.update(delta, new_state)
		6:	##	DEAD
			Dead.update(delta, new_state)
	
	""" End of process """
	move_and_slide() ## Might do this first, idk


""" Internal Functions """


""" External Functions """


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

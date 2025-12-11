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
@onready var Wall : WallState = $S/Wall
#@onready var Dead : DeadState = $S/Dead
#@onready var Cutscene : CutsceneState = $S/Cutscene

var current_state : State.s = State.s.GROUNDED
var walk_mode : bool = false  ##  A special grounded state and falling state where most actions are locked


""" Exports """
@export var DEBUG : bool = false

##	Unique Player Variables
@export_group("Player Spacific Variables")
@export var PLAYER_NAME  : String = "'"


@export_subgroup("Player Capabilities")

@export var can_swim : bool = false  #  Player can swim

#	Player can punch and air kick, sliding does half damage (rounded up) and upward knockback, dash does half damage (rounded up) and forward knockback
@export var combat_skills : bool = false
@export var combat_power : int = 5  #  Damage done by attacks

@export var basic_movenment : bool = false  #  Allows for ground dash, wall dash, and swinging
@export var advanced_movenment : bool = false  #  Allows for air normal dash, swinging dash, and advanced climbing

@export var item_double_jump : bool = false  #  Allows for air double jump under a condition
@export var free_double_jump : bool = false  #  Allows for air double jump with no conditional

@export var special_dash : bool = false  #  Allows for special dash variation on ground, air, and water

@export var slow_climb : bool = false  #  Allows for the player to climb on slow surfaces
@export var advanced_climb : bool = false  #  Allows for the player to climb on normal surfaces
@export var ice_slide : bool = false  #  Allows for the player to slide down on ice surfaces


##	Still working on / haven't started
@export var able_swing : bool = false  ##  Can use swingables
@export var able_fast_swim : bool = false  ##  Move quickly in water, and can water dash


""" Variables """
##	External Variables
var player_id : int = 0  ##  This will be used when there are multiple player characters instantiated, and we want to check who is who


##	Constants
# Movenment speed
const SWIM_SPEED_BASE : float = 250  ##  Pixel acceleration in water (px/s)

# Slide
const SLIDE_SPEED_BOOST : float = 100  ##  Extra velocity added when sliding, in a sliding state all friction is accounted for
const SLIDE_GROUND_REQ_TIME : float = 0.4  ##  Time required to slide for until you can leave (seconds)
const SLIDE_AIR_REQ_TIME : float = 0.2  ##  Time required to slide for until you can leave (seconds)
const SLIDE_VELOCITY_CUTOFF : float = 150  ##  lowest velocity until you're kicked out of sliding animation

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
var wall_direction : int = 1


""" Godot Built-In Functions """
func _ready():
	""" Check for global prefrences for controls and set the corresponding internal variables """
	if(!DEBUG):
		load_player_stats()
	


func _physics_process(delta):
	
	##	Check velocity rays and other state related stuff
	move_vector = left_right_priority(Input.is_action_pressed("LEFT"), Input.is_action_pressed("RIGHT"))
	
	wall_direction = 1 if $WallTypeRays/WallRight.is_colliding() else (-1 if $WallTypeRays/WallLeft.is_colliding() else 0)
	
	
	""" State Machine """
	
	##	The state process
	match current_state:
		State.s.AIR:
			##	Call the velocity ray checks first
			Air.update(delta)			##	Unfinished - Prototyped (Needs review)
		#State.s.DASH:
			#Dash.update(delta)			##	Unfinished
		#State.s.DAZED:
			#Dazed.update(delta)		##	Unfinished
		#State.s.FLOATING:
			#Floating.update(delta)		##	Unfinished
		#State.s.FROZEN:
			#Frozen.update(delta)		##	Unfinished
		#State.s.GHOST:
			#Ghost.update(delta)		##	Unfinished
		State.s.GROUNDED:
			##	Call the velocity ray checks first
			Grounded.update(delta)		##	Unfinished - Prototyped (Needs review)
		#State.s.KICK:
			#Kick.update(delta)			##	Unfinished
		#State.s.SLIDE:
			#Slide.update(delta)		##	Unfinished
		#State.s.SWIM:
			#Swim.update(delta)			##	Unfinished
		#State.s.SWING:
			#Swing.update(delta)		##	Unfinished
		State.s.WALL:
			##	Call the velocity ray checks first
			Wall.update(delta)			##	Unfinished - Working on
		#State.s.DEAD:
			#Dead.update(delta)			##	Unfinished
		#State.s.CUTSCENE:
			#Cutscene.update(delta)		##	Unfinished
	
	""" End of process """
	
	velocity *= Global.time_speed  ##  Sets it to the speed of the game
	
	##	Set Velocity Rays
	var temp_velocity = velocity / 60
	$GroundTypeRays/VelocityBouncePad.target_position = temp_velocity
	$WallTypeRays/VelocityBouncePadHigh.target_position = temp_velocity + (Vector2(6.0, 0.0) if temp_velocity.x > 0.0 else Vector2(-6.0, 0.0))
	$WallTypeRays/VelocityBouncePadLow.target_position = temp_velocity + (Vector2(6.0, 0.0) if temp_velocity.x > 0.0 else Vector2(-6.0, 0.0))
	$ConvenienceRays/VelocityClamber.target_position = temp_velocity
	$ConvenienceRays/VelocityOver.target_position = temp_velocity
	$ConvenienceRays/VelocityNextPosition.target_position = temp_velocity
	$ConvenienceRays/VelocityCeilingSnapLeft.target_position.y = minf(0, temp_velocity.y)
	$ConvenienceRays/VelocityCeilingSnapRight.target_position.y = minf(0, temp_velocity.y)
	$ConvenienceRays/VelocityCeilingLeft.target_position.y = minf(0, temp_velocity.y)
	$ConvenienceRays/VelocityCeilingRight.target_position.y = minf(0, temp_velocity.y)
	
	
	#$GroundTypeRays/VelocityBouncePad.force_update_transform()			##	Checks if the next frame will interact with a bouncepad on the ground
	#$WallTypeRays/VelocityBouncePadHigh.force_update_transform()		##	Checks if the next frame will interact with a bouncepad on the wall
	#$WallTypeRays/VelocityBouncePadLow.force_update_transform()			##	Checks if the next frame will interact with a bouncepad on the wall
	#$ConvenienceRays/VelocityClamber.force_update_transform()			##	Checks if you can't clamber over a ledge next frame
	#$ConvenienceRays/VelocityOver.force_update_transform()				##	Checks if you can't snap over a ledge next fram
	#$ConvenienceRays/VelocityNextPosition.force_update_transform()		##	Checks if you're colliding with a surface or the ground next frame
	#$ConvenienceRays/VelocityCeilingSnapLeft.force_update_transform()	##	Checks if you can't snap around the ceiling next frame
	#$ConvenienceRays/VelocityCeilingSnapRight.force_update_transform()	##	Checks if you can't snap around the ceiling next frame
	#$ConvenienceRays/VelocityCeilingLeft.force_update_transform()		##	Checks if you're colliding with the ceiling next frame
	#$ConvenienceRays/VelocityCeilingRight.force_update_transform()		##	Checks if you're colliding with the ceiling next frame
	#
	#$GroundTypeRays/VelocityBouncePad.force_raycast_update()
	#$WallTypeRays/VelocityBouncePadHigh.force_raycast_update()
	#$WallTypeRays/VelocityBouncePadLow.force_raycast_update()
	#$ConvenienceRays/VelocityClamber.force_raycast_update()
	#$ConvenienceRays/VelocityOver.force_raycast_update()
	#$ConvenienceRays/VelocityNextPosition.force_raycast_update()
	#$ConvenienceRays/VelocityCeilingSnapLeft.force_raycast_update()
	#$ConvenienceRays/VelocityCeilingSnapRight.force_raycast_update()
	#$ConvenienceRays/VelocityCeilingLeft.force_raycast_update()
	#$ConvenienceRays/VelocityCeilingRight.force_raycast_update()
	
	#pingpong()
	move_and_slide() # Might do this first, idk


##	Sets the player's movenment speeds, abilities, etc. to what they should be based on the player and their level
func load_player_stats():
	""" Might want to move movenment speed things into THIS class instead of the states themselves """
	
	""" Pull from the saved data what the abilities should be, or if you get an upgrade """
	pass



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

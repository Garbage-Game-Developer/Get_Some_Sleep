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


@onready var C : Node2D = $C


""" Exports """
@export var DEBUG : bool = false

##	Unique Player Variables
@export_group("Player Spacific Variables")
@export var PLAYER_NAME  : String = "'"


@export_subgroup("Swiming")
@export var can_swim : bool = false  #  Player can swim

@export_subgroup("Combat")
##	Player can punch and air kick, sliding does half damage (rounded up) and upward knockback, dash does half damage (rounded up) and forward knockback
@export var combat_skills : bool = false
@export var combat_power : int = 5  #  Damage done by attacks

@export_subgroup("Basic Movenment")
@export var basic_movenment : bool = false ##  Allows for ground dash, wall dash, and swinging
@export var advanced_movenment : bool = false  ##  Allows for air normal dash, swinging dash, and advanced climbing

@export_subgroup("Double Jump")
@export var item_double_jump : bool = false  ##  Allows for air double jump under a condition
@export var free_double_jump : bool = false  ##  Allows for air double jump with no conditional

@export_subgroup("Dash")
@export var special_dash : bool = false  ##  Allows for special dash variation on ground, air, and water

@export_subgroup("Climbing")
@export var MAX_STAMINA : float = 5.0  ##  Meassured in seconds of climbing, kicking off takes one whole second, not climbing takes 1/4 seconds the time
@export var normal_climb : bool = false  ##  Allows for the player to climb on normal surfaces
@export var normal_corner_swing : bool = false  ##  Allows the player to swing when on the lower corner of a normal surface
@export var slow_climb : bool = false  ##  Allows for the player to climb on slow surfaces
@export var slow_corner_swing : bool = false  ##  Allows the player to swing when on the lower corner of a slow surface
@export var ice_slide : bool = false  ##  Allows for the player to slide down on ice surfaces
@export var ice_corner_swing : bool = false  ##  Allows the player to swing when on the lower corner of an ice surface

@export_subgroup("Convenience")
@export_range(-15.0, -1.0) var cutting_value : float = -2.0


@export_subgroup("Not implemented yet")
##	Still working on / haven't started
@export var able_swing : bool = false  ##  Can use swingables


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
var can_use_actions : bool = true
var passive_state = false  ##  Most animations locked, can only walk
var special_available = true  ##  Can double jump or dash mid air
var has_dashed_in_air = false  ##  Has dashed in the air

# physics manipulation
var speed_boost : float = 1.0  ##  Boosts to all speed stuff
var layered_gravity : Vector2 = Vector2.ZERO  ##  Things like wind and extra gravity that are applied outside of the state

# Player Variables
@onready var stamina : float = MAX_STAMINA
var last_stamina : float = 1.0

# Animations
var left_or_right : bool = false  ## false for left, true for right

# Rays


# Simple internals
var move_vector : Vector2 = Vector2.ZERO
var wall_direction : int = 1  ##  -1 is left, 0 is no wall, 1 is right


""" Godot Built-In Functions """
func _ready():
	""" Check for global prefrences for controls and set the corresponding internal variables """
	can_use_actions = false
	if(!DEBUG):
		load_player_stats()
	else:
		Global.active_player = self


func _physics_process(delta):
	
	##	Check velocity rays and other state related stuff
	move_vector.x = left_right_priority(is_action_pressed("LEFT"), is_action_pressed("RIGHT")).x
	move_vector.y = down_up_priority(is_action_pressed("DOWN"), is_action_pressed("UP")).y
	
	wall_direction = 1 if $WallTypeRays/WallRight.is_colliding() else (-1 if $WallTypeRays/WallLeft.is_colliding() else 0)
	determine_wall_type()
	
	determine_ground_type()
	
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
	#var temp_velocity = velocity / 60
	#$GroundTypeRays/VelocityBouncePad.target_position = temp_velocity
	#$WallTypeRays/VelocityBouncePadHigh.target_position = temp_velocity + (Vector2(5.0, 0.0) if temp_velocity.x > 0.0 else Vector2(-5.0, 0.0))
	#$WallTypeRays/VelocityBouncePadLow.target_position = temp_velocity + (Vector2(5.0, 0.0) if temp_velocity.x > 0.0 else Vector2(-5.0, 0.0))
	#$ConvenienceRays/VelocityNextPosition.target_position = temp_velocity + (Vector2(5.0, 0.0) if temp_velocity.x > 0.0 else Vector2(-5.0, 0.0))
	#$ConvenienceRays/VelocityNextTopPosition.target_position = temp_velocity + (Vector2(5.0, 0.0) if temp_velocity.x > 0.0 else Vector2(-5.0, 0.0))
	
	#$GroundTypeRays/VelocityBouncePad.force_update_transform()			##	Checks if the next frame will interact with a bouncepad on the ground
	#$WallTypeRays/VelocityBouncePadHigh.force_update_transform()		##	Checks if the next frame will interact with a bouncepad on the wall
	#$WallTypeRays/VelocityBouncePadLow.force_update_transform()			##	Checks if the next frame will interact with a bouncepad on the wall
	#$ConvenienceRays/VelocityNextPosition.force_update_transform()		##	Checks if you're colliding with a surface or the ground next frame
	#
	#$GroundTypeRays/VelocityBouncePad.force_raycast_update()
	#$WallTypeRays/VelocityBouncePadHigh.force_raycast_update()
	#$WallTypeRays/VelocityBouncePadLow.force_raycast_update()
	#$ConvenienceRays/VelocityNextPosition.force_raycast_update()
	
	
	#pingpong()
	
	last_stamina = stamina
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
func on_wall() -> bool:
	return wall_direction != 0


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



var down_or_up : bool = false  ##  false for down, true for up
var h_just_switched_directions : bool = false
var down_hold : bool = false  ##  down been pressed for longer than a frame
var up_hold : bool = false  ##  up been pressed for longer than a frame
func down_up_priority(down_pressed : bool, up_pressed : bool) -> Vector2:
	if(up_pressed):
		if(!down_pressed):  ##  up is the 'only' button pressed
			h_just_switched_directions = !down_or_up || !up_hold ##  if was down, switch directions
			down_hold = false
			down_or_up = true
			up_hold = true
			return Vector2.UP
		else:
			if(!up_hold):  ##  up was 'just' pressed and down is down
				h_just_switched_directions = !down_or_up  ##  if was down, switch directions
				down_or_up = true
				up_hold = true
				return Vector2.UP
			else:
				if(!down_hold):  ##  down was 'just' pressed and up is down
					h_just_switched_directions = down_or_up  ##  if was up, switch directions
					down_or_up = false
					down_hold = true
					return Vector2.DOWN
				if(down_or_up):  ##  up was 'most recently' pressed and down is down
					h_just_switched_directions = false
					return Vector2.UP
	if(down_pressed):  ##  down is the 'only' button pressed, 'or' down was 'most recently' pressed and up is down
		h_just_switched_directions = down_or_up || !down_hold  ##  if was up, switch directions
		up_hold = up_pressed
		down_or_up = false
		down_hold = true
		return Vector2.DOWN
	h_just_switched_directions = down_hold || up_hold
	down_hold = false
	up_hold = false
	return Vector2.ZERO


func is_action_just_pressed(action : StringName, override : bool = false) -> bool:
	return Input.is_action_just_pressed(action) if can_use_actions || override else false
func is_action_pressed(action : StringName, override : bool = false) -> bool:
	return Input.is_action_pressed(action) if can_use_actions || override else false



var wall_type : int = 1	##	1 - Normal, 2 - Slow, 3 - Ice, -1 - Non Wall
var last_wall_type : int = 1
var new_wall_surface : bool
func determine_wall_type() -> bool:
	
	"""  When determining height priority, avoid multiple high low rays, instead, simply find the height of the intersection for the ray  """
	
	var too_low : bool = false
	
	var norm_collision = $WallTypeRays/NormalWallRight.is_colliding() || $WallTypeRays/NormalWallLeft.is_colliding()
	var slow_collision = $"WallTypeRays/SlowWallRight".is_colliding() || $"WallTypeRays/SlowWallLeft".is_colliding()
	var ice_collision = $"WallTypeRays/IceWallRight".is_colliding() || $"WallTypeRays/IceWallLeft".is_colliding()
	var non_collision = $"WallTypeRays/NonWallRight".is_colliding() || $"WallTypeRays/NonWallLeft".is_colliding()
	var collisions : int = int(norm_collision) + int(slow_collision) + int(ice_collision) + int(non_collision)
	if(collisions == 0):
		wall_type = 0
	
	elif(collisions > 1):
		##	Finds the priority wall  (Distance of 8 pixels from the start of the ray is the hand, and the cutoff point)
		var collision_points : Array[float] = [1.0, 1.0, 1.0, 1.0]
		collision_points[0] = -1.0 if !norm_collision else ($WallTypeRays/NormalWallRight.get_collision_point().y - $WallTypeRays/NormalWallRight.global_position.y if wall_direction == 1 else $WallTypeRays/NormalWallLeft.get_collision_point().y - $WallTypeRays/NormalWallLeft.global_position.y)
		collision_points[1] = -1.0 if !slow_collision else ($WallTypeRays/SlowWallRight.get_collision_point().y - $WallTypeRays/SlowWallRight.global_position.y if wall_direction == 1 else $WallTypeRays/SlowWallLeft.get_collision_point().y - $WallTypeRays/SlowWallLeft.global_position.y)
		collision_points[2] = -1.0 if !ice_collision else ($WallTypeRays/IceWallRight.get_collision_point().y - $WallTypeRays/IceWallRight.global_position.y if wall_direction == 1 else $WallTypeRays/IceWallLeft.get_collision_point().y - $WallTypeRays/IceWallLeft.global_position.y)
		collision_points[3] = -1.0 if !non_collision else ($WallTypeRays/NonWallRight.get_collision_point().y - $WallTypeRays/NonWallRight.global_position.y if wall_direction == 1 else $WallTypeRays/NonWallLeft.get_collision_point().y - $WallTypeRays/NonWallLeft.global_position.y)
		
		var current_best_height : float = -100.0
		var current_most_adequet : int = -1
		for i in range(collision_points.size()):
			if(collision_points[i] == -1.0 || collision_points[i] > 7.0):
				continue
				print(i)
			if(collision_points[i] <= 7.0 && collision_points[i] < current_best_height):
				"""  8.0 is the height you can grab from"""
				current_most_adequet = i
			elif(collision_points[i] ):
				pass
		
		wall_type = current_most_adequet + 1
		if(wall_type == 4):
			wall_type = -1
	
	else:
		if(norm_collision):
			wall_type = 1
			Wall.kick_power = Wall.NORMAL_KICK_POWER
		elif(slow_collision):
			wall_type = 2
			Wall.kick_power = Wall.SLOW_KICK_POWER
		elif(ice_collision):
			wall_type = 3
			Wall.kick_power = Wall.ICE_KICK_POWER
		elif(non_collision):
			wall_type = -1
	
	new_wall_surface = wall_type != last_wall_type
	last_wall_type = wall_type if wall_type != 0 else last_wall_type
	return too_low



var ground_type : int = 1	##	1 - Normal, 2 - Slow, 3 - Ice
var last_ground_type : int = 1
var new_ground_surface : bool = false
func determine_ground_type():
	last_ground_type = ground_type
	if($"GroundTypeRays/NormalGroundMiddle".is_colliding()):
		ground_type = 1
	elif($"GroundTypeRays/SlowGroundMiddle".is_colliding()):
		ground_type = 2
	elif($"GroundTypeRays/IceGroundMiddle".is_colliding()):
		ground_type = 3
	else:
		if($"GroundTypeRays/NormalGroundLeft".is_colliding() || $"GroundTypeRays/NormalGroundRight".is_colliding()):
			ground_type = 1
		elif($"GroundTypeRays/SlowGroundLeft".is_colliding() || $"GroundTypeRays/SlowGroundRight".is_colliding()):
			ground_type = 2
		elif($"GroundTypeRays/IceGroundLeft".is_colliding() || $"GroundTypeRays/IceGroundRight".is_colliding()):
			ground_type = 3
	new_ground_surface = ground_type != last_ground_type


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

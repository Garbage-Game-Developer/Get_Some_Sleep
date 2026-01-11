extends Node


"""	Global scene/nodes to call """
##	Core components
#var game_controller : GameController
#var level : Level
var current_room : Room
var players : Array[Player]
var active_player : Player
var camera : Camera

##	Level components


"""	External signals """
signal player_special_used(player_value : int)
signal player_ready_respawn(action_cooldown)


"""	Global variables """
var time_speed : float = 1.0  ##  The percentile speed of everything in the game


"""	Internal variables """
@onready var freeze_timer : Timer = Timer.new()


"""	Inputs (Prefrences) """
var left_input_one : Key = KEY_A
var left_input_two : Key = KEY_LEFT
var up_input_one : Key = KEY_W
var up_input_two : Key = KEY_UP
var right_input_one : Key = KEY_D
var right_input_two : Key = KEY_RIGHT
var down_input_one : Key = KEY_S
var down_input_two : Key = KEY_DOWN

var jump_input_one : Key = KEY_SPACE
var jump_input_two : Key = KEY_NONE
var dash_input_one : Key = KEY_SHIFT
var dash_input_two : Key = KEY_NONE
var slide_input_one : Key = KEY_C
var slide_input_two : Key = KEY_NONE
var kick_input_one : Key = KEY_V
var kick_input_two : Key = KEY_NONE

var attack_input_one : Key = KEY_F
var attack_input_two : Key = KEY_X
var interact_input_one : Key = KEY_E
var interact_input_two : Key = KEY_NONE


"""	Godot built-in functions"""
func _ready():
	##	Might high key crash, idk
	freeze_timer.connect("timeout", on_timer_timeout)
	freeze_timer.one_shot = true


"""	Externally called functions """
func get_saved_data(KEY : String):
	pass


func update_player_saved_data(value : Variant, ...KEYS):
	pass


## Used for immediatly freezing time
func time_freeze(time_value: float, intensity: float = 0.0, permanent : bool = false):
	time_speed = intensity
	if(!permanent):
		freeze_timer.start(time_value)


## Used for scaling time to a value
enum LERP_TYPE {LINEAR, EXPONENTIAL_TO, EXPONENTIAL_FROM, CUBIC}
func time_lerp(time_value: float, intensity_to: float, lerp_type : LERP_TYPE):
	##	Ts gonna suck to code
	pass


"""	Internal functions """
func on_timer_timeout():
	##  Could have it lerp to normal time instead of fully swapping (figure out later
	time_speed = 1.0
	##	

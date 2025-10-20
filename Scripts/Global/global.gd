extends Node


"""	Global scene/nodes to call """
##	Core components
var game_controller : GameController
#var level : Level
var player : Player
var camera : Camera

##	Level components
var camera_lock : Node2D


"""	External signals """


"""	Global variables """
var time_speed : float = 1.0  ##  The percentile speed of everything in the game


"""	Internal variables """
@onready var freeze_timer : Timer = Timer.new()


"""	Godot built-in functions"""
func _ready():
	##	Might high key crash, idk
	freeze_timer.connect("timeout", on_timer_timeout)
	freeze_timer.one_shot = true


"""	Externally called functions """
##	
func time_freeze(time_value: float, intensity: float = 0.0):
	##  Could have it lerp to normal time instead of fully swapping (figure out later)
	time_speed = intensity
	freeze_timer.start(time_value)


"""	Internal functions """
func on_timer_timeout():
	##  Could have it lerp to normal time instead of fully swapping (figure out later
	time_speed = 1.0

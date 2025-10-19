class_name GameController extends Node


"""	Exports"""
@export_category("Packed Scenes")
@export_group("On Start")
@export var main_menu_background : PackedScene
@export var splash_screen : PackedScene  ##  Plays on start
@export var main_menu : PackedScene  ##  Plays intro after splashscreen



"""	Internal variables """
var game_background : Node2D


"""	Ready """
func _ready():
	Global.game_controller = self
	game_background = main_menu_background.instantiate()
	$GUI.add_child(game_background)
	$GUI.add_child(splash_screen.instantiate())


"""	Externally called methods """
func splash_screen_end():
	$GUI.add_child(main_menu.instantiate())


##	Need to add some stuff for changing background colors and effects


"""	Internal methods """

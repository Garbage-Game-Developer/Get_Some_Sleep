class_name Camera extends Node2D

"""
Simple script so the camera sets itself to the global camera, and then follows the global camera node
"""

@onready var camera : Camera2D = $Camera2D

@export var follow_player : bool = false
@export var camera_override : bool = false
@export var override_posistion : Vector2 = Vector2.ZERO


func _ready():
	Global.camera = self
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	noise.seed = randi() % 128


func _process(delta):
	
	if(camera_override):
		position = override_posistion
	elif(follow_player && Global.camera_lock != null):
		position = Global.camera_lock.global_position + Vector2(0.0,-30.0)
	
	shake_strength = lerpf(shake_strength, 0.0, shake_decay_rate * delta) if !dont_decrease else shake_strength
	dont_decrease = false
	camera.offset = get_noise_offset(delta)



"""  Camera Shake Stuff  """
"""  Thank you Jason McCollum for the camera shake code <3  """
@export var shake_decay_rate : float = 5.0
@export var noise_shake_speed : float = 30.0
@export var noise_strength : float = 60.0

@onready var noise = FastNoiseLite.new()

var noise_i : float = 0.0
var shake_strength : float = 0.0
func get_noise_offset(delta : float) -> Vector2:
	noise_i += delta * noise_shake_speed
	return Vector2(0.2 + noise.get_noise_2d(1, noise_i) * shake_strength, noise.get_noise_2d(100, noise_i) * shake_strength)


var dont_decrease : bool = false
func shake(strength_percentile : float, mantain : bool = false):
	shake_strength = noise_strength * strength_percentile
	dont_decrease = mantain

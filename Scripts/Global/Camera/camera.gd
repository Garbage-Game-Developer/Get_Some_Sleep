class_name Camera extends Node2D

"""
Simple script so the camera sets itself to the global camera, and then follows the global camera node
"""

##	Follow Types
enum type { FREE, LOCK_POINT, HORIZONTAL_TRACK, VERTICAL_TRACK, BOUNDS, HORIZONTAL_POLYGON, VERTICAL_POLYGON, COMPLEX }
var follow_type : type = type.FREE

var lock_position : Vector2 = Vector2.ZERO
var track : PackedVector2Array
var bounds : Rectangle
var area : Polygon2D
var complex_type : int
##	Complex will have its own unique check

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
	elif(Global.active_player == null):
		position = Vector2.ZERO
	elif(follow_player):
		position = get_camera_position(Global.active_player.global_position)
	
	shake_strength = lerpf(shake_strength, 0.0, shake_decay_rate * delta) if !dont_decrease else shake_strength
	dont_decrease = false
	camera.offset = get_noise_offset(delta) if lerping else get_noise_offset(delta)
	lerping = true


"""  Camera Follow Stuff  """
var lerping : bool = true
func set_follow_type(par_type : type, value, lerp : bool = false):
	follow_type = par_type
	lerping = lerp
	match follow_type:
		type.FREE:
			pass
		type.LOCK_POINT:
			lock_position = value as Vector2
		type.HORIZONTAL_TRACK:
			track = value as PackedVector2Array
		type.VERTICAL_TRACK:
			track = value as PackedVector2Array
		type.BOUNDS:
			bounds = value as Rectangle
		type.HORIZONTAL_POLYGON:
			area = value as Polygon2D
		type.VERTICAL_POLYGON:
			area = value as Polygon2D
		type.COMPLEX:
			complex_type = value as int


##	Pass the global position of the player
func get_camera_position(desired_position : Vector2) -> Vector2:
	
	match follow_type:
		type.FREE:
			return desired_position
		
		type.LOCK_POINT:
			return lock_position
		
		type.HORIZONTAL_TRACK:
			if(track.size() == 2):
				return Vector2(clampf(desired_position.x, track.get(0).x, track.get(1).x), track.get(0).y)
			if(desired_position.x < track.get(0).x):
				return track.get(0)
			if(desired_position.x > track.get(track.size() - 1).x):
				return track.get(track.size() - 1)
			
			var i : int = 1
			while(!(desired_position.x < track.get(i).x || i == track.size() - 1)):
				i += 1
			return Vector2(desired_position.x, track.get(i-1).y + (track.get(i-1).x - desired_position.x) / (track.get(i-1).x - track.get(i).x) * (track.get(i-1).y - track.get(i).y))
		
		type.VERTICAL_TRACK:
			if(track.size() == 2):
				return Vector2(track.get(0).x, clampf(desired_position.y, track.get(0).y, track.get(1).y))
			if(desired_position.y < track.get(0).y):
				return track.get(0)
			if(desired_position.y > track.get(track.size() - 1).y):
				return track.get(track.size() - 1)
			
			var i : int = 1
			while(!(desired_position.y < track.get(i).y || i == track.size() - 1)):
				i += 1
			return Vector2(track.get(i-1).x + (track.get(i-1).y - desired_position.y) / (track.get(i-1).y - track.get(i).y) * (track.get(i-1).x - track.get(i).x), desired_position.y)
		
		type.BOUNDS:
			return bounds.get_in_area(desired_position)
		
		type.HORIZONTAL_POLYGON:
			pass
		
		type.VERTICAL_POLYGON:
			pass
		
		type.COMPLEX:
			match complex_type:
				##	Match for level code '####' as '## chapter, ## level'
				0101:
					pass
	
	return Vector2.ZERO


"""  Camera Shake Stuff  """
"""  Thank you Jason McCollum for the camera shake code <3  """
@export var shake_decay_rate : float = 5.0
@export var noise_shake_speed : float = 30.0
@export var noise_strength : float = 60.0

@onready var noise = FastNoiseLite.new()

var shake_direction # maybe implement later

var noise_i : float = 0.0
var shake_strength : float = 0.0
func get_noise_offset(delta : float) -> Vector2:
	noise_i += delta * noise_shake_speed
	return Vector2(0.2 + noise.get_noise_2d(1, noise_i) * shake_strength, noise.get_noise_2d(100, noise_i) * shake_strength)


var dont_decrease : bool = false
func shake(strength_percentile : float, mantain : bool = false):
	shake_strength = noise_strength * strength_percentile
	dont_decrease = mantain

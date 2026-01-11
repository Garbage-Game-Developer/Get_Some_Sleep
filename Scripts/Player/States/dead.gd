class_name DeadState extends State
var this_state : State.s = State.s.DEAD

""" 
Description
	This state has no input, and is used while death animations play

"""


"""  Effects  """
@export var death_effect : Effect


""" Externals """
@onready var P : Player = $"../.."
@onready var C : SpriteHandler = $"../../C"


""" Internals """
var ACTIVE_STATE : bool = false


""" DEBUG """
var time : String


func _ready():
	Global.connect("player_ready_respawn", player_respawn)


func new_state(_delta : float, _change_state : State.s, _movenment_package : Array):
	$"../../DeathAreas/Up".monitoring = true
	$"../../DeathAreas/Right".monitoring = true
	$"../../DeathAreas/Down".monitoring = true
	$"../../DeathAreas/Left".monitoring = true
	$DeathTime.start()
	C.play(C.DEAD)
	$"../../DeathAnimations".play("normal_death")



func update(_delta : float):
	var vel : Vector2 = P.velocity
	var collisions_list : Array[bool] = activater_right_areas(vel)
	vel.x *= -1 if collisions_list[0] || collisions_list[2] else 1
	vel.y *= -1 if collisions_list[1] || collisions_list[3] else 1
	P.velocity = lerp(vel, Vector2.ZERO, 0.05)



"""  Actual Player Death  """
var respawn_pos : SpawnPoint
func _on_death_time_timeout():
	P.velocity = Vector2.ZERO
	if(P.DEBUG):
		P.position = Vector2.ZERO
		P.reset()
		return
	respawn_pos = Global.current_room.player_died()
	
	##	Level handler stuff


func player_respawn():
	P.position = respawn_pos.position
	P.left_right_priority(!respawn_pos.facing_right, respawn_pos.facing_right)
	P.reset()


func activater_right_areas(velocity : Vector2) -> Array[bool]:
	return [sign(velocity.y) == -1.0 && $"../../DeathAreas/Up".has_overlapping_bodies(), 
		sign(velocity.x) == 1.0 && $"../../DeathAreas/Right".has_overlapping_bodies(), 
		sign(velocity.x) == 1.0 && $"../../DeathAreas/Down".has_overlapping_bodies(), 
		sign(velocity.x) == -1.0 && $"../../DeathAreas/Left".has_overlapping_bodies()]


func generate_movenment_package() -> Array:
	##	Intended starting velocity of the curve (if there is one), is moving allong the curve still
	return [true, 0.0]

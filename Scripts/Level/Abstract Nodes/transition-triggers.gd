class_name TransitionTrigger extends Area2D


@export var room_parent : Room

@export var active : bool = true
@export var activation_trigger : StringName
@export var transition_room : StringName
@export var spawn_point : StringName


func _ready():
	room_parent.connect("Triggered", receive_trigger)
	self.connect("area_entered", transition)


func transition():
	if(!active):
		return
	room_parent.transition(transition_room, spawn_point)


func receive_trigger(signal_name : StringName):
	if(!active && signal_name == activation_trigger):
		active = true

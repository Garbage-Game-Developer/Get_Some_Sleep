class_name Trigger extends Area2D


@export var room_parent : Room

@export var trigger_name : StringName = ""

var triggered : bool = false
@export var one_time : bool = false
@export var auto_resets : bool = false
@export var automatic_reset_time : float = 0.0
@onready var reset_timer : Timer = Timer.new()

@export var reset_on_trigger : Array[StringName]
@export var dissable_on_trigger : Array[StringName]


func _ready():
	room_parent.connect("Triggered", receive_trigger)
	reset_timer.connect("timeout", reset)
	self.connect("area_entered", trigger)


func reset(overwrite : bool = false):
	if(one_time && triggered && !overwrite):
		return
	reset_timer.stop()
	triggered = false


func trigger():
	if(triggered):
		return
	room_parent.trigger(trigger_name)
	triggered = true
	if(auto_resets):
		reset_timer.start(automatic_reset_time)


func receive_trigger(signal_name : StringName):
	for trig in reset_on_trigger:
		if(trig == signal_name):
			reset(true)
	for trig in dissable_on_trigger:
		if(trig == signal_name):
			triggered = true

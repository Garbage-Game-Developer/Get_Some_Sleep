class_name GUIHandler extends CanvasLayer


@export_group("Start Menu")
@export var VAR_Start_Screen : UIVariable
var Start_Screen : UIObject


@export_group("In Game")
@export var VAR_Pause_Screen : UIVariable
var Pause_Screen : UIObject


func Get(name : StringName, instance_if_null : bool = true, z_index : int = 0) -> UIObject:
	var object : UIObject = get(name)
	if(instance_if_null && object == null):
		var variable : UIVariable = get("VAR_" + name)
		var scene : UIObject = variable.scene.instantiate()
		scene.parent_set_up(variable)
		set(name, scene)
		object = scene
	return object
func Instance(name : StringName, z_index : int = 0) -> UIObject:
	return Get(name, true, z_index)


func Remove(name : StringName) -> bool:
	var scene : UIObject = get(name)
	set(name, null)
	if(scene != null):
		scene.queue_free()
		return true
	return false

class_name GUIHandler extends CanvasLayer


@export_group("Start Menu")
@export var VAR_Start_Screen : UIVariable
var Start_Screen : UIObject


@export_group("In Game")



func Get(name : StringName, instance_if_null : bool = true) -> UIObject:
	var object : UIObject = get(name)
	if(object == null):
		var variable : UIVariable = get("VAR_" + name)
		var scene : UIObject = variable.scene.instantiate()
		set(name, scene)
		object = scene
	return object


func Remove(name : StringName) -> bool:
	var scene : UIObject = get(name)
	set(name, null)
	if(scene != null):
		scene.queue_free()
		return true
	return false

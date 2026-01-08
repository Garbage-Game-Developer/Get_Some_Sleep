@abstract class_name UIObject extends Control


@abstract func set_up()
@abstract func transition_in()
@abstract func transition_out()

func parent_set_up(object : UIVariable):
	z_index = object.z_index

class_name Rectangle extends Resource

##Bounds mean: 
## x - min horizontal bound |
## y - max horizontal bound |
## z - min vertical bound |
## w - max horizontal bound |
@export var bounds : Vector4

func in_area(position : Vector2) -> bool:
	return clampf(position.x, bounds.x, bounds.y) == position.x && clampf(position.y, bounds.z, bounds.w) == position.y

func get_in_area(position : Vector2) -> Vector2:
	return Vector2(clampf(position.x, bounds.x, bounds.y), clampf(position.y, bounds.z, bounds.w))

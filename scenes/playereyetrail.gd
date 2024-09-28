extends Trails

var eyeposition: Vector2 = Vector2.ZERO

func _get_position() -> Vector2:
	eyeposition = get_parent().position
	#print(eyeposition)
	return eyeposition

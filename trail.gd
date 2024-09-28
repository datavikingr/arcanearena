extends Line2D
class_name Trails

#######################################################################################################################################################
## DECLARATIONS
# Exports
@export var max_length: int = 15
# Local
var pos # self position.
var queue: Array = [] # Hopper

#######################################################################################################################################################
## EXECUTION / MAIN
func _process(_delta: float) -> void: # Called every frame. 'delta' is the elapsed time since the previous frame.
	pos = _get_position()
	queue.push_front(pos)
	if queue.size() > max_length:
		queue.pop_back()
	clear_points()
	#print(queue)
	for point in queue:
		add_point(point)

func _get_position():
	return get_global_mouse_position()

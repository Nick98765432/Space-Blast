extends Line2D
class_name trail

var queue: Array = []
var active: bool = false
@export var max: int = 10

func _process(delta: float) -> void:
	var pos = get_parent().position
	if active:
		queue.push_front(pos)
	
	if queue.size() > max or not active:
		queue.pop_back()
	
	clear_points()
	
	for i in queue:
		add_point(i)

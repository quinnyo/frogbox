extends Node2D

## Emitted when the pointer moves in local space. `p` is the local position of the pointer.
signal moved(p: Vector2)

var _local_pos: Vector2

func _physics_process(_delta: float) -> void:
	if is_processing_input():
		var p := get_local_mouse_position()
		if !p.is_equal_approx(_local_pos):
			_local_pos = p
			moved.emit(p)

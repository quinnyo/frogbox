class_name SpawnPoint
extends Marker2D


#@export var face_left: bool = false

## `sequence == 0` for level start
@export var sequence := 0


#var face_side: float:
#	set(x): face_left = x < 0.0
#	get: return -1.0 if face_left else 1.0


func _enter_tree() -> void:
	(owner as Map)._register_spawn_point(self)


func get_spawn_transform() -> Transform2D:
	return Transform2D(global_rotation, global_position)


## return true if the given player's avatar can spawn from this.
func is_player_allowed(player_index: int = 0) -> bool:
	return player_index >= 0

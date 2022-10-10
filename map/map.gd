class_name Map
extends Node2D

signal pini(entity: Node2D)

var _map_ready: bool = false
var _spawn_points: Array[SpawnPoint] = []


func _ready() -> void:
	if get_tree().current_scene == self:
		print("TODO: map scene loaded ~~> initialise game?")

	_map_ready = true


func is_map_ready() -> bool:
	return _map_ready


##
func get_spawn_point(sequence: int = 0, player_slot: int = 0) -> SpawnPoint:
	var player_allowed: Array[SpawnPoint] = _spawn_points.filter(func(spawn: SpawnPoint): return spawn.is_player_allowed(player_slot))
	if player_allowed.is_empty():
		push_error("no registered SpawnPoint for player slot %d" % [ player_slot ])
		return null
	var best: SpawnPoint = null
	for spawn_point in player_allowed:
		if spawn_point.sequence == sequence:
			return spawn_point
		if best == null:
			best = spawn_point
	push_warning("no registered SpawnPoint for player slot %d matches sequence %d" % [ player_slot, sequence ])
	return best


func _register_spawn_point(spawn: SpawnPoint) -> void:
	_spawn_points.push_back(spawn)


func _on_pini_entity_entered(node: Node2D) -> void:
	pini.emit(node)

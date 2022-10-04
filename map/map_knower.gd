extends Node


const MAP_RESOURCE_TYPE_HINT := "PackedScene"


func has(id: String) -> bool:
	var path := _map_path(id)
	return ResourceLoader.exists(path, MAP_RESOURCE_TYPE_HINT)


func map_path(id: String, valid_only: bool = true) -> String:
	var path := _map_path(id)
	if valid_only && !ResourceLoader.exists(path, MAP_RESOURCE_TYPE_HINT):
		push_error("invalid map '%s' ('%s' not found)" % [ id, path ])
	return path


func _map_path(id: String) -> String:
	if id.is_absolute_path():
		return id
	return "res://content/maps/%s.tscn" % [ id ]

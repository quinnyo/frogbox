class_name GameStage
extends CanvasLayer


#const FN_ENTER_STAGE := "_enter_stage"


func add_to_stage(node: Node) -> void:
	add_child(node)
#	node.propagate_call(FN_ENTER_STAGE, [ self ])


func clear() -> void:
	for child in get_children():
		child.queue_free()


func is_empty() -> bool:
	return get_child_count() == 0


func set_avatar_control_enabled(enabled: bool) -> void:
	for child in get_children():
		propagate_call("set_process_input", [ enabled ])


func add_default_camera() -> void:
	var camera_scn := preload("res://mess/autocam/autocam_2d.tscn")
	var camera := camera_scn.instantiate()
	add_to_stage(camera)


static func find_stage_parent(node: Node) -> GameStage:
	if node is GameStage:
		return node as GameStage
	var parent := node.get_parent()
	while is_instance_valid(parent):
		if parent is GameStage:
			return parent as GameStage
		parent = parent.get_parent()
	return null

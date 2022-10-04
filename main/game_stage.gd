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


func open() -> void:
	pass


func close() -> void:
	pass


func start() -> void:
	pass


func stop() -> void:
	pass

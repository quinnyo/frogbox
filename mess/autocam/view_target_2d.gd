class_name ViewTarget2D
extends Node2D


const GROUP_NAME := "ViewTarget2D"


var _anchor_stack := []


func get_target_transform() -> Transform2D:
	return global_transform


func _enter_tree() -> void:
	add_to_group(GROUP_NAME)


func _on_view_anchor_area_entered(anchor: ViewAnchor2D) -> void:
	_anchor_stack.erase(anchor)
	_anchor_stack.push_back(anchor)


func _on_view_anchor_area_exited(anchor: ViewAnchor2D) -> void:
	_anchor_stack.erase(anchor)

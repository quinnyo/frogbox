## Camera framing hint node
@tool
class_name CameraHint2D
extends Node2D

signal changed()

const GROUP := "CameraHint2D"

@export var as_limit_left: bool = false:
	set(value):
		as_limit_left = value
		_emit_changed()
@export var as_limit_right: bool = false:
	set(value):
		as_limit_right = value
		_emit_changed()
@export var as_limit_top: bool = false:
	set(value):
		as_limit_top = value
		_emit_changed()
@export var as_limit_bottom: bool = false:
	set(value):
		as_limit_bottom = value
		_emit_changed()


func _enter_tree() -> void:
	if Engine.is_editor_hint():
		return
	set_notify_transform(true)
	if !is_in_group(GROUP):
		add_to_group(GROUP)


func _notification(what: int) -> void:
	match what:
		NOTIFICATION_TRANSFORM_CHANGED:
			_emit_changed()


func _draw() -> void:
	if !Engine.is_editor_hint():
		return

	var draw_thing := func(dir: Vector2, color: Color):
		var radius := 50.0
		var forward := dir * radius * 0.5
		var side := dir.orthogonal() * radius
		var offset := dir
		draw_multiline([ -side + offset, side + offset, offset, forward + offset ], color)

	if as_limit_left:
		draw_thing.call(Vector2.RIGHT, Color.RED)
	if as_limit_right:
		draw_thing.call(Vector2.LEFT, Color.ORANGE)
	if as_limit_top:
		draw_thing.call(Vector2.DOWN, Color.GREEN)
	if as_limit_bottom:
		draw_thing.call(Vector2.UP, Color.CYAN)


func _emit_changed() -> void:
	if Engine.is_editor_hint():
		queue_redraw()
		return
	changed.emit()

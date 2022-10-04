@tool
extends Node2D

@export var offset: Vector2 = Vector2.ZERO
@export var rotating: bool = false
@export var current: bool = false
@export var zoom: Vector2 = Vector2.ONE:
	set(p_zoom):
		assert(!is_zero_approx(p_zoom.x) && !is_zero_approx(p_zoom.y))
		zoom = p_zoom
		var old_smoothed_camera_pos := smoothed_camera_pos
		_update_scroll()
		smoothed_camera_pos = old_smoothed_camera_pos

@export var limit_left: int = -10000000
@export var limit_top: int = -10000000
@export var limit_right: int = 10000000
@export var limit_bottom: int = 10000000
@export var limit_smoothing_enabled: bool = false

@export var smoothing_enabled: bool = false
@export var smoothing_speed: float = 5.0

@export var drag_horizontal_enabled: bool = false
@export var drag_vertical_enabled: bool = false
@export var drag_horizontal_offset: float = 0.0:
	set(value):
		drag_horizontal_offset = value
		_drag_horizontal_offset_changed = true
@export var drag_vertical_offset: float = 0.0:
	set(value):
		drag_vertical_offset = value
		_drag_vertical_offset_changed = true
@export var drag_left_margin: float = 0.2
@export var drag_top_margin: float = 0.2
@export var drag_right_margin: float = 0.2
@export var drag_bottom_margin: float = 0.2

@export var editor_draw_screen: bool = true
@export var editor_draw_limits: bool = false
@export var editor_draw_drag_margin: bool = false


var camera_pos: Vector2
var smoothed_camera_pos: Vector2

var _target: ViewTarget2D
var _canvas_layer: CanvasLayer
var _first: bool = false
var _drag_horizontal_offset_changed: bool = false
var _drag_vertical_offset_changed: bool = false


func _physics_process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return

	if !has_target():
		_find_target()

	if has_target():
		global_position = _target.global_position
		global_rotation = _target.global_rotation

	_update_scroll()


func _notification(what: int) -> void:
	match what:
		NOTIFICATION_TRANSFORM_CHANGED:
			if Engine.is_editor_hint():
				_update_scroll()


func _enter_tree() -> void:
	if Engine.is_editor_hint():
		return

	_canvas_layer = _find_canvas_layer()
	_first = true
	if get_parent() is ViewTarget2D:
		set_target(get_parent() as ViewTarget2D)


func _draw() -> void:
	if !Engine.is_editor_hint():
		return

	draw_set_transform_matrix(global_transform.affine_inverse())

	var screen_enabled := editor_draw_screen && Engine.is_editor_hint()
	var limit_enabled := editor_draw_limits && Engine.is_editor_hint()
	var drag_margin_enabled := editor_draw_drag_margin && Engine.is_editor_hint()

	var line_width := 3.0 if current else 1.0
	var inv_camera_xf := _get_camera_transform().affine_inverse()
	var screen_size := _get_camera_screen_size()

	if screen_enabled:
		var color := Color(1, 0.4, 1, 0.6)
		var screen_endpoints := PackedVector2Array([
			inv_camera_xf * Vector2(),
			inv_camera_xf * Vector2(screen_size.x, 0),
			inv_camera_xf * screen_size,
			inv_camera_xf * Vector2(0, screen_size.y),
		])
		for i in range(screen_endpoints.size()):
			draw_line(screen_endpoints[i], screen_endpoints[(i + 1) % 4], color, line_width)

	if limit_enabled:
		var color := Color(1, 1, 0.25, 0.6)
		var limit_points := PackedVector2Array([
			Vector2(limit_left, limit_top),
			Vector2(limit_right, limit_top),
			Vector2(limit_right, limit_bottom),
			Vector2(limit_left, limit_bottom),
		])
		for i in range(limit_points.size()):
			draw_line(limit_points[i], limit_points[(i + 1) % 4], color, line_width)

	if drag_margin_enabled:
		var color := Color(0.25, 1, 1, 0.6)
		var half := screen_size / 2.0
		var points := PackedVector2Array([
			inv_camera_xf * Vector2(half.x - half.x * drag_left_margin, half.y - half.y * drag_top_margin),
			inv_camera_xf * Vector2(half.x + half.x * drag_right_margin, half.y - half.y * drag_top_margin),
			inv_camera_xf * Vector2(half.x + half.x * drag_right_margin, half.y + half.y * drag_bottom_margin),
			inv_camera_xf * Vector2(half.x - half.x * drag_left_margin, half.y + half.y * drag_bottom_margin),
		])
		for i in range(points.size()):
			draw_line(points[i], points[(i + 1) % 4], color, line_width)


func set_target(target: ViewTarget2D) -> void:
	_target = target


func has_target() -> bool:
	return is_instance_valid(_target) && _target.is_inside_tree()


func _update_scroll() -> void:
	if !is_inside_tree():
		return

	if Engine.is_editor_hint():
		queue_redraw()
		return

	if current:
		var xf := _get_camera_transform()
		if _canvas_layer:
			_canvas_layer.transform = xf
		else:
			get_viewport().canvas_transform = xf


func _get_camera_transform() -> Transform2D:
	if !is_inside_tree():
		return Transform2D()

	var zoom_scale := zoom
	var screen_size := _get_camera_screen_size()
	var new_camera_pos := global_position
	var ret_camera_pos := Vector2()

	if _first:
		camera_pos = new_camera_pos
		smoothed_camera_pos = new_camera_pos
		ret_camera_pos = new_camera_pos
		_first = false
	else:
		if drag_horizontal_enabled && !Engine.is_editor_hint() && !_drag_horizontal_offset_changed:
			camera_pos.x = minf(camera_pos.x, (new_camera_pos.x + screen_size.x * 0.5 * zoom_scale.x * drag_left_margin))
			camera_pos.x = maxf(camera_pos.x, (new_camera_pos.x - screen_size.x * 0.5 * zoom_scale.x * drag_right_margin))
		else:
			_drag_horizontal_offset_changed = false
			if drag_horizontal_offset < 0.0:
				camera_pos.x = new_camera_pos.x + screen_size.x * 0.5 * drag_right_margin * drag_horizontal_offset
			else:
				camera_pos.x = new_camera_pos.x + screen_size.x * 0.5 * drag_left_margin * drag_horizontal_offset

		if drag_vertical_enabled && !Engine.is_editor_hint() && !_drag_vertical_offset_changed:
			camera_pos.y = minf(camera_pos.y, (new_camera_pos.y + screen_size.y * 0.5 * zoom_scale.y * drag_top_margin))
			camera_pos.y = maxf(camera_pos.y, (new_camera_pos.y - screen_size.y * 0.5 * zoom_scale.y * drag_bottom_margin))
		else:
			_drag_vertical_offset_changed = false
			if drag_vertical_offset < 0.0:
				camera_pos.y = new_camera_pos.y + screen_size.y * 0.5 * drag_bottom_margin * drag_vertical_offset
			else:
				camera_pos.y = new_camera_pos.y + screen_size.y * 0.5 * drag_top_margin * drag_vertical_offset

		if limit_smoothing_enabled:
			var screen_offset := screen_size * 0.5 * zoom_scale
			var screen_rect := Rect2(-screen_offset + camera_pos, screen_size * zoom_scale)
			if screen_rect.position.x < limit_left:
				camera_pos.x -= screen_rect.position.x - limit_left
			if screen_rect.end.x > limit_right:
				camera_pos.x -= screen_rect.position.x + limit_right - screen_rect.size.x
			if screen_rect.position.y < limit_top:
				camera_pos.y -= screen_rect.position.y - limit_top
			if screen_rect.end.y > limit_bottom:
				camera_pos.y -= screen_rect.position.y + limit_bottom - screen_rect.size.y

		if smoothing_enabled && !Engine.is_editor_hint():
			var c := smoothing_speed * _get_camera_process_delta_time()
			smoothed_camera_pos += (camera_pos - smoothed_camera_pos) * c
			ret_camera_pos = smoothed_camera_pos
		else:
			smoothed_camera_pos = camera_pos
			ret_camera_pos = camera_pos

	var screen_offset := screen_size * 0.5 * zoom_scale

	var angle := global_rotation
	if rotating:
		screen_offset = screen_offset.rotated(angle)

	var screen_rect := Rect2(-screen_offset + ret_camera_pos, screen_size * zoom_scale)

	if !smoothing_enabled || !limit_smoothing_enabled:
		if screen_rect.position.x < limit_left:
			screen_rect.position.x = limit_left
		if screen_rect.end.x > limit_right:
			screen_rect.position.x = limit_right - screen_rect.size.x
		if screen_rect.position.y < limit_top:
			screen_rect.position.y = limit_top
		if screen_rect.end.y > limit_bottom:
			screen_rect.position.y = limit_bottom - screen_rect.size.y

	if !offset.is_zero_approx():
		screen_rect.position += offset

	var xf := Transform2D()
	xf.set_scale(zoom_scale)
	if rotating:
		xf.set_rotation(angle)
	xf.origin = screen_rect.position

	return xf.affine_inverse()


func _get_camera_screen_size() -> Vector2:
	if Engine.is_editor_hint():
		return Vector2(ProjectSettings.get_setting("display/window/size/viewport_width"), ProjectSettings.get_setting("display/window/size/viewport_height"))
	return get_viewport_rect().size


func _get_camera_process_delta_time() -> float:
	return get_physics_process_delta_time()


func _find_target() -> void:
	set_target(get_tree().get_first_node_in_group(ViewTarget2D.GROUP_NAME) as ViewTarget2D)


func _find_canvas_layer() -> CanvasLayer:
	var node := get_parent()
	while is_instance_valid(node):
		if node is CanvasLayer:
			return node as CanvasLayer
		else:
			node = node.get_parent()
	return null

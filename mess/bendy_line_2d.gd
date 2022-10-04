@tool
class_name BendyLine2D
extends Node2D

@export var rest_axis: Vector2 = Vector2.UP

@export_node_path(Node2D) var tip_node_path := NodePath():
	set(value):
		tip_node_path = value
#		var tip_node: Node2D = get_node_or_null(tip_node_path)
#		if tip_node:
#			tip_rest = to_local(tip_node.global_position)
		_update()

@export var nsegments := 9:
	set(value):
		nsegments = value
		_update()

@export_exp_easing("inout") var flex_bias := 0.85:
	set(value):
		flex_bias = value
		_update()

@export var snap_to_pixel := false:
	set(value):
		snap_to_pixel = value
		_update()

@export var width := 2.0:
	set(value):
		width = value
		_update()

@export var default_color := Color.GRAY:
	set(value):
		default_color = value
		_update()


#var tip_rest := Vector2():
#	set(value):
#		if !value.is_equal_approx(tip_rest):
#			_update()
#		tip_rest = value
#		tip_position = tip_rest

var tip_position: Vector2:
	set(value):
		if !value.is_equal_approx(tip_position):
			_update()
		tip_position = value

var _is_valid := false


#func _ready() -> void:
#	var tip_node: Node2D = get_node_or_null(tip_node_path)
#	if tip_node:
#		tip_rest = to_local(tip_node.global_position)


func _process(_delta: float) -> void:
	var tip_node: Node2D = get_node_or_null(tip_node_path)
	if tip_node:
#		if Engine.is_editor_hint():
#			tip_rest = to_local(tip_node.global_position)
		tip_position = to_local(tip_node.global_position)
		_is_valid = true
	else:
		_is_valid = false


func _draw() -> void:
	if !(_is_valid || Engine.is_editor_hint()):
		return


	var tip_rest := tip_position.project(rest_axis)
	draw_polyline(build_bendy_line(Vector2(), tip_rest, tip_position), default_color, width)


func _update() -> void:
	queue_redraw()


func build_bendy_line(p_a: Vector2, p_b0: Vector2, p_b1: Vector2, p_nsegments: int = nsegments, p_flex_bias: float = flex_bias, p_snap_to_pixel: bool = snap_to_pixel) -> PackedVector2Array:
	var points := PackedVector2Array()
	points.resize(p_nsegments + 1)
	for i in range(points.size()):
		var t := float(i) / float(p_nsegments)
		var flexion := ease(t, p_flex_bias)
		var p := p_a + (p_b0 * t).lerp(p_b1 * t, flexion)
		points[i] = p.round() if p_snap_to_pixel else p
	return points


func bendy_line(_a:Vector2, _b0:Vector2, _b1:Vector2, _t:float, _flex_curve:float) -> Vector2:
	var flexion := ease(_t, _flex_curve)
	var p := _a + (_b0 * _t).lerp(_b1 * _t, flexion)
	return p

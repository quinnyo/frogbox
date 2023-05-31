@tool
class_name Bendygon2D
extends Polygon2D

const SHADER := preload("bendygon_2d.gdshader")

@export var rest_axis: Vector2 = Vector2.UP:
	set(value):
		rest_axis = value
		queue_update()

@export var rest_length: float = 100.0:
	set(value):
		rest_length = value
		queue_update()

@export var tip_node_path := NodePath():
	set(value):
		tip_node_path = value
		queue_update()

@export_exp_easing("inout") var flex_bias := 1.35:
	set(value):
		flex_bias = value
		queue_update()

#@export var snap_to_pixel := false:
#	set(value):
#		snap_to_pixel = value
#		queue_update()

var tip_position: Vector2:
	set(value):
		if !value.is_equal_approx(tip_position):
			tip_position = value
			queue_update()

var _is_valid := false
var _update_requested := true


func _process(_delta: float) -> void:
	var tip_node: Node2D = get_node_or_null(tip_node_path)
	if tip_node:
		tip_position = to_local(tip_node.global_position)
		_is_valid = true
	else:
		_is_valid = false

	if _update_requested:
		_update()


#func _draw() -> void:
#	if !(_is_valid || Engine.is_editor_hint()):
#		return

#	var ext_verts := polygon.slice(0, -internal_vertex_count)
#	var outline := Geometry2D.offset_polygon(ext_verts, 1.0, Geometry2D.JOIN_MITER)
#	if outline.size() == 1:
#		draw_polyline(outline[0], Color.RED, 2.0)

#	var tip_rest := rest_axis * rest_length
#	var m1 := tip_position.length()
#	var full_angle := tip_rest.angle_to(tip_position)
#	var full_stretch := m1 / rest_length
#	for i in range(polygon.size()):
#		var v := polygon[i]
#		var t := v.dot(rest_axis) / rest_length
#		var flexion := ease(t, flex_bias)
#		var vz := v.rotated(full_angle) * full_stretch
#		var vf := v.lerp(vz, flexion)
#		draw_circle(v, 2, Color.GRAY)
#		draw_line(v, vf, Color(1,0,0,0.5))
#		draw_circle(vf, 2, Color(1,0,0,0.5))


func queue_update() -> void:
	_update_requested = true


func _update() -> void:
	queue_redraw()
	var shmat := material as ShaderMaterial
	if shmat && shmat.shader:
		shmat.set_shader_parameter("rest_axis", rest_axis)
		shmat.set_shader_parameter("rest_length", rest_length)
		shmat.set_shader_parameter("flex_curve", flex_bias)
		shmat.set_shader_parameter("tip_position", tip_position)
	_update_requested = false

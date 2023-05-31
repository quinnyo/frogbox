@tool
@icon("../icon/poly_chunk_2d.svg")
class_name PolyChunk2D extends Node2D

## Emitted after (re)building
signal updated()


enum ColliderMode {
	## Visual only -- no collision shape or body will be created.
	NONE,
	## Easy-mode static (solid) geometry.
	## A static body and collision shape/s will be created and added to the scene.
	STATIC_BODY,
}


@export var color: Color = Color.PALE_VIOLET_RED:
	set(value):
		color = value
		_update()

@export var color_stroke: Color = Color.PALE_GREEN:
	set(value):
		color_stroke = value
		_update()

@export var stroke_thickness := 2.0:
	set(value):
		stroke_thickness = value
		_update()

@export var texture: Texture2D:
	set(value):
		texture = value
		_update()

@export var join_cut_depth := 4.0:
	set(value):
		join_cut_depth = value
		_update()

@export var points: PackedVector2Array:
	set(value):
		points = value
		_update()

@export var collider_mode: ColliderMode = ColliderMode.STATIC_BODY


var overlay_enabled: bool = false

## built polygon (cache)
var _polygon: PackedVector2Array

var _update_requested := true


func _physics_process(_delta: float) -> void:
	if _update_requested:
		build()
		_update_requested = false


func _draw() -> void:
	_draw_chunk()
	if Engine.is_editor_hint() && overlay_enabled:
		_draw_overlay()


func get_points_count() -> int:
	return points.size()


func get_point_world(idx: int) -> Vector2:
	return to_global(points[idx])


func get_point(idx: int, p_repeating: bool = true) -> Vector2:
	return points[wrapi(idx, 0, get_points_count()) if p_repeating else idx]


func set_point(idx: int, p: Vector2) -> void:
	points[idx] = p
	_update()


func append_point(p: Vector2) -> int:
	points.push_back(p)
	_update()
	return points.size() - 1


func insert_point(idx: int, p: Vector2) -> void:
	points.insert(idx, p)
	_update()


func clone_points() -> PackedVector2Array:
	return points.duplicate()


func set_points(p_points: PackedVector2Array) -> void:
	points = p_points
	_update()


## Find the point nearest to $p_pos and return its index.
## Optionally only consider points within $p_radius.
## If no point is found, returns `-1`
func pick_point(p_pos: Vector2, p_radius: float = INF) -> int:
	var best_idx := -1
	var best_distsq := pow(p_radius, 2.0)
	for idx in range(points.size()):
		var distsq := p_pos.distance_squared_to(points[idx])
		if distsq < best_distsq:
			best_idx = idx
			best_distsq = distsq
	return best_idx


func pick_edge(p_pos: Vector2, p_margin: float = INF) -> float:
	if get_points_count() < 2:
		return -1.0
	var best_idx := -1
	var best_distsq := pow(p_margin, 2.0)
	var best_u := 0.0
	for idx in range(points.size()):
		var seg := get_segment(idx)
		var ab := seg[1] - seg[0]
		var ap := p_pos - seg[0]
		var u := ap.dot(ab) / ab.length_squared()
		if u < 0.0 || u >= 1.0:
			continue
		var distsq := p_pos.distance_squared_to(seg[0] + ab * u)
		if distsq < best_distsq:
			best_idx = idx
			best_distsq = distsq
			best_u = u

	return float(best_idx) + best_u


func get_segment(idx: int) -> PackedVector2Array:
	if points.size() < 2:
		return PackedVector2Array()
	return PackedVector2Array([ points[idx], points[(idx + 1) % points.size()] ])


func interpolate_polyline(offset: float) -> Vector2:
	var seg := get_segment(int(offset))
	return seg[0].lerp(seg[1], offset - floor(offset))


func get_segment_length_squared(idx: int) -> float:
	var seg := get_segment(idx)
	return (seg[1] - seg[0]).length_squared()


func interpolate_segment(idx: int, t: float) -> Vector2:
	var seg := get_segment(idx)
	return seg[0].lerp(seg[1], t)


func split_segment(offset: float) -> void:
	points.insert(ceil(offset), interpolate_polyline(offset))
	_update()


func remove_point(idx: int) -> void:
	points.remove_at(idx)
	_update()


## (re)build geometry
func build() -> void:
	var triangles := Geometry2D.triangulate_polygon(points)
	if triangles.is_empty():
		_polygon = PackedVector2Array()
	else:
		_polygon = points.duplicate()
#		if Geometry2D.is_polygon_clockwise(_polygon):
#			_polygon.reverse()
		if join_cut_depth > 0.0:
			_polygon = _smooth(_polygon, join_cut_depth)

		var body := get_node_or_null("_static_body_2d") as StaticBody2D
		if !Engine.is_editor_hint() && collider_mode == ColliderMode.STATIC_BODY:
			if body == null:
				body = StaticBody2D.new()
				body.name = "_static_body_2d"
				add_child(body)
			var colpol := body.get_node_or_null("collision_polygon_2d") as CollisionPolygon2D
			if colpol == null:
				colpol = CollisionPolygon2D.new()
				colpol.name = "collision_polygon_2d"
				body.add_child(colpol)
			colpol.polygon = _polygon
		elif is_instance_valid(body):
			body.queue_free()

	queue_redraw()
	updated.emit()


func _update() -> void:
	if Engine.is_editor_hint():
		build()
	else:
		_update_requested = true


func _smooth(p_points: PackedVector2Array, p_depth: float) -> PackedVector2Array:
	var polygon := PackedVector2Array()
	for idx in range(p_points.size()):
		var seg0 := p_points[idx]
		var seg1 := p_points[(idx + 1) % p_points.size()]
		var seglen := seg0.distance_to(seg1)
		var udepth := p_depth / seglen
		if udepth > 0.5:
			polygon.push_back(seg0)
			polygon.push_back(seg1)
		else:
			polygon.push_back(seg0.lerp(seg1, udepth))
			polygon.push_back(seg1.lerp(seg0, udepth))
	return polygon


func _interpolate_segment(polygon: PackedVector2Array, offset: float) -> Vector2:
	var a := polygon[int(offset)]
	var b := polygon[(int(offset) + 1) % polygon.size()]
	var t := offset - floorf(offset)
	return a.lerp(b, t)


func _split_segment(polygon: PackedVector2Array, offset: float) -> PackedVector2Array:
	var a := polygon[int(offset)]
	var b := polygon[(int(offset) + 1) % polygon.size()]
	var t := offset - floorf(offset)
	var new := polygon.duplicate()
	new.insert(int(offset) + 1, a.lerp(b, t))
	return new


func _draw_chunk() -> void:
	if _polygon.size() < 3:
		return

	if stroke_thickness > 0.0:
		var polyline := _polygon.duplicate()
		polyline.push_back(polyline[0])
		draw_polyline(polyline, color_stroke, stroke_thickness)

	if texture:
		var uv_transform := Transform2D().scaled(Vector2.ONE / texture.get_size())
		var uv0 := uv_transform * _polygon
		draw_colored_polygon(_polygon, color, uv0, texture)
	else:
		draw_colored_polygon(_polygon, color)


func _draw_overlay() -> void:
	draw_set_transform_matrix(global_transform.affine_inverse())
	for idx in range(get_points_count()):
		var p0 := get_point_world(idx)
		var radius := Vector2.ONE * 2.0
		var point_colour := Color.WHITE if idx == 0 else Color.BLACK if idx == get_points_count() - 1 else Color.DIM_GRAY
		draw_rect(Rect2(p0 - radius, radius * 2.0), point_colour)
		if get_points_count() > 1:
			var next_idx := (idx + 1) % get_points_count()
			var p1 := get_point_world(next_idx)
			draw_dashed_line(p0, p1, Color.WHITE)
			var dir := (p1 - p0).normalized()
			var side := dir.orthogonal()
			draw_line(p0, p0 + dir * 4.0, Color.MAGENTA)
			if idx == 0:
				draw_line(p0, p0 + side * 4.0, Color.YELLOW)

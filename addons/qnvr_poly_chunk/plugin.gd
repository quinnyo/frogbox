@tool
extends EditorPlugin

const EditPolyChunk2D := preload("src/edit_poly_chunk_2d.gd")


var gizmo_size := 8.0
var gizmo_picking_margin := 1.5

var visible := false

var target: PolyChunk2D
var mouse_position: Vector2
var active_point: int = -1:
	get: return -1 if input_mod_add else active_point
var active_segpos: float
var grab_position: Vector2
var input_grab := false
var input_mod_add := false

var _picked_point: int = -1
var _picked_edge: float = -1.0


func has_target() -> bool:
	return is_instance_valid(target) && target.is_inside_tree()


func is_editing() -> bool:
	var edsel := get_editor_interface().get_selection()
	return visible && has_target() && edsel.get_selected_nodes().has(target)


func is_active_point_valid() -> bool:
	return is_editing() && active_point >= 0 && active_point < target.get_points_count()


func is_active_segpos_valid() -> bool:
	return is_editing() && active_segpos >= 0.0 && active_segpos < float(target.get_points_count())


func is_grabbing_point() -> bool:
	return is_active_point_valid() && input_grab


## Get viewport containing the edited scene.
func get_canvas_viewport() -> Viewport:
	var scene_root := get_tree().get_edited_scene_root()
	return scene_root.get_parent() as Viewport if scene_root else null


## Get mouse position in edited scene viewport/world coordinates
func get_mouse_position() -> Vector2:
	var viewport := get_canvas_viewport()
	if viewport:
		var container := viewport.get_parent() as SubViewportContainer
		return viewport.global_canvas_transform.affine_inverse() * container.get_local_mouse_position()
	return Vector2.ZERO


## Get matrix to transform edited scene viewport/world coordinates to editor canvas overlay coordinates.
func get_canvas_transform() -> Transform2D:
	var viewport := get_canvas_viewport()
	return viewport.global_canvas_transform if viewport else Transform2D()


## Scale factor to keep canvas/world gizmos sized consistency with overlay/editor units...
func get_gizmo_scale() -> Vector2:
	return get_canvas_transform().affine_inverse().get_scale()


func _get_edit_context() -> EditPolyChunk2D:
	return get_node_or_null("_EditPolyChunk2D")


func _get_target_undo_redo() -> UndoRedo:
	if has_target():
		var undoman := get_undo_redo()
		var history_id := undoman.get_object_history_id(target)
		return undoman.get_history_undo_redo(history_id)
	return null


func _init_edit_context(p_target: PolyChunk2D) -> void:
	_unedit()
	target = p_target
	if has_target():
		_try_connect(target.updated, _on_target_updated)
		target.overlay_enabled = true
		var edctx := _get_edit_context()
		if not edctx:
			edctx = EditPolyChunk2D.new()
			edctx.name = "_EditPolyChunk2D"
			add_child(edctx)


## Clear target
func _unedit() -> void:
	if has_target():
		_try_disconnect(target.updated, _on_target_updated)
		target.overlay_enabled = false
		target.queue_redraw()
		target = null

	var edctx := _get_edit_context()
	if edctx:
		remove_child(edctx)
		edctx.queue_free()

	active_point = -1
	active_segpos = -1.0
	input_grab = false
	input_mod_add = false
	update_overlays()


func _grab_point(idx: int) -> void:
	active_segpos = -1.0
	if !is_editing() || idx < 0 || idx >= target.get_points_count():
		input_grab = false
		active_point = -1
	else:
		input_grab = true
		active_point = idx
		grab_position = mouse_position
	_update_mouse()


func _update_mouse() -> void:
	mouse_position = get_mouse_position()
	if is_editing():
		_picked_point = target.pick_point(target.to_local(mouse_position), (gizmo_size + gizmo_picking_margin) * get_gizmo_scale().x)
		if !input_grab && _picked_point != active_point:
			active_point = _picked_point

		_picked_edge = target.pick_edge(target.to_local(mouse_position), (2.0 * gizmo_size + gizmo_picking_margin) * get_gizmo_scale().x)
		active_segpos = _picked_edge
	else:
		_picked_point = -1
		_picked_edge = -1.0
		active_point = -1
		active_segpos = -1.0
	update_overlays()


func _on_target_updated() -> void:
	_update_mouse()


func _on_edsel_selection_changed() -> void:
	_update_mouse()


func _forward_canvas_gui_input(event: InputEvent) -> bool:
	_update_mouse()

	if event is InputEventKey:
		var kev := event as InputEventKey
		if kev.keycode == KEY_SHIFT && !kev.is_echo():
			input_mod_add = kev.is_pressed() && !is_grabbing_point()
			update_overlays()
			return false

	if event is InputEventMouse:
		var mbev := event as InputEventMouseButton
		if mbev:
			match [mbev.button_index, mbev.pressed]:
				[MOUSE_BUTTON_LEFT, true]:
					if input_mod_add:
						# APPEND
						EditPolyChunk2D.do_append_point(get_undo_redo(), target, target.to_local(mouse_position))
						input_mod_add = false
						_grab_point(target.get_points_count() - 1)
						return true
					elif is_active_point_valid():
						# GRAB
						_grab_point(active_point)
						return true
					elif is_active_segpos_valid():
						# SPLIT (ADD)
						var new_idx := EditPolyChunk2D.do_split_segment(get_undo_redo(), target, active_segpos)
						_grab_point(new_idx)
						return true
				[MOUSE_BUTTON_LEFT, false]:
					# RELEASE
					if is_grabbing_point():
						var delta := mouse_position - grab_position
						if delta.length_squared() > 0.0:
							var wpos := (target.get_point_world(active_point) + delta).round()
							EditPolyChunk2D.do_set_point(get_undo_redo(), target, active_point, target.to_local(wpos))
						_grab_point(-1)
						return true
				[MOUSE_BUTTON_RIGHT, true]:
					# CANCEL GRAB
					if is_grabbing_point():
						_grab_point(-1)
						return true
					# REMOVE
					elif is_active_point_valid():
						EditPolyChunk2D.do_remove_point(get_undo_redo(), target, active_point)
						return true

	return false


func _forward_canvas_draw_over_viewport(overlay: Control):
	if !is_editing():
		return

	target.queue_redraw()

	var points := target.global_transform * target.clone_points()
	if is_grabbing_point() && active_point >= 0 && active_point < points.size():
		points[active_point] += (mouse_position - grab_position)
	points = get_canvas_transform() * points
	var triangles := Geometry2D.triangulate_polygon(points)

	# draw drag preview polygon
	if is_grabbing_point() && points.size() > 2:
		overlay.draw_polyline(points, target.color.inverted(), 2.0)
		if !triangles.is_empty():
			overlay.draw_colored_polygon(points, Color(target.color.lightened(0.5), 0.8))

	#POINTS
	for idx in range(points.size()):
		var radius := gizmo_size
		var color := Color.LIGHT_GRAY
		var color_outline := Color.BLACK
		if idx == active_point:
			color_outline = Color.RED

		if idx == 0:
			color = Color.WHITE
		elif idx == points.size() - 1:
			color = Color.DIM_GRAY

		var centre := points[idx]
		overlay.draw_circle(centre, radius, color)
		overlay.draw_arc(centre, radius, 0.0, TAU, 36, color_outline, 2.0)

	#SPLIT SEGMENT THING
	if is_active_segpos_valid() && !is_active_point_valid():
		var seg := target.global_transform * target.get_segment(int(floor(active_segpos)))
		if seg.size() == 2:
			seg = get_canvas_transform() * seg
			var point := get_canvas_transform() * target.global_transform * target.interpolate_polyline(active_segpos)
			var dir := (seg[1] - seg[0]).normalized()
			var side := dir.orthogonal()
			var a0 := (dir + side * 2.0) * gizmo_size
			var b0 := (dir - side * 2.0) * gizmo_size
			overlay.draw_line(point + a0, point - a0, Color.RED, 2.0)
			overlay.draw_line(point + b0, point - b0, Color.RED, 2.0)


func _handles(object: Variant) -> bool:
	return object is PolyChunk2D


func _make_visible(p_visible: bool) -> void:
	visible = p_visible
	if !visible:
		_unedit()
	update_overlays()


func _edit(object: Variant) -> void:
	if object is PolyChunk2D:
		_init_edit_context(object)


func _clear() -> void:
	_unedit()


func _enter_tree() -> void:
	var edsel := get_editor_interface().get_selection()
	if edsel:
		_try_connect(edsel.selection_changed, _on_edsel_selection_changed)


func _exit_tree() -> void:
	var edsel := get_editor_interface().get_selection()
	if edsel:
		_try_disconnect(edsel.selection_changed, _on_edsel_selection_changed)


func _enable_plugin() -> void:
	add_custom_type("PolyChunk2D", "Node2D", preload("src/poly_chunk_2d.gd"), preload("icon/poly_chunk_2d.svg"))
	set_input_event_forwarding_always_enabled()


func _disable_plugin() -> void:
	remove_custom_type("PolyChunk2D")


func _get_plugin_icon() -> Texture2D:
	return preload("icon/plugin.svg")


func _selectables_find_recursive(root: Node) -> Array:
	var found: Array = []
	_walk_tree(root, func(node: Node) -> bool:
		if node is PolyChunk2D:
			found.push_back(node as PolyChunk2D)
		return true
		)
	return found


func _walk_tree(root: Node, f: Callable) -> void:
	if f.call(root):
		for child in root.get_children():
			_walk_tree(child, f)


static func _try_connect(p_signal: Signal, p_callable: Callable, p_flags: int = 0) -> void:
	if !p_signal.is_connected(p_callable):
		var err := p_signal.connect(p_callable, p_flags)
		if err != OK:
			push_error("failed to connect signal %s -> %s: '%s'(%s)" % [ p_signal, p_callable, error_string(err), err ])


static func _try_disconnect(p_signal: Signal, p_callable: Callable) -> void:
	if p_signal.is_connected(p_callable):
		p_signal.disconnect(p_callable)

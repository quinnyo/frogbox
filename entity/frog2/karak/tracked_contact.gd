class_name KarakTrackedContact
extends RefCounted

const DRAW_POINT_RADIUS := 4.0

var created: int = -1:
	set(_v): push_error("no set 'created', pls!")
	get: return _created

var updated: int = -1:
	set(_v): push_error("no set 'updated', pls!")
	get: return _updated

var collider: RID

var collider_position: PackedVector2Array
#var collider_shape: PackedInt64Array
var collider_velocity_at_position: PackedVector2Array
var local_normal: PackedVector2Array
var local_position: PackedVector2Array
var local_velocity_at_position: PackedVector2Array
#var local_shape: PackedInt64Array

var linear_velocity: Vector2

var _created: int = -1
var _updated: int = -1


func _init(p_collider: RID) -> void:
	_created = Engine.get_physics_frames()
	_updated = _created
	collider = p_collider


func get_points_count() -> int:
	return local_position.size()
func get_collider_position(idx: int) -> Vector2:
	return collider_position[idx]
func get_collider_velocity_at_position(idx: int) -> Vector2:
	return collider_velocity_at_position[idx]
func get_local_normal(idx: int) -> Vector2:
	return local_normal[idx]
func get_local_position(idx: int) -> Vector2:
	return local_position[idx]
func get_local_velocity_at_position(idx: int) -> Vector2:
	return local_velocity_at_position[idx]
#func get_relative_velocity_at_position(idx: int) -> Vector2:
#	return get_local_velocity_at_position(idx) - get_collider_velocity_at_position(idx)
func get_local_entry_velocity() -> Vector2:
	return linear_velocity
func get_relative_entry_velocity_at_position(idx: int) -> Vector2:
	return get_local_entry_velocity() - get_collider_velocity_at_position(idx)


func update_from_direct_body_state(contact_idx: int, state: PhysicsDirectBodyState2D) -> void:
	_flush()
	collider_position.push_back(state.get_contact_collider_position(contact_idx))
	collider_velocity_at_position.push_back(state.get_contact_collider_velocity_at_position(contact_idx))
	local_position.push_back(state.get_contact_local_position(contact_idx))
	local_normal.push_back(state.get_contact_local_normal(contact_idx))
	local_velocity_at_position.push_back(state.linear_velocity)


#func update_from_test_motion_result(result: PhysicsTestMotionResult2D, local_state: PhysicsDirectBodyState2D, collider_state: PhysicsDirectBodyState2D) -> void:
#	if created == -1:
#		created = Engine.get_physics_frames()
#		collider = result.get_collider_rid()
#		linear_velocity = local_state.linear_velocity
#
#	_flush()
#	var cpos := result.get_collision_point() + result.get_collision_normal() * result.get_collision_depth()
#	collider_position.push_back(cpos)
#	collider_velocity_at_position.push_back(collider_state.get_velocity_at_local_position(cpos))
#	local_position.push_back(result.get_collision_point())
#	local_normal.push_back(result.get_collision_normal())
#	local_velocity_at_position.push_back(local_state.get_velocity_at_local_position(result.get_collision_point()))


func get_age_ticks() -> int:
	return _updated - _created


func draw(canvas_item: RID) -> void:
	for idx in range(get_points_count()):
		var pos := get_local_position(idx)
		var nor := get_local_normal(idx)
		var side := nor.orthogonal()
		var color_point := Color(1,1,1,0.4)
		_draw_vec(canvas_item, pos, nor * DRAW_POINT_RADIUS * 2, color_point)
		RenderingServer.canvas_item_add_line(canvas_item, pos + side * DRAW_POINT_RADIUS, pos - side * DRAW_POINT_RADIUS, color_point, 1.0)

		_draw_vec(canvas_item, pos + nor, get_local_entry_velocity(), Color.RED)
		_draw_vec(canvas_item, pos - nor, get_collider_velocity_at_position(idx), Color.BLUE)
		_draw_vec(canvas_item, pos, get_relative_entry_velocity_at_position(idx), Color.MAGENTA)
#		_draw_vec(canvas_item, pos, get_relative_velocity_at_position(idx), Color(Color.YELLOW, 0.4))


func _draw_vec(canvas_item: RID, p: Vector2, v: Vector2, color: Color) -> void:
	var size := 6.0
	var n := v.normalized()
	var side := n.orthogonal() * size / 2.0
	var tip := p + v
	var head_base := tip - n * size
	RenderingServer.canvas_item_add_polygon(canvas_item, [ tip, head_base + side, head_base - side ], [ Color(color, 0.4) ])
	RenderingServer.canvas_item_add_line(canvas_item, tip, head_base + side, color, 1.0)
	RenderingServer.canvas_item_add_line(canvas_item, tip, head_base - side, color, 1.0)
	RenderingServer.canvas_item_add_line(canvas_item, p, head_base, Color(color, 0.4), 1.5)
	RenderingServer.canvas_item_add_line(canvas_item, p, head_base, color, 1.0)


func _clear_points() -> void:
	collider_position = PackedVector2Array()
	collider_velocity_at_position = PackedVector2Array()
	local_normal = PackedVector2Array()
	local_position = PackedVector2Array()
	local_velocity_at_position = PackedVector2Array()


## Clear contact data once per frame.
func _flush() -> void:
	if _updated != Engine.get_physics_frames():
		_updated = Engine.get_physics_frames()
		_clear_points()

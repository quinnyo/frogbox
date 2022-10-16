class_name PhysicsBodySnapshot2D
extends RefCounted


var angular_velocity: float
var center_of_mass: Vector2
var center_of_mass_local: Vector2
var inverse_inertia: float
var inverse_mass: float
var linear_velocity: Vector2
var sleeping: bool
var step: float
var total_angular_damp: float
var total_gravity: Vector2
var total_linear_damp: float
var transform: Transform2D

var contact_collider: Array[RID]
var contact_collider_id: PackedInt64Array
var contact_collider_object: Array[Object]
var contact_collider_position: PackedVector2Array
var contact_collider_shape: PackedInt64Array
var contact_collider_velocity_at_position: PackedVector2Array
var contact_local_normal: PackedVector2Array
var contact_local_position: PackedVector2Array
var contact_local_shape: PackedInt64Array


func get_contact_count() -> int:
	return contact_collider.size()
func get_contact_collider(contact_idx: int) -> RID:
	return contact_collider[contact_idx]
func get_contact_collider_id(contact_idx: int) -> int:
	return contact_collider_id[contact_idx]
func get_contact_collider_object(contact_idx: int) -> Object:
	return contact_collider_object[contact_idx]
func get_contact_collider_position(contact_idx: int) -> Vector2:
	return contact_collider_position[contact_idx]
func get_contact_collider_shape(contact_idx: int) -> int:
	return contact_collider_shape[contact_idx]
func get_contact_collider_velocity_at_position(contact_idx: int) -> Vector2:
	return contact_collider_velocity_at_position[contact_idx]
func get_contact_local_normal(contact_idx: int) -> Vector2:
	return contact_local_normal[contact_idx]
func get_contact_local_position(contact_idx: int) -> Vector2:
	return contact_local_position[contact_idx]
func get_contact_local_shape(contact_idx: int) -> int:
	return contact_local_shape[contact_idx]


@warning_ignore(return_value_discarded)
func _contacts_resize(p_size: int) -> void:
	contact_collider.resize(p_size)
	contact_collider_id.resize(p_size)
	contact_collider_object.resize(p_size)
	contact_collider_position.resize(p_size)
	contact_collider_shape.resize(p_size)
	contact_collider_velocity_at_position.resize(p_size)
	contact_local_normal.resize(p_size)
	contact_local_position.resize(p_size)
	contact_local_shape.resize(p_size)


static func from_body_direct_state(state: PhysicsDirectBodyState2D) -> PhysicsBodySnapshot2D:
	var res := PhysicsBodySnapshot2D.new()
	res.angular_velocity = state.angular_velocity
	res.center_of_mass = state.center_of_mass
	res.center_of_mass_local = state.center_of_mass_local
	res.inverse_inertia = state.inverse_inertia
	res.inverse_mass = state.inverse_mass
	res.linear_velocity = state.linear_velocity
	res.sleeping = state.sleeping
	res.step = state.step
	res.total_angular_damp = state.total_angular_damp
	res.total_gravity = state.total_gravity
	res.total_linear_damp = state.total_linear_damp
	res.transform = state.transform
	res._contacts_resize(state.get_contact_count())
	for contact_idx in range(state.get_contact_count()):
		res.contact_collider[contact_idx] = state.get_contact_collider(contact_idx)
		res.contact_collider_id[contact_idx] = state.get_contact_collider_id(contact_idx)
		res.contact_collider_object[contact_idx] = state.get_contact_collider_object(contact_idx)
		res.contact_collider_position[contact_idx] = state.get_contact_collider_position(contact_idx)
		res.contact_collider_shape[contact_idx] = state.get_contact_collider_shape(contact_idx)
		res.contact_collider_velocity_at_position[contact_idx] = state.get_contact_collider_velocity_at_position(contact_idx)
		res.contact_local_normal[contact_idx] = state.get_contact_local_normal(contact_idx)
		res.contact_local_position[contact_idx] = state.get_contact_local_position(contact_idx)
		res.contact_local_shape[contact_idx] = state.get_contact_local_shape(contact_idx)
	return res

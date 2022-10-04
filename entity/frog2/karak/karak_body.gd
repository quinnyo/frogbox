class_name KarakBody2D
extends Node2D

#signal contact_begin(contact: KarakTrackedContact)
#signal contact_tracked(contact: KarakTrackedContact)
#signal contact_end(contact: KarakTrackedContact)

const FN_THINK := "_karak_think"
const FN_INTEGRATE := "_karak_integrate"
const FN_CONTACT_BEGIN := "_karak_contact_begin"
const FN_CONTACT_TRACKED := "_karak_contact_tracked"
const FN_CONTACT_END := "_karak_contact_end"


@export var up := Vector2.UP

@export var do_force_integration := true

## If true, rotate physics body to match up vector
@export var lock_rotation := false


var body: RID
var body_snapshot: PhysicsBodySnapshot2D = PhysicsBodySnapshot2D.new()
var tracked_contacts := {}


func _enter_tree() -> void:
	_setup()


func get_tracked_contact(collider: RID) -> KarakTrackedContact:
	return tracked_contacts.get(collider)


func get_parent_body() -> RigidBody2D:
	return get_parent()


func get_rid() -> RID:
	return body


func invoke(method: StringName, argv: Array) -> void:
	for child in get_children(true):
		if !child.has_method(method):
			continue
		child.callv(method, argv)


func _setup() -> void:
	body = get_parent_body().get_rid()
	PhysicsServer2D.body_set_force_integration_callback(get_rid(), _integrat)
	PhysicsServer2D.body_set_omit_force_integration(get_rid(), true)


func _integrat(state: PhysicsDirectBodyState2D) -> void:
	_update_tracked_contacts(state)

	invoke(FN_THINK, [ self, state ])
	invoke(FN_INTEGRATE, [ self, state ])

	if do_force_integration:
		state.integrate_forces()

	if lock_rotation:
		var tf := state.transform
		tf.set_rotation(Vector2.UP.angle_to(up))
		state.transform = tf

	body_snapshot = PhysicsBodySnapshot2D.from_body_direct_state(state)


func _update_tracked_contacts(state: PhysicsDirectBodyState2D) -> void:
	for contact_idx in state.get_contact_count():
		var collider := state.get_contact_collider(contact_idx)
		var tracked := get_tracked_contact(collider)
		if tracked == null:
			tracked = KarakTrackedContact.new(state.get_contact_collider(contact_idx))
			# MUST USE VELOCITY FROM PREVIOUS FRAME
			tracked.linear_velocity = body_snapshot.linear_velocity
			tracked_contacts[collider] = tracked
		# MUST USE VELOCITY FROM PREVIOUS FRAME
		tracked.linear_velocity = body_snapshot.linear_velocity
		tracked.update_from_direct_body_state(contact_idx, state)

	for k in tracked_contacts.keys():
		var contact := get_tracked_contact(k)
		if contact.created == Engine.get_physics_frames():
			invoke(FN_CONTACT_BEGIN, [ contact ])
		if contact.updated == Engine.get_physics_frames():
			invoke(FN_CONTACT_TRACKED, [ contact ])
		elif contact.updated < Engine.get_physics_frames() - 1:
			invoke(FN_CONTACT_END, [ contact ])
			tracked_contacts.erase(contact.collider)


func predict_jump_trajectory(p_initial_velocity: Vector2, p_time_limit: float = 1.0) -> PackedVector2Array:
	return predict_trajectory(Vector2.ZERO, p_initial_velocity, body_snapshot.total_linear_damp, body_snapshot.total_gravity, body_snapshot.step, p_time_limit)


#func integrate_dynamic() -> void:
#	var applied_force := Vector2.ZERO
#	var constant_force := state.get_constant_force()
#	var applied_torque := 0.0
#	var constant_torque := state.get_constant_torque()
#	var force := state.total_gravity * mass + applied_force + constant_force
#	var torque := applied_torque + constant_torque
#
#	var linear_damp := 1.0 - state.step * state.total_linear_damp
#	if linear_damp <= 0.0: # reached zero in the given time
#		linear_damp = 0.0
#
#	var angular_damp := 1.0 - state.step * state.total_angular_damp
#	if angular_damp <= 0.0: # reached zero in the given time
#		angular_damp = 0.0
#
#	state.linear_velocity *= linear_damp
#	state.angular_velocity *= angular_damp
#
#	state.linear_velocity += state.inverse_mass * force * state.step
#	state.angular_velocity += state.inverse_inertia * torque * state.step


## returns the updated linear velocity vector
static func integrate_step(p_step: float, p_linear_velocity: Vector2, p_total_linear_damp: float, p_accel: Vector2 = Vector2.ZERO) -> Vector2:
#	var force := gravity * mass + applied_force + constant_force

	var linear_damp := 1.0 - p_step * p_total_linear_damp

	if linear_damp <= 0.0: # reached zero in the given time
		linear_damp = 0.0

	return p_linear_velocity * linear_damp + p_accel * p_step


static func predict_trajectory(p_initial_position: Vector2, p_initial_velocity: Vector2, p_total_linear_damp: float, p_accel: Vector2, p_step: float, p_time_limit: float = 1.0) -> PackedVector2Array:
	var points := PackedVector2Array()
	var linear_velocity := p_initial_velocity
	var pos := p_initial_position
	var time := 0.0
	while time < p_time_limit:
		linear_velocity = integrate_step(p_step, linear_velocity, p_total_linear_damp, p_accel)
		pos += linear_velocity * p_step
		points.push_back(pos)
		time += p_step

	return points

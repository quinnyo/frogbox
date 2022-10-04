class_name KactGripJoint
extends Kact


enum GripMode { JOINT, TRANSFORM }

var mode := GripMode.JOINT
var collider: RID
var contact_normal: Vector2
## Pose in collider's space
var pose: Transform2D

var _active_mode: GripMode
var _joint: RID


func _notification(what: int) -> void:
	match what:
		NOTIFICATION_PREDELETE:
			if is_instance_valid(body):
				PhysicsServer2D.body_remove_collision_exception(body.get_rid(), collider)
			if _joint:
				PhysicsServer2D.free_rid(_joint)


func _create_pin_joint(p_anchor: Vector2, p_body_a: RID, p_body_b: RID) -> RID:
	var joint = PhysicsServer2D.joint_create()
	PhysicsServer2D.joint_make_pin(joint, p_anchor, p_body_a, p_body_b)
	return joint


func _start() -> void:
	_active_mode = mode
	var local_state := PhysicsServer2D.body_get_direct_state(body.get_rid())
	var local_transform := local_state.transform
	var collider_state := PhysicsServer2D.body_get_direct_state(collider)
	var collider_transform := collider_state.transform
	local_transform.set_rotation(Vector2.UP.angle_to(contact_normal))
	pose = collider_transform.inverse() * local_transform
	body.lock_rotation = true
	PhysicsServer2D.body_add_collision_exception(body.get_rid(), collider)
	match _active_mode:
		GripMode.JOINT:
			_joint = _create_pin_joint(local_transform.origin, collider, body.get_rid())
		GripMode.TRANSFORM:
			body.do_force_integration = false


func _stop() -> void:
	body.lock_rotation = false
	PhysicsServer2D.body_remove_collision_exception(body.get_rid(), collider)
	match _active_mode:
		GripMode.JOINT:
			PhysicsServer2D.free_rid(_joint)
			_joint = RID()
		GripMode.TRANSFORM:
			body.do_force_integration = true


func _integrate(state: PhysicsDirectBodyState2D) -> void:
#	var avg_normal := Vector2()
#	for idx in range(state.get_contact_count()):
#		if state.get_contact_collider(idx) != collider:
#			continue
#		var normal := state.get_contact_local_normal(idx)
#		avg_normal = avg_normal / 2.0 + normal / 2.0
#
#	pose.set_rotation(Vector2.UP.angle_to(avg_normal))

	var collider_state := PhysicsServer2D.body_get_direct_state(collider)
	var target_pose := collider_state.transform * pose
	# force rotation
	body.up = -target_pose.y
#	state.transform = Transform2D(target_pose.x, target_pose.y, state.transform.origin)
	if _active_mode == GripMode.TRANSFORM:
		state.transform = target_pose

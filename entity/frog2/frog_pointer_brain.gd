extends Node2D

const POINTER_AIM_SCALE := 5.0
const HOP_RANDOM: Array[float] = [-0.426716, 0.156269, -0.484452, 0.501348, -0.286018, 0.125836, -0.256589, 0.129383]

var rules: FrogRules = preload("default_rules.tres")

var current: Kact:
	set(value):
		if value != current:
#			print("kact '%s' => '%s'" % [ current, value ])
			current = value

var _global_pointer: Vector2
var _aim_vec: Vector2
var _jump_aiming: bool = false

var _jump_trajectory := PackedVector2Array()
var _jump_vel := Vector2()

var _hop_random_idx := 0
var _grip_enable_tick := 0

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("jump"):
		if has_grip():
			_jump_aiming = true
	elif event.is_action_released("jump"):
		if _jump_aiming && !_jump_vel.is_equal_approx(Vector2.ZERO):
			jump(_jump_vel)
			_jump_vel = Vector2.ZERO
			queue_redraw()
	elif event.is_action_released("teleport"):
		teleport(_global_pointer)


func _draw() -> void:
	draw_set_transform_matrix(global_transform.inverse())
	if _jump_aiming && _jump_trajectory.size() >= 2:
		var points := Transform2D(0.0, global_position) * _jump_trajectory
		draw_polyline(points, Color(Color.SPRING_GREEN, 0.2), 2.0)
		for i in range(points.size()):
			var p := points[i]
			if i % 3 == 0 || i == points.size() - 1:
				draw_arc(p, 8.0, 0.0, TAU, 12, Color(Color.SPRING_GREEN, 0.35))


func has_current() -> bool:
	return is_instance_valid(current)


func has_active() -> bool:
	return is_instance_valid(current) && current.is_active()


func set_current(kact: Kact) -> void:
	if current:
		current.stop()
	current = kact


func teleport(to: Vector2) -> void:
	var k := KactTeleport.new()
	k.exit_transform = Transform2D(0.0, to)
	set_current(k)


func jump(vel: Vector2) -> void:
	var ballistic := KactBallistic.new()
	ballistic.initial_velocity = vel
	set_current(ballistic)
	_grip_enable_tick = Engine.get_physics_frames() + 1


func grip_form(collider: RID, normal: Vector2) -> void:
	var grip := KactGripJoint.new()
	grip.collider = collider
	grip.contact_normal = normal
	set_current(grip)


func is_action_allowed() -> bool:
	return is_processing_input() && !Input.is_action_pressed("abort")


func has_grip() -> bool:
	return has_active() && current is KactGripJoint


func is_hop_pressed() -> bool:
	return is_action_allowed() && Input.is_action_pressed("hop")


func _karak_contact_tracked(contact: KarakTrackedContact) -> void:
	if has_grip() || _grip_enable_tick > Engine.get_physics_frames():
		return

	for idx in range(contact.get_points_count()):
		var normal := contact.get_local_normal(idx)
		var vel := contact.get_relative_entry_velocity_at_position(idx)
		if rules.grip_or_slip(vel, normal):
			grip_form(contact.collider, normal)
			break


func _karak_think(body: KarakBody2D, _body_state: PhysicsDirectBodyState2D) -> void:
	if current && current.status == Kact.Status.COMPLETE:
		set_current(null)

#	if !has_grip() && _grip_enable_tick <= Engine.get_physics_frames():
#		for idx in range(body_state.get_contact_count()):
#			var normal := body_state.get_contact_local_normal(idx)
#			var collider := body_state.get_contact_collider(idx)
#			var collider_vel := body_state.get_contact_collider_velocity_at_position(idx)
#			var vel := body_state.linear_velocity - collider_vel
#			if rules.grip_or_slip(vel, normal):
#				grip_form(collider, normal)
#				break

	var new_jump_vel := Vector2.ZERO
	if !is_action_allowed() || !has_grip():
		_jump_aiming = false
	elif _jump_aiming:
		var v := _aim_vec * POINTER_AIM_SCALE
		var vx := v.slide(global_transform.y)
		var vy := global_transform.y * minf(v.dot(global_transform.y), -128.0)
		var clamped := vx + vy
		new_jump_vel = rules.limit_jump(clamped)
	elif is_hop_pressed():
		# hop whenever possible (and button is pressed)
		var h := HOP_RANDOM[_hop_random_idx % HOP_RANDOM.size()]
		var aim_dir := _aim_vec.normalized()
		var is_looking_up := aim_dir.dot(-global_transform.y) >= 0.8
		var up := -global_transform.y * (2.0 + h)
		var forward := global_transform.x * signf(to_local(_global_pointer).x)
		var hop_vel := (up * 1.5) if is_looking_up else (forward * 2.0 + up)
		jump(hop_vel * 80.0)

	if !new_jump_vel.is_equal_approx(_jump_vel):
		_jump_vel = new_jump_vel
		if _jump_vel.is_equal_approx(Vector2.ZERO):
			_jump_trajectory = PackedVector2Array()
		else:
			_jump_trajectory = body.predict_jump_trajectory(_jump_vel, 1.5)
		queue_redraw()

	if current:
		assert(current.status != Kact.Status.ERROR)
		if current.status == Kact.Status.INIT:
			current.bind(body)
			current.start()

		current.think()


func _karak_integrate(_body: KarakBody2D, state: PhysicsDirectBodyState2D) -> void:
	if current && current.status == Kact.Status.RUNNING:
		current.integrate(state)


func _on_pointer_moved(p: Vector2) -> void:
	_global_pointer = to_global(p)
	_aim_vec = _global_pointer - global_position


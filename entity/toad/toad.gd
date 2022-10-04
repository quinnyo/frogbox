## toad.gd
## Hopping toad character.
## This script is a mess.
extends CharacterBody2D

const FLOOR_SLIDE_EPSILON := 0.35

class Jumptility:
	static func grav(y: float, t: float) -> float:
		return (2.0 * y) / (t * t)

	static func launch_vel(y: float, g: float) -> float:
		return sqrt(2.0 * absf(g) * absf(y))

	static func apex_time(v: float, g: float) -> float:
		return absf(v) / absf(g)

	static func apex_height(v: float, g: float) -> float:
		return (0.5 * v * v) / g


## returns the update linear velocity vector
static func integrate_step(p_step: float, p_linear_velocity: Vector2, p_total_linear_damp: float, p_accel: Vector2 = Vector2.ZERO) -> Vector2:
#	var force := gravity * mass + applied_force + constant_force

	var linear_damp := 1.0 - p_step * p_total_linear_damp

	if linear_damp <= 0.0: # reached zero in the given time
		linear_damp = 0.0

	return p_linear_velocity * linear_damp + p_accel * p_step


class JumpTrajectory:
	var initial_pose: Transform2D
	var initial_vel: Vector2

	var time: float = 0.0
	var pose: Transform2D
	var linear_velocity: Vector2
	var collision: KinematicCollision2D
	var collided: bool
	var path: PackedVector2Array

	func get_travel() -> Vector2:
		return pose.origin - initial_pose.origin


func predict_jump(p_initial_velocity: Vector2, p_total_linear_damp: float, p_accel: Vector2, p_step: float) -> JumpTrajectory:
	var time_limit := jump_apex_time * 3.1
	var jt := JumpTrajectory.new()
	jt.initial_vel = p_initial_velocity
	jt.linear_velocity = p_initial_velocity
	jt.initial_pose = global_transform
	jt.pose = global_transform
	while jt.collided == false && jt.time < time_limit:
		jt.linear_velocity = integrate_step(p_step, jt.linear_velocity, p_total_linear_damp, p_accel)
		var motion := jt.linear_velocity * p_step
		var collision := KinematicCollision2D.new()
		if test_move(jt.pose, motion, collision):
			jt.collided = true
			motion = collision.get_travel()
			jt.collision = collision
		jt.pose.origin += motion
		jt.path.push_back(jt.pose.origin)
		jt.time += p_step

	return jt


@export var jump_height := 18.0
@export var jump_apex_time := 0.16
var jump_gravity: float:
	get: return Jumptility.grav(jump_height, jump_apex_time)


@export var hop_forward := 85.0

@export var hop_interval := 0.7

## horizontal damping applied when sliding on floor
@export var damp_floor := 9.5

@export var face_left := true


var face_sign: float:
	set(x): face_left = x < 0.0
	get: return -1.0 if face_left else 1.0

var _hop_charge := 0.0
var _jump_trajectory: JumpTrajectory
var _target_rotation: float


func jump(impulse: Vector2) -> void:
	velocity = impulse


func is_sliding_on_floor() -> bool:
	return is_on_floor() && velocity.y >= 0.0 && !is_zero_approx(velocity.x)


func _think_floor(delta: float) -> void:
	queue_redraw()
	if is_zero_approx(velocity.x):
		var g := Jumptility.grav(jump_height, jump_apex_time)
		var vy := Jumptility.launch_vel(jump_height, g)
		var jump_vel := Vector2(face_sign * hop_forward, -vy)
		_jump_trajectory = predict_jump(jump_vel, 0.0, Vector2.DOWN * g, delta)
		if _jump_trajectory.collided:
			var dx := absf(_jump_trajectory.get_travel().x)
			var vx := dx / (2.0 * jump_apex_time)
			jump_vel.x = face_sign * vx
			_jump_trajectory = predict_jump(jump_vel, 0.0, Vector2.DOWN * g, delta)

		if !_jump_trajectory.collided:
			# try reverse
			jump_vel.x *= -0.5
			_jump_trajectory = predict_jump(jump_vel, 0.0, Vector2.DOWN * g, delta)
			if _jump_trajectory.collided:
				face_left = !face_left

		_hop_charge += delta
		if _hop_charge >= hop_interval:
			_hop_charge = 0.0
			jump(_jump_trajectory.initial_vel)
			_target_rotation = Vector2.UP.angle_to(_jump_trajectory.collision.get_normal()) if _jump_trajectory.collided else global_rotation
	else:
		_jump_trajectory = null
		_hop_charge = 0.0


func _apply_forces(delta: float) -> void:
	if not is_on_floor():
		velocity.y += jump_gravity * delta

	if is_sliding_on_floor():
		velocity.x = velocity.x / (1.0 + damp_floor * delta)
		if absf(velocity.x) < FLOOR_SLIDE_EPSILON:
			velocity.x = 0.0


func _physics_process(delta: float) -> void:
	_apply_forces(delta)

	if is_on_floor():
		_target_rotation = Vector2.UP.angle_to(get_floor_normal())
		global_rotation = _target_rotation
		_think_floor(delta)

	var rotdiff := absf(_target_rotation - global_rotation)
	if rotdiff < 0.001:
		global_rotation = _target_rotation
	else:
		global_rotation = lerp_angle(global_rotation, _target_rotation, minf(1.0, delta / rotdiff * 15))

	if !is_zero_approx(velocity.x):
		face_sign = signf(velocity.x)

#	var was_falling := !is_on_floor() && velocity.y >= 0.0

	move_and_slide()

#	if was_falling && is_on_floor():
#		pass

	if is_on_wall():
		# bounce
		face_sign = signf(get_wall_normal().x)
		velocity.x = face_sign * absf(velocity.x * 0.5)

	var col := $contact_damage as Node2D
	col.scale = Vector2(face_sign, 1.0)
	var sprite := $toad as Sprite2D
	sprite.flip_h = face_left


func _draw() -> void:
	if !get_tree().debug_collisions_hint:
		return
	if is_on_floor() && _jump_trajectory && _jump_trajectory.path.size() >= 2:
		draw_set_transform_matrix(global_transform.affine_inverse())
		draw_polyline(_jump_trajectory.path, Color.GREEN_YELLOW, 1.0)

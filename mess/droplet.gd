class_name KlWaterDrop
extends RigidBody2D


@export var detect_radius: float = 16.0
@export var stick_power: float = 96.0


func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	_do_raycast_thing(state)


func _do_raycast_thing(state: PhysicsDirectBodyState2D) -> void:
	var space := state.get_space_state()
	var query := PhysicsRayQueryParameters2D.create(state.transform.origin, Vector2(), self.collision_mask, [ get_rid() ])
	var deg := 0
	while deg < 360:
		var dir := Vector2.from_angle(deg_to_rad(deg))
		query.to = query.from + dir * detect_radius
		var result := space.intersect_ray(query)
		if result.size():
			var p: Vector2 = result.position
			var diff := p - state.transform.origin
			var dist := diff.length()
			var intensity := 1.0 / dist * dist * stick_power
			state.apply_central_force(intensity * dir)
		deg += 15

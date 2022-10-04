class_name KactBallistic
extends Kact

var initial_velocity: Vector2


func _start() -> void:
#	body.up = Vector2.UP
	body.lock_rotation = false


func _integrate(state: PhysicsDirectBodyState2D) -> void:
	if get_ticks() == 0:
#		state.transform.origin += -state.transform.y
		state.linear_velocity = initial_velocity
		state.angular_velocity = 0.0
		_status = Status.COMPLETE

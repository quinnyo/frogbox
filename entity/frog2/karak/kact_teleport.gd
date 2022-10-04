class_name KactTeleport
extends Kact


var exit_transform: Transform2D
var exit_velocity: Vector2


func _start() -> void:
	body.up = Vector2.UP


func _integrate(state: PhysicsDirectBodyState2D) -> void:
	state.transform = self.exit_transform
	state.linear_velocity = self.exit_velocity
	_status = Status.COMPLETE


func _debug_draw(canvas: CanvasItem) -> void:
	canvas.draw_dashed_line(Vector2.ZERO, self.exit_transform.origin, Color.MAGENTA)
